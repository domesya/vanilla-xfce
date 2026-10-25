set -euo pipefail
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

tmp="$(mktemp -d)"

_cleanup() {
    rm -rf "$tmp"
}

trap _cleanup INT TERM EXIT

CURL_RETRY=(--retry 5 --retry-all-errors --retry-delay 10)
CPAK_VERSION=$(curl -fsSLI "${CURL_RETRY[@]}" -o /dev/null -w '%{url_effective}' \
    https://github.com/Containerpak/cpak/releases/latest | sed 's#.*/releases/tag/##')
[ -n "${CPAK_VERSION}" ] || { echo "ERROR: could not find the latest cpak release"; exit 1; }
CPAK_BASE="https://github.com/Containerpak/cpak/releases/download/${CPAK_VERSION}"
curl -fsSL "${CURL_RETRY[@]}" -o "$tmp/cpak-linux-$arch" "${CPAK_BASE}/cpak-linux-$arch"
curl -fsSL "${CURL_RETRY[@]}" -o "$tmp/cpak-storaged-linux-$arch" "${CPAK_BASE}/cpak-storaged-linux-$arch"
curl -fsSL "${CURL_RETRY[@]}" -o "$tmp/cpak-SHA256SUMS" "${CPAK_BASE}/SHA256SUMS"

(
    cd "$tmp" && sha256sum -c --ignore-missing cpak-SHA256SUMS
)

install -Dm755 "$tmp/cpak-linux-$arch" /usr/bin/cpak
install -Dm755 "$tmp/cpak-storaged-linux-$arch" /usr/bin/cpak-storaged
