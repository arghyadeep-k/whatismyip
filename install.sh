#!/usr/bin/env bash
# Installs whatismyip to /usr/local/bin (or PREFIX/bin if PREFIX is set).
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -d "$PREFIX/bin"
install -m 0755 "$SCRIPT_DIR/bin/whatismyip" "$PREFIX/bin/whatismyip"

echo "Installed whatismyip to $PREFIX/bin/whatismyip"
