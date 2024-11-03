# Essential Scripts

These scripts handle the minimal bootstrapping process before the full environment
is available. They should:

- Use minimal dependencies (basic shell commands only)
- Handle essential setup (SSH, GitHub, etc.)
- Be idempotent (safe to run multiple times)
- Not depend on tools/ directory or nix environment

## Scripts

- `bootstrap.sh`: Initial environment setup
- `setup_github.sh`: GitHub repository configuration

## Usage

```bash
# Initial setup
export GITHUB_TOKEN="your-token"
./scripts/bootstrap.sh

# Setup GitHub remote
./scripts/setup_github.sh
```
