#\!/usr/bin/env bash
# Script to set up GPG key for GitHub commit signing
# Sets up dedicated GPG key for aygp-dr account

set -euo pipefail

GPG_KEY_ID="79B6CE1B71B45489"
GPG_KEY_EMAIL="computeruse@defrecord.com"
GPG_KEY_NAME="Aidan Pace"
GPG_KEY_PASSPHRASE="anthropic-computeruse"

# Create GPG key if it doesn't exist
if \! gpg --list-secret-keys --keyid-format=long | grep -q "${GPG_KEY_ID}"; then
    echo "Generating GPG key for ${GPG_KEY_NAME}..."
    cat > /tmp/gpg_input << GPGEOF
%echo Generating GPG key for ${GPG_KEY_NAME}
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ${GPG_KEY_NAME}
Name-Email: ${GPG_KEY_EMAIL}
Expire-Date: 0
Passphrase: ${GPG_KEY_PASSPHRASE}
%commit
%echo Done
GPGEOF

    gpg --batch --gen-key /tmp/gpg_input
    rm /tmp/gpg_input
else
    echo "GPG key already exists for ${GPG_KEY_NAME}"
fi

# Configure Git to use the GPG key
git config --global user.signingkey "${GPG_KEY_ID}"
git config --global commit.gpgsign true

# Export the public key
GPG_PUBLIC_KEY=$(gpg --armor --export "${GPG_KEY_ID}")

# Display the key info
echo
echo "===================================================================="
echo "GPG key configured for Git commit signing:"
echo "===================================================================="
echo "Key ID: ${GPG_KEY_ID}"
echo "Name: ${GPG_KEY_NAME}"
echo "Email: ${GPG_KEY_EMAIL}"
echo "Passphrase: ${GPG_KEY_PASSPHRASE} (store securely\!)"
echo "===================================================================="
echo

# Add to GitHub if gh CLI is available
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "Adding GPG key to GitHub account..."
        echo "${GPG_PUBLIC_KEY}" > /tmp/gpg_key.asc
        gh gpg-key add /tmp/gpg_key.asc || echo "Failed to add key to GitHub. Add manually."
        rm /tmp/gpg_key.asc
    else
        echo "GitHub CLI not authenticated. Please run 'gh auth login' first."
    fi
else
    echo "GitHub CLI not installed. To add this key to GitHub:"
    echo "1. Copy the public key below"
    echo "2. Go to GitHub → Settings → SSH and GPG keys → New GPG key"
    echo "3. Paste the key and save"
    echo
    echo "${GPG_PUBLIC_KEY}"
fi
