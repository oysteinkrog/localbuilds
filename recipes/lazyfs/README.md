# LazyFS, a FUSE file system that loses unsynced writes on demand, used by the Agent Hub power-loss test

Upstream is `dsrhaslab/lazyfs`; the fork is `oysteinkrog/lazyfs`. The clone lives at
`~/src/lazyfs`. The package is `lazyfs-local`.

LazyFS keeps its own page cache and writes data to the backing directory only on fsync.
`lazyfs::clear-cache` (sent through the FIFO named in the config) drops everything not
yet synced, which simulates a power loss.

## What the package installs

| Path | What |
|---|---|
| `/usr/bin/lazyfs` | the file system; finds `libpcache.so` through an rpath |
| `/usr/lib/lazyfs/libpcache.so*` | the page cache library, built from `libs/libpcache` |
| `/usr/share/lazyfs/default.toml` | upstream sample config |
| `/usr/share/lazyfs/mount-lazyfs.sh` | upstream mount helper |

FUSE needs `user_allow_other` in `/etc/fuse.conf` when `allow_other` is used.

## Fork branches

| Branch | What it is |
|---|---|
| `local/0.3.1` | upstream tag 0.3.1 (`045a0b3a`), no local changes. |
| `fix/shm-recreate` | `local/0.3.1` plus two fixes. This is what is built. `77e87106`: readdir no longer passes `FUSE_FILL_DIR_PLUS` with a stat that has no size. With it, any readdir set every open file's size to 0 in the kernel, and a shared mapping of an unsynced file (SQLite's `-shm`) got SIGBUS. `9ee91517`: statfs passes through to the backing folder; without it df and free-space checks saw 0 blocks. `check-readdir-mmap.sh [lazyfs binary]` checks both: exit 0 on this build, a failure on upstream 0.3.1. |

## Build notes

CMake fetches toml11 and spdlog from GitHub during the build, so the build needs network
access. CMake 4 rejects the old minimum version in toml11 v3.7.1, so the PKGBUILD passes
`-DCMAKE_POLICY_VERSION_MINIMUM=3.5`. Tests are off (`LAZYFS_BUILD_TESTS=OFF`), as in
upstream's `build.sh`.
