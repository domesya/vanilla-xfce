set -euo pipefail

WINTC_VERSION="5adad1c4f54003680e327e33a20690469423a1dd"
tmp="$(mktemp -d)"

case "${ARCH:-$(uname -a)}" in 
    amd64) arch=x86_64
        ;;
    aarch64) arch=aarch64
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

./packaging/chkdeps.sh | awk -F':' '!/libwintc/ { print $2 }' | xargs apt-get install -y

./packaging/buildall.sh

apt-get install -y ./xptc/*/deb/std/$arch/fre/*.deb 
