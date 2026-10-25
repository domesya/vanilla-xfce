set -euo pipefail

WINTC_VERSION="5adad1c4f54003680e327e33a20690469423a1dd"
tmp="$(mktemp -d)"

case "${ARCH:-$(uname -m)}" in 
    amd64|x86_64) arch=x86_64;
        ;;
    aarch64|arm64) arch=aarch64;
        ;;
    *) >&2 echo "wintc-install: unsupported architecture: ${ARCH:-$(uname -m)}"; exit 1; 
        ;; 
esac

_cleanup() {
    rm -rf "$tmp"
}

trap _cleanup INT TERM EXIT

cd "$tmp"
git clone "https://github.com/rozniak/xfce-winxp-tc" ./xfce-winxp-tc
cd ./xfce-winxp-tc
git checkout "$WINTC_VERSION"

apt-get update

chkdeps_status=0
chkdeps_out="$(./packaging/chkdeps.sh)" || chkdeps_status=$?

# if [[ $chkdeps_status -gt 2 ]]; then
if [[ $chkdeps_status -ne 0 && $chkdeps_status -ne 2 ]]; then
    echo "wintc-install: chkdeps failed (status $chkdeps_status)" >&2
    exit 1
fi

raw_deps="$( echo "$chkdeps_out" | awk -F':' '!/libwintc/ { print $2 }' | tr '\n' ' ' )"
#raw_deps="$(echo "$chkdeps_out" | cut -d':' -f2 | tr '\n' ' ')"

if [[ -n "$raw_deps" ]]; then
    apt-get install -y $raw_deps
fi

./packaging/buildall.sh

apt-get install -y ./xptc/*/deb/std/$arch/fre/*.deb 
