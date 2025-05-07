#!/bin/bash

# Script to clean up Docker resources
# WARNING: This will stop all running containers and remove various Docker resources

set -euo pipefail

echo "Stopping all running containers..."
docker stop $(docker ps -q) || echo "No running containers to stop"

echo
echo "Removing stopped containers..."
docker container prune -f

echo
echo "Removing unused volumes..."
docker volume prune -f

echo
echo "Cleaning up unused Docker resources..."
docker system prune -f

echo
echo "Removing benchi/conduit image..."
docker image rm benchi/conduit || echo "Image benchi/conduit not found or couldn't be removed"

echo
echo "Docker cleanup completed!"