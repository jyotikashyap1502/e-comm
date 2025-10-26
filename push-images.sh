#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Variables
IMAGE_NAME="ecomm-react-app"
DOCKER_USERNAME="jyotikashyap1502"
DEV_TAG="dev"
PROD_TAG="prod"

echo "🔹 Building Docker image..."
docker build -t ${IMAGE_NAME}:latest .

echo "🔹 Tagging images..."
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:${DEV_TAG}
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:${PROD_TAG}

echo "🔹 Logging in to Docker Hub..."
docker login

echo "🔹 Pushing dev image (public)..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${DEV_TAG}

echo "🔹 Pushing prod image (private)..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${PROD_TAG}

echo "✅ All images pushed successfully!"
