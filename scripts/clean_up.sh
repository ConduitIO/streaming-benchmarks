#!/bin/bash

# Script to clean up Docker resources
# WARNING: This will stop all running containers and remove various Docker resources

set -euo pipefail

# Stop all running containers
echo "Stopping all running containers..."
docker stop $(docker ps -q) || echo "No running containers to stop"

# Remove stopped containers
echo "Removing stopped containers..."
docker container prune -f

# Remove unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Clean up unused Docker resources
echo "Cleaning up unused Docker resources..."
docker system prune -f

# Remove specific image
echo "Removing benchi/conduit image..."
docker image rm benchi/conduit || echo "Image benchi/conduit not found or couldn't be removed"

echo "Docker cleanup completed!"