# Microsoft's .NET 11 SDK linux-x64 tarball, packaged as dotnet-sdk11-<patch>-sxs (for 11.0.100
# that is dotnet-sdk11-100-sxs). Extra has no .NET 11 yet, so the package carries the SDK and its
# own 11.0 runtimes, targeting packs, workload manifests and templates, beside the distro 10.0
# files. It leaves host/fxr and the dotnet muxer to extra's dotnet-host.
#
# Move it with `localbuild bump dotnet-sdk11-sxs <version>`: lb_pin_hash looks up the new
# checksum in Microsoft's release metadata.

UPSTREAM=https://dotnet.microsoft.com/download/dotnet
MODE=binary
KIND=pkg
PIN=11.0.100
SHA512=1bec9cca2ec689b1e80245b84f2b53c9441d1aa6daccf2ceb27490768bffa95954fa585bd275def31069d874d543d9ba9e6591fe9ade2dbd9f34ec5c0fd0050c

lb_pin_hash() {
    local channel=${1%.*}
    curl -fsSL "https://builds.dotnet.microsoft.com/dotnet/release-metadata/$channel/releases.json" |
        python3 -I -c '
import json, sys
want = sys.argv[1]
for r in json.load(sys.stdin)["releases"]:
    for s in r.get("sdks") or [r["sdk"]]:
        if s["version"] == want:
            for f in s["files"]:
                if f["name"] == "dotnet-sdk-linux-x64.tar.gz":
                    print(f["hash"].lower())
                    sys.exit()
' "$1"
}

lb_check() {
    pacman -Q dotnet-host >/dev/null 2>&1 || warn "dotnet-sdk11-sxs: extra/dotnet-host is not installed"
    pacman -Q "dotnet-sdk11-${PIN##*.}-sxs" >/dev/null 2>&1 || warn "dotnet-sdk11-sxs: dotnet-sdk11-${PIN##*.}-sxs is not installed"
}
