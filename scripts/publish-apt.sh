#!/usr/bin/env bash
# Add .deb files to a signed apt repository laid out under REPO_DIR.
#
# Usage: GPG_KEY_ID=<id> scripts/publish-apt.sh REPO_DIR pkg1.deb [pkg2.deb ...]
#
# Optional env:
#   GPG_PASSPHRASE  passphrase for the signing key (omit if the key has none)
#   SUITE           apt suite/codename (default: stable)
#   COMPONENT       apt component (default: main)
set -euo pipefail

: "${GPG_KEY_ID:?GPG_KEY_ID must be set}"
SUITE="${SUITE:-stable}"
COMPONENT="${COMPONENT:-main}"

[ $# -ge 2 ] || { echo "usage: $0 REPO_DIR file.deb..." >&2; exit 1; }
REPO_DIR="$(cd "$1" && pwd)"; shift
DEBS=()
for f in "$@"; do DEBS+=("$(realpath "$f")"); done

gpg_sign() {
  local args=(--batch --yes --default-key "$GPG_KEY_ID")
  if [ -n "${GPG_PASSPHRASE:-}" ]; then
    args+=(--pinentry-mode loopback --passphrase "$GPG_PASSPHRASE")
  fi
  gpg "${args[@]}" "$@"
}

cd "$REPO_DIR"
mkdir -p "pool/$COMPONENT"
cp -f "${DEBS[@]}" "pool/$COMPONENT/"

# Architecture: all packages are listed under binary-all; apt on any
# architecture also reads binary-all via the Architecture: all entries,
# but amd64/arm64 index files must exist or apt prints warnings.
for arch in all amd64 arm64; do
  d="dists/$SUITE/$COMPONENT/binary-$arch"
  mkdir -p "$d"
  dpkg-scanpackages --multiversion --arch "$arch" pool/ > "$d/Packages" 2>/dev/null
  gzip -9kf "$d/Packages"
done

apt-ftparchive \
  -o "APT::FTPArchive::Release::Origin=whatismyip" \
  -o "APT::FTPArchive::Release::Label=whatismyip" \
  -o "APT::FTPArchive::Release::Suite=$SUITE" \
  -o "APT::FTPArchive::Release::Codename=$SUITE" \
  -o "APT::FTPArchive::Release::Components=$COMPONENT" \
  -o "APT::FTPArchive::Release::Architectures=all amd64 arm64" \
  release "dists/$SUITE" > "dists/$SUITE/Release.new"
mv "dists/$SUITE/Release.new" "dists/$SUITE/Release"

rm -f "dists/$SUITE/Release.gpg" "dists/$SUITE/InRelease"
gpg_sign --armor --detach-sign -o "dists/$SUITE/Release.gpg" "dists/$SUITE/Release"
gpg_sign --clearsign -o "dists/$SUITE/InRelease" "dists/$SUITE/Release"

# Public key for users to download (binary keyring format for signed-by=).
gpg --batch --yes --export "$GPG_KEY_ID" > KEY.gpg

# Stop GitHub Pages from running Jekyll over the repo.
touch .nojekyll
echo "Published: $(ls "pool/$COMPONENT" | wc -l) package file(s) in $REPO_DIR"
