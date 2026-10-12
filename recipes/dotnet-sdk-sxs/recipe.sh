# Microsoft's .NET SDK linux-x64 tarball, packaged as dotnet-sdk-<band>-sxs (for 10.0.401 that
# is dotnet-sdk-401-sxs). It installs only /usr/share/dotnet/sdk/<version>, next to the distro
# dotnet-sdk, and uses the host, runtime and targeting pack from the extra/dotnet-* packages.
#
# Move it with `localbuild bump dotnet-sdk-sxs <version>`: lb_pin_hash looks up the new
# checksum in Microsoft's release metadata.

UPSTREAM=https://dotnet.microsoft.com/download/dotnet
MODE=binary
KIND=pkg
PIN=10.0.401
SHA512=51c8b999af9e8dd9998c9edc5944e19a90788862068acd38694e098889054ce8c23d4f0c5cccfa16bf187d044562359e5ee69a9f8ad0bbe913ba90311fbce25b

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
    pacman -Q dotnet-runtime >/dev/null 2>&1 || warn "dotnet-sdk-sxs: extra/dotnet-runtime is not installed"
    pacman -Q "dotnet-sdk-${PIN##*.}-sxs" >/dev/null 2>&1 || warn "dotnet-sdk-sxs: dotnet-sdk-${PIN##*.}-sxs is not installed"
}
