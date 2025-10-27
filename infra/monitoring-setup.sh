#!/bin/bash
# ==========================================
#  Uptime Kuma Monitoring Setup Script
#  Author: Mahendra Parmar (College Project)
#  Purpose: Monitor React App running on EC2
#  Free & Open-source Monitoring (Docker-based)
# ==========================================

set -e

echo "=========================================="
echo "🔍 Installing Uptime Kuma Monitoring"
echo "=========================================="

# Step 1: Install Docker and Docker Compose if not already installed
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt update -y
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Installing Docker Compose..."
  sudo apt install -y docker-compose
fi

# Step 2: Create directory for Uptime Kuma
echo "Setting up directory..."
mkdir -p /home/ubuntu/uptime-kuma
cd /home/ubuntu/uptime-kuma

# Step 3: Create Docker Compose file for Kuma
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    volumes:
      - ./uptime-kuma-data:/app/data
    ports:
      - "3001:3001"
    restart: unless-stopped
    environment:
      - TZ=Asia/Kolkata
EOF

# Step 4: Start Uptime Kuma
echo "Starting Uptime Kuma with Docker Compose..."
sudo docker-compose up -d

# Step 5: Wait for service to start
echo "Waiting for Uptime Kuma to initialize..."
sleep 10

# Step 6: Display access info
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "YOUR_EC2_PUBLIC_IP")
echo ""
echo "=========================================="
echo "✅ Uptime Kuma Installation Complete!"
echo "=========================================="
echo "🌐 Access Uptime Kuma at: http://$PUBLIC_IP:3001"
echo ""
echo "IMPORTANT: In AWS Security Group, open port 3001 (TCP) for your IP"
echo ""
echo "👉 First-time setup steps:"
echo "   1️⃣ Open the URL above in your browser"
echo "   2️⃣ Create an admin username & password"
echo "   3️⃣ Add a new monitor:"
echo "       - Monitor Type: HTTP(s)"
echo "       - Friendly Name: DevOps React App"
echo "       - URL: http://localhost:80"
echo "       - Interval: 60 seconds"
echo "       - Retries: 3"
echo ""
echo "After setup, you’ll see your app’s health status on the dashboard."
echo "=========================================="
