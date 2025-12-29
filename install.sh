#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing certificates and pip/uv configuration..."

# Function to get latest version from Maven metadata
get_maven_latest_version() {
    local repo_url="$1"
    local group_path="$2"
    local artifact_id="$3"
    
    local metadata_url="${repo_url}/${group_path}/${artifact_id}/maven-metadata.xml"
    local metadata
    metadata=$(curl -fsSL "$metadata_url" 2>/dev/null) || return 1
    
    # Try <release> first, then <latest>, then last <version>
    local version
    version=$(echo "$metadata" | grep -oP '(?<=<release>)[^<]+' | head -1)
    if [ -z "$version" ]; then
        version=$(echo "$metadata" | grep -oP '(?<=<latest>)[^<]+' | head -1)
    fi
    if [ -z "$version" ]; then
        version=$(echo "$metadata" | grep -oP '(?<=<version>)[^<]+' | tail -1)
    fi
    echo "$version"
}

# Function to download cert from Maven
download_maven_cert() {
    local repo_url="$1"
    local group_id="$2"
    local artifact_id="$3"
    local extension="$4"
    
    local group_path="${group_id//./\/}"
    local version
    version=$(get_maven_latest_version "$repo_url" "$group_path" "$artifact_id")
    
    if [ -z "$version" ]; then
        echo "    Warning: Could not determine latest version for $group_id:$artifact_id"
        return 1
    fi
    
    local artifact_url="${repo_url}/${group_path}/${artifact_id}/${version}/${artifact_id}-${version}.${extension}"
    local filename="${artifact_id}-${version}.${extension}"
    
    echo "    Downloading: $filename (version $version)"
    if curl -fsSL "$artifact_url" -o "/tmp/$filename"; then
        sudo cp "/tmp/$filename" /usr/local/share/ca-certificates/
        return 0
    else
        echo "    Warning: Failed to download $artifact_url"
        return 1
    fi
}

# Download and install certificates
CERT_LIST="$SCRIPT_DIR/certs.txt"
if [ -f "$CERT_LIST" ]; then
    echo "==> Downloading certificates from certs.txt..."
    CERT_COUNT=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        if [[ "$line" == maven\|* ]]; then
            # Maven artifact: maven|repo-url|group-id|artifact-id|extension
            IFS='|' read -r _ repo_url group_id artifact_id extension <<< "$line"
            if download_maven_cert "$repo_url" "$group_id" "$artifact_id" "$extension"; then
                ((CERT_COUNT++)) || true
            fi
        else
            # Direct URL
            filename=$(basename "$line")
            echo "    Downloading: $filename"
            if curl -fsSL "$line" -o "/tmp/$filename"; then
                sudo cp "/tmp/$filename" /usr/local/share/ca-certificates/
                ((CERT_COUNT++)) || true
            else
                echo "    Warning: Failed to download $line"
            fi
        fi
    done < "$CERT_LIST"
    
    if [ "$CERT_COUNT" -gt 0 ]; then
        sudo update-ca-certificates
        echo "    Installed $CERT_COUNT certificate(s) successfully"
    else
        echo "    No certificates downloaded"
    fi
else
    echo "    certs.txt not found, skipping certificate installation..."
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

# Install uv.toml
UV_TOML="$SCRIPT_DIR/uv.toml"
if [ -f "$UV_TOML" ]; then
    echo "==> Installing uv.toml to ~/.config/uv/"
    mkdir -p ~/.config/uv
    cp "$UV_TOML" ~/.config/uv/uv.toml
    echo "    uv.toml installed successfully"
else
    echo "    uv.toml not found, skipping..."
fi

echo "==> Setup complete!"
