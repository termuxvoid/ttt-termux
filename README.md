<p align="center">
  <h1 align="center">TTT for Termux</h1>
  <p align="center">
    <strong>Terminal Text Tool, built from source for every Termux architecture.</strong><br>
    Maintained by <a href="https://github.com/termuxvoid">TermuxVoid</a>.
  </p>
</p>

---

## Overview

[TTT](https://github.com/eugenioenko/ttt) (Terminal Text Tool) is a terminal-based code editor: a TUI with syntax highlighting for 124 languages, multi-cursor editing, file explorer, workspace search, Git integration, an integrated terminal, LSP support, themes, and Lua plugins — all in a single Go binary with zero config.

This repository builds TTT from the official upstream source and publishes ready-to-run archives for **all four Termux architectures**.

## Why this repository exists

The upstream project only publishes an **Android `aarch64`** binary for Termux (and its installer rejects every other Android ABI). Termux also runs on 32-bit ARM, x86_64, and i686, so those users have no official binary.

This repository fills that gap:

- Builds the exact upstream release tag from source in GitHub Actions.
- Targets **aarch64, arm, x86_64, and i686** with the Android NDK.
- Produces Android PIE binaries linked against bionic (Android 7.0 / API 24 or newer).
- Publishes a GitHub release plus a checksum file for download verification.

## Supported architectures

| Termux `uname -m` | Go target | Release asset |
| --- | --- | --- |
| `aarch64` | `android/arm64` | `ttt-<version>-aarch64.tar.gz` |
| `armv7l`, `armv8l` | `android/arm` (`GOARM=7`) | `ttt-<version>-arm.tar.gz` |
| `x86_64` | `android/amd64` | `ttt-<version>-x86_64.tar.gz` |
| `i686` | `android/386` (`GO386=sse2`) | `ttt-<version>-i686.tar.gz` |

## Requirements

- Termux installed from [F-Droid](https://f-droid.org/packages/com.termux/) or the [GitHub releases](https://github.com/termux/termux-app/releases) — not the Play Store build.
- Android 7.0 or newer.
- Optional: `git` for source control features, `ripgrep` for workspace search.

## Installation

### TermuxVoid repository (recommended)

Add the TermuxVoid APT repository once:

```bash
curl -fsSL https://github.com/termuxvoid/repo/raw/main/install.sh | bash
```

Then install TTT:

```bash
pkg update
pkg install ttt
```

Once TTT 1.13.0 is published to the TermuxVoid package catalog, this is the recommended path: updates arrive through `pkg upgrade`, and the package selects the archive matching your device architecture.

> The TermuxVoid package downloads the matching release archive and verifies it against `SHA256SUMS`. If `pkg install ttt` cannot find the package yet, use the direct release method below.

### Direct from GitHub releases

Install the latest TTT build without the package repository:

```bash
VERSION=1.13.0
case "$(uname -m)" in
  aarch64) ARCH=aarch64 ;;
  armv7l|armv8l|arm) ARCH=arm ;;
  x86_64) ARCH=x86_64 ;;
  i686|i386) ARCH=i686 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

BASE="https://github.com/termuxvoid/termux-ttt/releases/download/v${VERSION}"
TGZ="ttt-${VERSION}-${ARCH}.tar.gz"

curl -fsSLO "$BASE/$TGZ"
curl -fsSLO "$BASE/SHA256SUMS"
grep -F "  $TGZ" SHA256SUMS | sha256sum -c -

tar -xzf "$TGZ"
install -Dm755 ttt "$PREFIX/bin/ttt"

ttt --version
```

Each archive contains the `ttt` binary and the upstream `LICENSE`.

## Usage

```bash
ttt                    # open the editor
ttt path/to/file       # open a file
ttt path/to/project    # open a folder
```

Run `ttt --help` for CLI flags, or see the [upstream documentation](https://github.com/eugenioenko/ttt#readme) for keybindings, configuration, LSP setup, and plugins.

## Build from source

The GitHub release workflow builds every archive with [`scripts/build.sh`](scripts/build.sh). The same script works on any Linux host with Go 1.25+, an Android NDK, `curl`, and `tar`:

```bash
VERSION=1.13.0 \
TERMUX=aarch64 \
GOARCH=arm64 \
TRIPLE=aarch64-linux-android \
scripts/build.sh
```

The script:

1. Downloads `https://github.com/eugenioenko/ttt/archive/refs/tags/v$VERSION.tar.gz`.
2. Builds `./cmd/ttt` with `CGO_ENABLED=1`, `GOOS=android`, the matching `GOARCH`, and NDK clang.
3. Packages `ttt` + `LICENSE` into `dist/ttt-$VERSION-$TERMUX.tar.gz` and writes a per-architecture checksum.

Environment variables: `TERMUX` (aarch64/arm/x86_64/i686), `GOARCH`, `TRIPLE`, optional `GOARM`, `GO386`, `ANDROID_NDK_LATEST_HOME` or `ANDROID_HOME`, `OUTDIR`, and `WORKDIR`.

## Release process

1. Edit [`VERSION`](VERSION) to the upstream tag **without** the leading `v` (for example `1.13.0`).
2. Commit and push to `main`.

The [release workflow](.github/workflows/release.yml) then:

- Reads `VERSION` via [`scripts/resolve-version.sh`](scripts/resolve-version.sh).
- Uses tag `v<version>` and skips the build if that release already exists.
- Builds all four Termux architectures in parallel.
- Publishes `ttt-<version>-<arch>.tar.gz` and a merged `SHA256SUMS`.

Use **Actions → Release → Run workflow** to rebuild manually. To rebuild an existing version, delete its release and tag first.

## Acknowledgments

- **[eugenioenko/ttt](https://github.com/eugenioenko/ttt)** — the original TTT editor, created by Eugene Yakhnenko. All editor code and design belong to the upstream project.
- **TermuxVoid** — build automation, Android/Termux packaging, and release hosting.
- The Go, Android NDK, and Termux communities whose toolchains make these builds possible.

## License

TTT is licensed under the MIT License. The original license is included in this repository at [`LICENSE`](LICENSE) and inside every release archive. See the [upstream license](https://github.com/eugenioenko/ttt/blob/main/LICENSE).

## Disclaimer

This is an unofficial community build, not affiliated with or endorsed by the TTT maintainers. Report build, packaging, or architecture issues here; report editor bugs and feature requests to [upstream](https://github.com/eugenioenko/ttt/issues).
