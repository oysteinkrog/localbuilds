#!/bin/bash
# Regression check for the two fork commits on fix/shm-recreate. Upstream 0.3.1 fails both.
# 1. readdir: mounts LazyFS, writes a 32 KiB file without fsync, maps it shared (as SQLite
#    maps its -shm WAL index), lists the folder, then reads the mapping again. Upstream
#    sets the file's size to 0 on readdir, and the read gets SIGBUS.
# 2. statfs: the mount must report the backing file system's blocks. Upstream reports 0.
#
# Usage: check-readdir-mmap.sh [lazyfs binary]   (default /usr/bin/lazyfs)
# Exit 0 when both hold.
set -u
bin=${1:-/usr/bin/lazyfs}
w=$(mktemp -d "${TMPDIR:-/var/tmp}/lazyfs-check.XXXXXX")
mkdir -p "$w/root" "$w/mnt"
cat >"$w/cfg.toml" <<CFG
[faults]
fifo_path="$w/fifo"

[cache]
apply_eviction=false

[cache.simple]
custom_size="64mb"
blocks_per_page=1

[filesystem]
log_all_operations=false
logfile="$w/lazyfs.log"
CFG
"$bin" "$w/mnt" --config-path "$w/cfg.toml" -o modules=subdir -o subdir="$w/root" -f \
    >"$w/lazyfs.err" 2>&1 &
pid=$!
for _ in $(seq 100); do
    mountpoint -q "$w/mnt" && break
    sleep 0.1
done
if ! mountpoint -q "$w/mnt"; then
    echo "FAIL: LazyFS did not mount; see $w/lazyfs.err"
    kill "$pid" 2>/dev/null
    exit 2
fi

python3 -I - "$w/mnt" <<'PY'
import mmap, os, sys
d = sys.argv[1]
fd = os.open(os.path.join(d, "x.db-shm"), os.O_RDWR | os.O_CREAT, 0o644)
os.pwrite(fd, b"\0" * 32768, 0)
m = mmap.mmap(fd, 32768, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)
m[0:4] = b"WAL!"
os.listdir(d)
assert bytes(m[0:4]) == b"WAL!"
PY
rc=$?
if [ "$rc" -eq 0 ] && [ "$(stat -f -c %b "$w/mnt")" -eq 0 ]; then
    echo "FAIL: statfs on the mount reports 0 blocks"
    rc=3
fi

fusermount3 -u "$w/mnt"
wait "$pid" 2>/dev/null
if [ "$rc" -eq 0 ]; then
    echo "PASS: the shared mapping survives a readdir, and statfs reports the backing space"
    rm -r "$w"
else
    echo "FAIL: exit $rc (135: SIGBUS after readdir, 3: statfs); files in $w"
fi
exit "$rc"
