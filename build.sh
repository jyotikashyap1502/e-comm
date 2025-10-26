#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
IMAGE_NAME="ecomm-react-app"                   # local image name
DOCKERHUB_USER="jyotikashyap1502"                       # replace with your Docker Hub username
DEV_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:dev-latest"
PROD_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:prod-latest"
BUILD_TAG="${IMAGE_NAME}:local-$(date +%Y%m%d%H%M%S)"
CONTEXT="."                                    # build context (project root)
DOCKERFILE="Dockerfile"
# =============

echo "🔧 Building local image $BUILD_TAG ..."
docker build -t "$BUILD_TAG" -f "$DOCKERFILE" "$CONTEXT"

# Tag for dev
echo "🏷️ Tagging as $DEV_TAG ..."
docker tag "$BUILD_TAG" "$DEV_TAG"

# Optionally tag for prod (uncomment if required)
# echo "🏷️ Tagging as $PROD_TAG ..."
# docker tag "$BUILD_TAG" "$PROD_TAG"

echo "✅ Build complete. Images created:"
docker images | grep "${IMAGE_NAME}" || true

echo
echo "To push images to Docker Hub:"
echo "  docker login"
echo "  docker push $DEV_TAG"
echo "To push prod tag:"
echo "  docker tag $BUILD_TAG $PROD_TAG && docker push $PROD_TAG"
