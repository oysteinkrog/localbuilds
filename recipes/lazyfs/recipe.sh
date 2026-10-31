# LazyFS 0.3.1 (FUSE file system with a page cache that drops unsynced writes on demand),
# as the pacman package lazyfs-local. Used by the Agent Hub power-loss test.
#
# Pinned to the fork branch fix/shm-recreate: upstream tag 0.3.1 plus the readdir size fix
# (see README.md).

UPSTREAM=https://github.com/dsrhaslab/lazyfs.git
FORK=https://github.com/oysteinkrog/lazyfs.git
MODE=fork
KIND=pkg
PIN=77e8710692bd765bc95262307596e5f3444738b6

lb_pkgver() {
    echo "0.3.1.g${LB_COMMIT:0:10}"
}
