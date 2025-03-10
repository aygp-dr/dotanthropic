#\!/usr/bin/env bash
# Simple key import script using wget
# No dependencies on GitHub CLI or other tools

set -euo pipefail

# Create a safe temporary directory
SAFE_TMP="${HOME}/.tmp/gpg_keys"
mkdir -p "${SAFE_TMP}"
chmod 700 "${SAFE_TMP}"

# List of GitHub users to import
COLLABORATORS=(
  "aygp-dr"
  "jwalsh"
)

# Import keys from GitHub
for user in "${COLLABORATORS[@]}"; do
  echo "Importing key for ${user}..."
  
  # Download key if not exists
  if [ \! -f "${SAFE_TMP}/${user}.gpg" ]; then
    wget -q "https://github.com/${user}.gpg" -O "${SAFE_TMP}/${user}.gpg"
    echo "✓ Downloaded key for ${user}"
  else
    echo "✓ Using cached key for ${user}"
  fi
  
  # Import to GPG
  gpg --import "${SAFE_TMP}/${user}.gpg"
  
  # Trust the key
  fingerprints=$(gpg --list-keys --with-colons "${user}" | grep "^fpr" | cut -d: -f10)
  for fpr in $fingerprints; do
    echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key "$fpr" trust
  done
  
  echo "✓ Successfully imported and trusted keys for ${user}"
  echo
done

# List all keys
echo "=== Imported Keys ==="
gpg --list-keys

echo
echo "🎉 All keys imported successfully\! 🎉"
echo "You can now encrypt files for your collaborators."
echo

# Encryption examples
echo "Example usage:"
echo "  Encrypt for aygp-dr: gpg --encrypt --armor -r computeruse@defrecord.com -o file.gpg file.txt"
echo "  Encrypt for jwalsh:  gpg --encrypt --armor -r j@wal.sh -o file.gpg file.txt"
echo "  Encrypt for both:    gpg --encrypt --armor -r computeruse@defrecord.com -r j@wal.sh -o file.gpg file.txt"
