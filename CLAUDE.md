# Commands and Guidelines for dotanthropic

## Build/Development Commands
- Initial configuration: `gmake configure` (detects and configures make/gmake preference)
- Enter dev environment: `gmake nix-shell` 
- Build environment: `gmake nix-build`
- Bootstrap setup: `gmake bootstrap`
- Clean environment: `gmake clean` or `gmake nix-clean`
- Check environment: `gmake check-env`
- Generate changelog: `gmake changelog`
- Generate and commit changelog: `gmake changelog-commit`
- Lint code: `gmake lint`
- Run Computer Use container: `ANTHROPIC_KEY=your_key GITHUB_TOKEN=your_token gmake run-container`
- SSH key setup: `gmake setup-ssh`
- GPG key setup: `gmake setup-gpg`
- Import collaborator keys: `gmake import-keys`

### Make vs GMake
- FreeBSD users should prefer using `gmake` 
- The configuration script will detect the best make command
- Check detected make with: `gmake make-detect`
- Note: Regular `make` command does not work properly with this Makefile

## Code Style Guidelines

### Git Configuration
- Default identity: `Aidan Pace <computeruse@defrecord.com>`
- Use dedicated SSH keys: Run `gmake setup-ssh` to configure
- Remote format: `git@github.com-aygp-dr:aygp-dr/REPO.git`
- GPG key ID: `79B6CE1B71B45489` (for signed commits)
- Collaborator keys: Run `gmake import-keys` to import public keys for encryption

### Commit Format
- Follow conventional commits: `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, test, chore
- Example: `feat(setup): add support for poetry initialization`
- Commits are signed with GPG by default
- To disable GPG signing for a commit: `git commit --no-gpg-sign -m "message"`
- Commit command example: `git commit -m "feat(docker): add container run script"`

### Python
- Use Python 3.11+ with type annotations
- Follow PEP 8 style guide
- Use Poetry for dependency management

### Bash
- Use shellcheck for linting
- Include `set -euo pipefail` in scripts
- Wrap variables in quotes: `"${variable}"`
- Include descriptive function headers

### Error Handling
- Use proper error codes and exit statuses
- Implement logging for operations
- Create idempotent operations when possible

### Naming Conventions
- Use snake_case for variables and functions
- Use kebab-case for file names
- Prefer descriptive names over abbreviations