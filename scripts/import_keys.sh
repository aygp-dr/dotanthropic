#\!/usr/bin/env bash
# Script to import public GPG keys for collaborators
# Imports keys from GitHub for secure file sharing

set -euo pipefail

# List of GitHub users whose keys we want to import
GITHUB_USERS=(
  "jwalsh"
)

# Import keys
import_keys() {
  for user in "${GITHUB_USERS[@]}"; do
    echo "Importing GPG key for GitHub user: ${user}"
    # Use gh CLI to fetch the key since it's authenticated
    gh api "https://github.com/${user}.gpg" > "/tmp/${user}.gpg"
    gpg --import "/tmp/${user}.gpg"
    rm "/tmp/${user}.gpg"
    
    # Trust the key (ultimately)
    local key_ids=($(gpg --list-keys --with-colons "${user}" | grep "^pub" | cut -d: -f5))
    for key_id in "${key_ids[@]}"; do
      echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key "${key_id}" trust
    done
  done
}

# Check dependencies
if \! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is required but not installed."
  exit 1
fi

# Import keys
import_keys

# List imported keys
echo
echo "=== Imported GPG Keys ==="
gpg --list-keys

# Example encryption command
echo
echo "To encrypt a file for all collaborators:"
echo "gpg --encrypt --sign --armor -r computeruse@defrecord.com -r j@wal.sh -o file.gpg file.txt"
