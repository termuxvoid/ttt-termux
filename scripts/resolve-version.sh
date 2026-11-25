#!/usr/bin/env bash
set -eu

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
VERSION="${VERSION#v}"
[ -n "$VERSION" ] || { echo "VERSION is empty" >&2; exit 1; }
TAG="v$VERSION"

SHOULD_RELEASE=true
if [ -n "${GITHUB_REPOSITORY:-}" ] && command -v gh >/dev/null 2>&1; then
    if gh release view "$TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
        SHOULD_RELEASE=false
    fi
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
        echo "version=$VERSION"
        echo "tag=$TAG"
        echo "should_release=$SHOULD_RELEASE"
    } >> "$GITHUB_OUTPUT"
else
    printf 'version=%s\ntag=%s\nshould_release=%s\n' "$VERSION" "$TAG" "$SHOULD_RELEASE"
fi
