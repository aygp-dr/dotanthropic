#\!/usr/bin/env bash
# Script to check Docker installation and port availability
# Used as a prerequisite check before running the Computer Use container

set -euo pipefail

# Default port to check
PORT="${1:-8000}"
DOCKER_IMAGE="anthropics/computer-use-quickstart"

# Check Docker installation
check_docker() {
  echo "Checking Docker installation..."
  
  if command -v docker &> /dev/null; then
    echo "✓ Docker is installed"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
      echo "✓ Docker daemon is running"
      return 0
    else
      echo "✗ Docker daemon is not running"
      echo "  Please start Docker daemon with:"
      echo "  • Linux: sudo systemctl start docker"
      echo "  • macOS: open Docker Desktop application"
      return 1
    fi
  else
    echo "✗ Docker is not installed"
    echo "  Please install Docker:"
    echo "  • Linux: https://docs.docker.com/engine/install/"
    echo "  • macOS: https://docs.docker.com/desktop/install/mac/"
    echo "  • Windows: https://docs.docker.com/desktop/install/windows/"
    return 1
  fi
}

# Check port availability
check_port() {
  local port="$1"
  echo "Checking if port ${port} is available..."
  
  if command -v nc &> /dev/null; then
    if nc -z localhost "${port}" 2>/dev/null; then
      echo "✗ Port ${port} is already in use"
      echo "  Please choose a different port with:"
      echo "  ANTHROPIC_KEY=your_key GITHUB_TOKEN=your_token gmake run-container PORT=${port}"
      return 1
    else
      echo "✓ Port ${port} is available"
      return 0
    fi
  elif command -v lsof &> /dev/null; then
    if lsof -i :"${port}" &>/dev/null; then
      echo "✗ Port ${port} is already in use"
      echo "  Please choose a different port with:"
      echo "  ANTHROPIC_KEY=your_key GITHUB_TOKEN=your_token gmake run-container PORT=${port}"
      return 1
    else
      echo "✓ Port ${port} is available"
      return 0
    fi
  else
    echo "\! Cannot check port availability (nc or lsof not found)"
    echo "  Assuming port ${port} is available"
    return 0
  fi
}

# Check required environment variables
check_env_vars() {
  echo "Checking required environment variables..."
  local missing=0
  
  if [ -z "${ANTHROPIC_KEY:-}" ]; then
    echo "✗ ANTHROPIC_KEY is not set"
    echo "  Get your API key from https://console.anthropic.com/settings/keys"
    missing=1
  else
    echo "✓ ANTHROPIC_KEY is set"
  fi
  
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "✗ GITHUB_TOKEN is not set"
    echo "  Create a token at https://github.com/settings/tokens"
    echo "  Requires 'repo' scope at minimum"
    missing=1
  else
    echo "✓ GITHUB_TOKEN is set"
  fi
  
  return $missing
}

# Check Docker image
check_image() {
  echo "Checking Docker image..."
  if docker image inspect "${DOCKER_IMAGE}" &>/dev/null; then
    echo "✓ Docker image ${DOCKER_IMAGE} is available"
    return 0
  else
    echo "- Docker image ${DOCKER_IMAGE} will be pulled automatically"
    return 0
  fi
}

# Run all checks
run_checks() {
  local port="${1:-8000}"
  local status=0
  
  echo "=== Computer Use Container Prerequisites ==="
  
  check_docker || status=1
  check_port "${port}" || status=1
  check_env_vars || status=1
  check_image || status=1
  
  echo "=========================================="
  
  if [ $status -eq 0 ]; then
    echo "✅ All checks passed\! You're ready to run Computer Use."
    echo
    echo "Run the container with:"
    echo "  ANTHROPIC_KEY=your_key GITHUB_TOKEN=your_token gmake run-container"
    echo
    echo "Or with a custom port:"
    echo "  HOST_PORT=9000 ANTHROPIC_KEY=your_key GITHUB_TOKEN=your_token gmake run-container"
  else
    echo "❌ Some checks failed. Please fix the issues above."
  fi
  
  return $status
}

# Main function
main() {
  run_checks "$PORT"
}

main "$@"
