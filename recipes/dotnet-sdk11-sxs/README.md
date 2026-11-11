# .NET 11 SDK and runtimes from Microsoft's tarball, installed beside the distro SDK as dotnet-sdk11-<patch>-sxs

The company monorepo moved its `global.json` to SDK 11.0.100 on 2026-11-11, and extra has no
.NET 11 packages yet. This recipe packages Microsoft's linux-x64 SDK tarball. Unlike
`dotnet-sdk-sxs`, it also ships the runtimes the SDK needs (`shared/Microsoft.NETCore.App` and
`shared/Microsoft.AspNetCore.App` 11.0.x), the targeting and apphost packs, the workload
manifests and the templates. Each sits in its own version folder, so nothing owned by extra's
`dotnet-*` packages is overwritten.

It leaves out `host/fxr` and the `dotnet` muxer. extra's `dotnet-host` (10.0.x) runs the 11.0 SDK:
hostfxr reads `global.json`, finds `sdk/11.0.100` and starts it on the 11.0 runtime. Checkouts
that pin a 10.0 SDK keep resolving it, because `rollForward: patch` stays in its feature band.

There is no clone and there are no patches. The tarball is pinned by SHA512 in `recipe.sh`.

## Moving to a new SDK release

```sh
localbuild bump dotnet-sdk11-sxs 11.0.101   # sets PIN and looks up SHA512 from Microsoft
localbuild build dotnet-sdk11-sxs
localbuild install dotnet-sdk11-sxs
dotnet --list-sdks
```

The package name carries the patch number (`dotnet-sdk11-100-sxs`), so a new SDK installs beside
the old one. Remove the old one once nothing pins it. Commit the recipe before `install`.

When extra ships .NET 11, check for file conflicts with its runtime packages before upgrading.
