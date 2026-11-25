#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:?VERSION is required}"
VERSION="${VERSION#v}"
TERMUX="${TERMUX:?TERMUX (Termux arch) is required}"
GOARCH="${GOARCH:?GOARCH is required}"
TRIPLE="${TRIPLE:?TRIPLE is required}"
UPSTREAM="${UPSTREAM:-eugenioenko/ttt}"
WORKDIR="${WORKDIR:-${RUNNER_TEMP:-/tmp}/ttt-build}"
OUTDIR="${OUTDIR:-$ROOT/dist}"
TAG="v$VERSION"

NDK="${ANDROID_NDK_LATEST_HOME:-}"
if [ -z "$NDK" ]; then
    NDK="$(ls -d "${ANDROID_HOME:-/usr/local/lib/android/sdk}"/ndk/* 2>/dev/null | tail -n 1)" || true
fi
[ -n "$NDK" ] && [ -d "$NDK" ] || { echo "Android NDK not found" >&2; exit 1; }
export CC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${TRIPLE}24-clang"
[ -x "$CC" ] || { echo "NDK compiler not found: $CC" >&2; exit 1; }

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR" "$OUTDIR"
OUTDIR="$(cd "$OUTDIR" && pwd)"

curl -fsSL "https://github.com/$UPSTREAM/archive/refs/tags/${TAG}.tar.gz" \
    | tar -xz --strip-components=1 -C "$WORKDIR"

cd "$WORKDIR"
export CGO_ENABLED=1 GOOS=android GOARCH
[ -n "${GOARM:-}" ] && export GOARM
[ -n "${GO386:-}" ] && export GO386

go build -trimpath -ldflags "-s -w -X main.version=$TAG" -o "$WORKDIR/ttt" ./cmd/ttt

NAME="ttt-${VERSION}-${TERMUX}"
tar -czf "$OUTDIR/$NAME.tar.gz" -C "$WORKDIR" ttt LICENSE
(cd "$OUTDIR" && sha256sum "$NAME.tar.gz") > "$OUTDIR/sha256sums.${TERMUX}"
echo "Built $OUTDIR/$NAME.tar.gz"
