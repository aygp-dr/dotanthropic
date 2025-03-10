#!/usr/bin/env bash
# Script to run the Anthropic Computer Use Docker container
# Requires ANTHROPIC_KEY and GITHUB_TOKEN environment variables

set -euo pipefail

# Default values
IMAGE_NAME="anthropics/computer-use-quickstart"
TAG="latest"
CONTAINER_NAME="anthropic-computer-use"
CONTAINER_PORT=8000
HOST_PORT=8000

# Usage information
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Run the Anthropic Computer Use Docker container"
  echo
  echo "Options:"
  echo "  -i, --image NAME      Docker image name (default: ${IMAGE_NAME})"
  echo "  -t, --tag TAG         Docker image tag (default: ${TAG})"
  echo "  -n, --name NAME       Container name (default: ${CONTAINER_NAME})"
  echo "  -p, --port PORT       Host port to map (default: ${HOST_PORT})"
  echo "  -h, --help            Show this help message"
  echo
  echo "Environment variables required:"
  echo "  ANTHROPIC_KEY         Your Anthropic API key"
  echo "  GITHUB_TOKEN          Your GitHub personal access token"
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--image)
      IMAGE_NAME="$2"
      shift 2
      ;;
    -t|--tag)
      TAG="$2"
      shift 2
      ;;
    -n|--name)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    -p|--port)
      HOST_PORT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Check for required environment variables
if [ -z "${ANTHROPIC_KEY:-}" ]; then
  echo "Error: ANTHROPIC_KEY environment variable is not set"
  echo "Please set your Anthropic API key:"
  echo "  export ANTHROPIC_KEY=your_api_key"
  exit 1
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Please set your GitHub token:"
  echo "  export GITHUB_TOKEN=your_github_token"
  exit 1
fi

# Stop and remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping and removing existing container: ${CONTAINER_NAME}"
  docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true
fi

# Pull the latest image
echo "Pulling Docker image: ${IMAGE_NAME}:${TAG}"
docker pull "${IMAGE_NAME}:${TAG}"

# Run the container
echo "Starting container: ${CONTAINER_NAME} on port ${HOST_PORT}"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -e ANTHROPIC_KEY="${ANTHROPIC_KEY}" \
  -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
  --restart unless-stopped \
  "${IMAGE_NAME}:${TAG}"

# Check if container started successfully
if [ "$(docker ps -q -f name="${CONTAINER_NAME}")" ]; then
  echo "Container started successfully!"
  echo "Access Computer Use at: http://localhost:${HOST_PORT}"
  echo
  echo "Container logs:"
  sleep 2
  docker logs "${CONTAINER_NAME}"
else
  echo "Failed to start container. Check logs with: docker logs ${CONTAINER_NAME}"
  exit 1
fi