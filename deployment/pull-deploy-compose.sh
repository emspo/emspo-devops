#!/bin/bash

# Get the tag from the first parameter
TAG=$1

# Check if the tag is provided
if [ -z "$TAG" ]; then
    echo "Tag not provided. Usage: ./pull-deploy-compose.sh <tag>"
    exit 1
fi
# Define variables
REPO_DIR="./"
DOCKER_COMPOSE_FILE="${TAG}-docker-compose.yml"

# Navigate to the repository directory
cd $REPO_DIR || { echo "Repository directory not found"; exit 1; }

echo "Pulling latest be from Docker repository..."
docker pull emspo/mspots_be:${TAG}

echo "Pulling latest fe from Docker repository..."
docker pull emspo/mspots_fe:${TAG}

# Build and deploy the Docker containers
echo "Building and deploying Docker containers..."
docker compose -f $DOCKER_COMPOSE_FILE up --build -d || { echo "Failed to deploy Docker containers"; exit 1; }

echo "Deployment successful!"