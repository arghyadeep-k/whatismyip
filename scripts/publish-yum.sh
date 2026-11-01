#!/usr/bin/env bash
# Add .rpm files to a signed dnf/yum repository under REPO_DIR/rpm.
#
# Usage: GPG_KEY_ID=<id> scripts/publish-yum.sh REPO_DIR pkg1.rpm [pkg2.rpm ...]
#
# Optional env:
#   GPG_PASSPHRASE  passphrase for the signing key (omit if the key has none)
set -euo pipefail

: "${GPG_KEY_ID:?GPG_KEY_ID must be set}"
[ $# -ge 2 ] || { echo "usage: $0 REPO_DIR file.rpm..." >&2; exit 1; }
REPO_DIR="$(cd "$1" && pwd)"; shift
RPMS=()
for f in "$@"; do RPMS+=("$(realpath "$f")"); done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Build the gpg invocation used both for rpm signing and repomd signing.
GPG_EXTRA=()
RPMSIGN_DEFS=(--define "_gpg_name $GPG_KEY_ID")
if [ -n "${GPG_PASSPHRASE:-}" ]; then
  printf '%s' "$GPG_PASSPHRASE" > "$TMP/pass"
  chmod 600 "$TMP/pass"
  GPG_EXTRA=(--pinentry-mode loopback --passphrase-file "$TMP/pass")
  RPMSIGN_DEFS+=(--define "__gpg_sign_cmd %{__gpg} gpg --batch --no-verbose --no-armor --pinentry-mode loopback --passphrase-file $TMP/pass --no-secmem-warning -u \"%{_gpg_name}\" -sbo %{__signature_filename} %{__plaintext_filename}")
fi

mkdir -p "$REPO_DIR/rpm"
cp -f "${RPMS[@]}" "$REPO_DIR/rpm/"

# Sign every package (idempotent: re-signing an already-signed rpm is fine).
for f in "$REPO_DIR"/rpm/*.rpm; do
  rpmsign "${RPMSIGN_DEFS[@]}" --addsign "$f"
done

createrepo_c --update "$REPO_DIR/rpm"

rm -f "$REPO_DIR/rpm/repodata/repomd.xml.asc"
gpg --batch --yes --default-key "$GPG_KEY_ID" "${GPG_EXTRA[@]}" \
  --armor --detach-sign -o "$REPO_DIR/rpm/repodata/repomd.xml.asc" \
  "$REPO_DIR/rpm/repodata/repomd.xml"

# Armored public key for gpgkey= in the .repo file.
gpg --batch --yes --armor --export "$GPG_KEY_ID" > "$REPO_DIR/KEY.asc"
touch "$REPO_DIR/.nojekyll"
echo "Published: $(ls "$REPO_DIR"/rpm/*.rpm | wc -l) rpm file(s) in $REPO_DIR/rpm"
