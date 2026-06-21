#!/usr/bin/env bash
# Build a .deb package using only dpkg-deb (no debhelper required).
set -euo pipefail

VERSION="${VERSION:-1.0.0}"
PKG=whatismyip
ARCH=all
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

PKGROOT="$WORKDIR/${PKG}_${VERSION}_${ARCH}"
install -d "$PKGROOT/DEBIAN" "$PKGROOT/usr/bin"
install -m 0755 "$SCRIPT_DIR/bin/whatismyip" "$PKGROOT/usr/bin/whatismyip"

cat > "$PKGROOT/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: net
Priority: optional
Architecture: $ARCH
Depends: bash, curl, iproute2
Maintainer: Arghya <contact@arghyadeep.in>
Description: Print your public and local IP address(es)
 whatismyip is a small CLI tool that prints your public IPv4/IPv6
 address and/or your local IPv4 address(es).
EOF

dpkg-deb --build --root-owner-group "$PKGROOT" "$SCRIPT_DIR/${PKG}_${VERSION}_${ARCH}.deb"
echo "Built ${PKG}_${VERSION}_${ARCH}.deb"
