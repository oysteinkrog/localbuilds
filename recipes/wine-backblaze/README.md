# Wine 11.20 for Backblaze Personal, as a private copy

This recipe builds the fork branch
[`backblaze/wine-11.20`](https://github.com/oysteinkrog/wine/tree/backblaze/wine-11.20) of
`oysteinkrog/wine` and installs it to `~/.local/share/backblaze-wine/<build id>/`, with
`current` pointing at the one in use. Only the Backblaze prefix uses it.

Most commits are Martyn Forryan's Wine patches from
[iamfoz/backblaze-64-personal-wine-container](https://github.com/iamfoz/backblaze-64-personal-wine-container)
(commit `b5387357`, `patches/`), written against wine-11.19. All of them apply to wine-11.20
without changes. Each patch is one commit, and each runtime switch is a separate commit after
them, in the fork's order. Every change is off unless its environment variable is set, so this
Wine behaves like stock Wine by default.

| Module | Variable | What it fixes |
|---|---|---|
| wineserver | `WINE_SOCK_SEND_READY=1` | Reports a socket as writable when the kernel would accept a send. Stock Wine holds one upload stream to about 140 KB/s. WineHQ bug 59893 |
| wineserver | `WINE_SOCK_FDWRITE_REARM=1` | Lets a socket report `FD_WRITE` again after a poll finds it full. Needs `WINE_SOCK_SEND_READY=1`. The fork measured about three times the total upload rate |
| wineserver | `WINE_SERVICE_TOKEN=1` | Gives services the LocalSystem group and an enabled SeDebugPrivilege. Backblaze 10.0.3 and later need it, or every backup pass loses its four-hour lock. Also needed to debug: bztransmit denies everyone access to its own process, so `winedbg` can only attach (and `OpenProcess` only succeeds) with this set |
| wineserver | `WINE_OFD_LOCKS=1` | Uses open file description locks, so wineserver can close a file the client closed. Without it the client leaks descriptors |
| ntdll | `WINE_CASE_CACHE=1` | Decides once per device whether names are case sensitive, instead of after every failed lookup. Speeds up scans |
| ntdll, kernelbase | `WINE_MOUNTMGR_CACHE=1` | Keeps the mountmgr's drive answer per Unix device, and the drive type per drive letter, for 30 s, failures included. Backblaze's scanner calls `GetFileInformationByHandle` and `GetDriveTypeW` (with the file's full path) for every file, and each call cost five or more server round trips plus a signal, because the mountmgr answers from another process. That held the scanner to about 480 files/s. A benchmark that opens each file and calls both went from about 6,000 to about 19,000 files/s. Local commits, not from iamfoz. Two drive letters on one Unix device share the cached answer |
| ntdll | `WINE_HEAP_BIN_SKIP=1` | Makes the heap look at no more than 8 blocks of a request's own free list before it moves to the next list, where every block fits. Stock Wine walks the whole list, so a list full of blocks just below the request size costs a full walk on every allocation. bztransmit spent about 75% of its CPU there while it read its 37 GB upload history, at about 1 MB/s. A test with 10,000 such blocks went from 218 to 1.5 µs per allocation. Read from the Windows environment, so a service needs it in the registry too. Local commit, not from iamfoz |
| wineserver | `WINE_NOTIFY_HASH=1` | Spreads the inodes of directory change watches over 65521 hash buckets instead of 31. Backblaze watches whole drives, about 305,000 directories here, so each lookup walked about 10,000 list entries. wineserver ran at 85% of one core, over half of it in `find_inode`, and every server call from the client waited behind it. Local commit, not from iamfoz |
| wineserver | `WINE_REALPATH_CACHE=1` | Keeps the resolved name of recently used directories for one second when the server opens a file. `realpath()` calls `readlink()` on every path component, over CIFS for the NAS drives, inside the single-threaded server. During a full rescan wineserver ran at 100% of a core with about half its time in `open_fd` and `readlink`. Directories opened as `dir/` and symlinks such as the drive letters are cached too, and a rename clears the cache. Local commit, not from iamfoz |
| kernelbase | `WINE_LONGPATH_CACHE=1` | Remembers for one second what each path prefix passed to `GetLongPathNameW` resolved to. Wine checks every component with `FindFirstFileW`, which costs several server calls. The client calls it many times per file, mostly on its own data folders: about 84 directory queries per backed-up file, and about 43% of the client's time went to rewriting two status files. A component that was not found is never cached. In a test, 20,000 calls went from 6,674 ms to 10 ms with identical results. Local commit, not from iamfoz |
| wineserver | `WINE_REPLACE_READ_ONLY_OPEN=1` | Lets a rename replace a file that other handles have open only for reading. Windows refuses this, but on Unix the readers keep the old file. The client rewrites its status files through a `.tmp` file many times a second while bzbui and bzserv read them about 100 times a second each, and each refused rename made it sleep 250 ms, about a third of its time. A handle with write or delete access, or delete-on-close, still blocks the rename. Local commit, not from iamfoz |
| ntdll | `WINE_SHORTEN_SLEEP=4000:50` | Turns a non-alertable sleep of exactly the first number of ms into one of the second. The client pauses 4 s between chunks when it reads its own large files "to lighten disk I/O" (61 pauses at the start of each backup pass, 42 per file it re-reads for the server). It already runs at idle I/O priority. Other sleep lengths are untouched. Local commit, not from iamfoz |
| wineserver | `WINE_SOCK_SNDBUF_AUTOTUNE=1` | Records the `SO_SNDBUF` a TCP socket asks for but does not pass it to the kernel, so Linux send-buffer autotuning stays on. The client asks for 64 KiB, which fixed each upload connection's buffer at 128 KiB: `ss` showed them sndbuf-limited about 90% of the time at about 5.5 Mbit/s over a 172 ms round trip. In a test the kernel buffer grew to 2.6 MB while `getsockopt` still returned 65536. Local commit, not from iamfoz |
| ntdll | `WINE_SPAWN_NOCOPY=1` | Starts each new Windows process with `clone(CLONE_VM | CLONE_VFORK)` twice instead of `fork()` twice, so the parent's page tables are not copied. The middle and new processes make only system calls until `execve()`, with every signal blocked while they share memory. The Backblaze client starts an upload process for every batch, about every 1.4 s, and with 11 GB swapped out each `fork()` cost it about 0.5 s, a third of its time. In a test with 2 GB touched in the parent, 20 spawns took 94 ms against 1,456 ms, with the same cwd, environment, stdout and exit codes. Local commit, not from iamfoz |
| ntdll | `WINE_MOUNTPOINTS_AS_DIRS=<letters>` or `1` | Shows mount points inside a drive as plain folders. Stock Wine reports them as reparse points, and Backblaze skips those |

The system Wine must be the release the branch is based on (`BASE` in `recipe.sh`), because the
build copies it and replaces only `wineserver` and the modules the branch changes.

To change it: commit on the branch, `git push fork backblaze/wine-11.20`,
`localbuild bump wine-backblaze <commit>`, build, commit the recipe, install.
