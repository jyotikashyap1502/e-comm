#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
DOCKER_COMPOSE_FILE="docker-compose.yml"
# =============

echo "🛠 Stopping any existing containers..."
docker-compose -f "$DOCKER_COMPOSE_FILE" down || true

echo "🚀 Deploying application..."
docker-compose -f "$DOCKER_COMPOSE_FILE" up -d

echo "✅ Deployment complete!"
echo "🖥 Running containers:"
docker ps

echo "Visit http://localhost:3000 (or server IP) to check the application."
