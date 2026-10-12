# .NET SDK from Microsoft's tarball, installed beside the distro SDK as dotnet-sdk-<band>-sxs

The company monorepo pins its SDK in `global.json` (10.0.401 at the time of writing), and
extra only ships the 10.0.1xx band. This recipe packages Microsoft's linux-x64 SDK tarball.
The package holds only `/usr/share/dotnet/sdk/<version>`, so it does not touch any file owned
by extra's `dotnet-host`, `dotnet-runtime`, `dotnet-targeting-pack` or `dotnet-sdk`. It
depends on those for the host and the 10.0 runtime.

There is no clone and there are no patches. The tarball is pinned by SHA512 in `recipe.sh`.

## Moving to a new SDK release

```sh
localbuild bump dotnet-sdk-sxs 10.0.402   # sets PIN and looks up SHA512 from Microsoft
localbuild build dotnet-sdk-sxs
localbuild install dotnet-sdk-sxs
dotnet --list-sdks
```

The package name carries the feature band and patch number (`dotnet-sdk-402-sxs`), so the new
SDK installs beside the old one. Remove the old one with `sudo pacman -R dotnet-sdk-401-sxs`
once nothing pins it. Commit the recipe before `install`.

An SDK needs a runtime of its own band or newer. If the new SDK needs a runtime newer than
extra has, wait for extra or package the runtime too.
