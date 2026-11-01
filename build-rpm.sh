#!/usr/bin/env bash
# Build a .rpm package locally from the current git tree (no GitHub release needed).
set -euo pipefail

VERSION="${VERSION:-1.0.0}"
PKG=whatismyip
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOPDIR="$(mktemp -d)"
trap 'rm -rf "$TOPDIR"' EXIT

mkdir -p "$TOPDIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

git -C "$SCRIPT_DIR" archive --prefix="${PKG}-${VERSION}/" -o "$TOPDIR/SOURCES/${PKG}-${VERSION}.tar.gz" HEAD

rpmbuild --define "_topdir $TOPDIR" --define "pkg_version $VERSION" -ba "$SCRIPT_DIR/${PKG}.spec"

find "$TOPDIR/RPMS" -name '*.rpm' -exec cp {} "$SCRIPT_DIR/" \;
echo "Built $(find "$SCRIPT_DIR" -maxdepth 1 -name "${PKG}-${VERSION}*.rpm")"
