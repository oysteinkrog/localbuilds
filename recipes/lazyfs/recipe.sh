# LazyFS 0.3.1 (FUSE file system with a page cache that drops unsynced writes on demand),
# as the pacman package lazyfs-local. Used by the Agent Hub power-loss test.
#
# Pinned to the fork branch local/0.3.1, which is upstream tag 0.3.1 with no local changes.

UPSTREAM=https://github.com/dsrhaslab/lazyfs.git
FORK=https://github.com/oysteinkrog/lazyfs.git
MODE=fork
KIND=pkg
PIN=045a0b3a1126725e693934e29d3ba15e08cc39ec

lb_pkgver() {
    echo "0.3.1.g${LB_COMMIT:0:10}"
}
