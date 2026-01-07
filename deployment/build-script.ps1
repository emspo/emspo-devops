    param (
        [string]$TAG = "dev"
    )

    # Define variables
    $IMAGE_NAME = "mspots_be"
    $DOCKERFILE_PATH = "./../"
    $REPOSITORY = "emspo"

    # Build the Docker image
    docker build -t "${IMAGE_NAME}:${TAG}" $DOCKERFILE_PATH

    # Check if the build was successful
    if ($LASTEXITCODE -eq 0) {
        # Modified $SELECTION_PLACEHOLDER$ code
        Write-Output "Docker image ${IMAGE_NAME}:${TAG} built successfully."
        
        # Tag the image for the repository
        docker tag "${IMAGE_NAME}:${TAG}" "${REPOSITORY}/${IMAGE_NAME}:${TAG}"
        
        # Push the image to the repository
        docker push "${REPOSITORY}/${IMAGE_NAME}:${TAG}"
        
        # Check if the push was successful
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Docker image ${REPOSITORY}/${IMAGE_NAME}:${TAG} pushed successfully."
        } else {
            Write-Output "Failed to push Docker image ${REPOSITORY}/${IMAGE_NAME}:${TAG}."
            exit 1
        }
    } else {
        Write-Output "Failed to build Docker image ${IMAGE_NAME}:${TAG}."
        exit 1
    }