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
| wineserver | `WINE_SERVICE_TOKEN=1` | Gives services the LocalSystem group and an enabled SeDebugPrivilege. Backblaze 10.0.3 and later need it, or every backup pass loses its four-hour lock |
| wineserver | `WINE_OFD_LOCKS=1` | Uses open file description locks, so wineserver can close a file the client closed. Without it the client leaks descriptors |
| ntdll | `WINE_CASE_CACHE=1` | Decides once per device whether names are case sensitive, instead of after every failed lookup. Speeds up scans |
| ntdll, kernelbase | `WINE_MOUNTMGR_CACHE=1` | Keeps the mountmgr's drive answer per Unix device, and the drive type per drive letter, for 30 s, failures included. Backblaze's scanner calls `GetFileInformationByHandle` and `GetDriveTypeW` (with the file's full path) for every file, and each call cost five or more server round trips plus a signal, because the mountmgr answers from another process. That held the scanner to about 480 files/s. A benchmark that opens each file and calls both went from about 6,000 to about 19,000 files/s. Local commits, not from iamfoz. Two drive letters on one Unix device share the cached answer |
| ntdll | `WINE_HEAP_BIN_SKIP=1` | Makes the heap look at no more than 8 blocks of a request's own free list before it moves to the next list, where every block fits. Stock Wine walks the whole list, so a list full of blocks just below the request size costs a full walk on every allocation. bztransmit spent about 75% of its CPU there while it read its 37 GB upload history, at about 1 MB/s. A test with 10,000 such blocks went from 218 to 1.5 µs per allocation. Read from the Windows environment, so a service needs it in the registry too. Local commit, not from iamfoz |
| ntdll | `WINE_MOUNTPOINTS_AS_DIRS=<letters>` or `1` | Shows mount points inside a drive as plain folders. Stock Wine reports them as reparse points, and Backblaze skips those |

The system Wine must be the release the branch is based on (`BASE` in `recipe.sh`), because the
build copies it and replaces only `wineserver` and the modules the branch changes.

To change it: commit on the branch, `git push fork backblaze/wine-11.20`,
`localbuild bump wine-backblaze <commit>`, build, commit the recipe, install.
