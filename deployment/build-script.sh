#!/bin/bash

# Define variables
IMAGE_NAME="mspots_be"
TAG="dev"
DOCKERFILE_PATH="./../"
REPOSITORY="emspo"

# Build the Docker image
docker build -t $IMAGE_NAME:$TAG $DOCKERFILE_PATH

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image $IMAGE_NAME:$TAG built successfully."
    
    # Tag the image for the repository
    docker tag $IMAGE_NAME:$TAG $REPOSITORY/$IMAGE_NAME:$TAG
    
    # Push the image to the repository
    docker push $REPOSITORY/$IMAGE_NAME:$TAG
    
    # Check if the push was successful
    if [ $? -eq 0 ]; then
        echo "Docker image $REPOSITORY/$IMAGE_NAME:$TAG pushed successfully."
    else
        echo "Failed to push Docker image $REPOSITORY/$IMAGE_NAME:$TAG."
        exit 1
    fi
else
    echo "Failed to build Docker image $IMAGE_NAME:$TAG."
    exit 1
fi