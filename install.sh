#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing certificates and pip configuration..."

# Install certificates
CERT_DIR="$SCRIPT_DIR/certs"
if [ -d "$CERT_DIR" ] && [ "$(ls -A "$CERT_DIR"/*.crt 2>/dev/null || ls -A "$CERT_DIR"/*.cert 2>/dev/null)" ]; then
    echo "==> Installing certificates to /usr/local/share/ca-certificates/"
    sudo cp "$CERT_DIR"/*.crt /usr/local/share/ca-certificates/ 2>/dev/null || true
    sudo cp "$CERT_DIR"/*.cert /usr/local/share/ca-certificates/ 2>/dev/null || true
    sudo update-ca-certificates
    echo "    Certificates installed successfully"
else
    echo "    No .crt or .cert files found in $CERT_DIR, skipping..."
fi

# Install pip.conf
PIP_CONF="$SCRIPT_DIR/pip.conf"
if [ -f "$PIP_CONF" ]; then
    echo "==> Installing pip.conf to ~/.config/pip/"
    mkdir -p ~/.config/pip
    cp "$PIP_CONF" ~/.config/pip/pip.conf
    echo "    pip.conf installed successfully"
else
    echo "    pip.conf not found, skipping..."
fi

echo "==> Setup complete!"
