#!/usr/bin/env bash
# Script to set up SSH keys for GitHub with multiple accounts
# Sets up dedicated SSH key for aygp-dr account

set -euo pipefail

SSH_DIR="${HOME}/.ssh"
ATHENAEUM_DIR="${SSH_DIR}/athenaeum"
CONFIG_DIR="${SSH_DIR}/config.d"
KEY_NAME="aygp-dr"
KEY_EMAIL="computeruse@defrecord.com"

# Create directories if they don't exist
mkdir -p "${ATHENAEUM_DIR}" "${CONFIG_DIR}"

# Create SSH key if it doesn't exist
if [ ! -f "${ATHENAEUM_DIR}/${KEY_NAME}" ]; then
    echo "Generating SSH key for ${KEY_NAME}..."
    ssh-keygen -t ed25519 -C "${KEY_EMAIL}" -f "${ATHENAEUM_DIR}/${KEY_NAME}" -N ""
    chmod 600 "${ATHENAEUM_DIR}/${KEY_NAME}"
else
    echo "SSH key already exists at ${ATHENAEUM_DIR}/${KEY_NAME}"
fi

# Create SSH config for GitHub
cat > "${CONFIG_DIR}/github.conf" << CONF
Host github.com-${KEY_NAME}
  HostName github.com
  User git
  IdentityFile ${ATHENAEUM_DIR}/${KEY_NAME}
  IdentitiesOnly yes

Host ssh.github.com-${KEY_NAME}
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ${ATHENAEUM_DIR}/${KEY_NAME}
  IdentitiesOnly yes
CONF

chmod 600 "${CONFIG_DIR}/github.conf"

# Add Include directive to main SSH config if not already present
if [ ! -f "${SSH_DIR}/config" ] || ! grep -q "Include ${CONFIG_DIR}/*.conf" "${SSH_DIR}/config"; then
    echo "Updating SSH config..."
    echo "Include ${CONFIG_DIR}/*.conf" > "${SSH_DIR}/config.new"
    if [ -f "${SSH_DIR}/config" ]; then
        cat "${SSH_DIR}/config" >> "${SSH_DIR}/config.new"
    fi
    mv "${SSH_DIR}/config.new" "${SSH_DIR}/config"
    chmod 600 "${SSH_DIR}/config"
fi

# Show the public key to be added to GitHub
echo
echo "=============================================================="
echo "Add this SSH public key to GitHub account (aygp-dr):"
echo "=============================================================="
cat "${ATHENAEUM_DIR}/${KEY_NAME}.pub"
echo "=============================================================="
echo
echo "To test the connection, run: ssh -T git@github.com-${KEY_NAME}"
echo "To use with repositories: git remote set-url origin git@github.com-${KEY_NAME}:aygp-dr/repo.git"
