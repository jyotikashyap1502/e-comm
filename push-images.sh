#!/bin/bash
set -e

USERNAME="hello85"
IMAGE="ecomm-react-app"
TAG="latest"

echo "🚀 Tagging images..."
docker tag $IMAGE:$TAG $USERNAME/ecomm-react-dev:$TAG
docker tag $IMAGE:$TAG $USERNAME/ecomm-react-prod:$TAG

echo "📤 Pushing dev image (public)..."
docker push $USERNAME/ecomm-react-dev:$TAG

echo "📤 Pushing prod image (private)..."
docker push $USERNAME/ecomm-react-prod:$TAG

echo "✅ Both images pushed successfully!"
