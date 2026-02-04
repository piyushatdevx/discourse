#!/bin/bash
# FanTribe Discourse Server Setup Script
# =======================================
# Run this script on a fresh Ubuntu 22.04 server
# Usage: sudo bash setup-server.sh

set -e

echo "=========================================="
echo "FanTribe Discourse Server Setup"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo bash setup-server.sh)"
  exit 1
fi

# Update system
echo "[1/6] Updating system packages..."
apt update && apt upgrade -y

# Install Docker
echo "[2/6] Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
  echo "Docker installed successfully"
else
  echo "Docker already installed"
fi

# Install Git
echo "[3/6] Installing Git..."
apt install -y git

# Clone Discourse Docker
echo "[4/6] Setting up Discourse Docker..."
if [ ! -d "/var/discourse" ]; then
  git clone https://github.com/discourse/discourse_docker.git /var/discourse
  echo "Discourse Docker cloned to /var/discourse"
else
  echo "/var/discourse already exists, updating..."
  cd /var/discourse && git pull
fi

# Create directories
echo "[5/6] Creating necessary directories..."
mkdir -p /var/discourse/shared/standalone
mkdir -p /var/discourse/shared/standalone/log/var-log

# Set permissions
chown -R root:root /var/discourse

echo "[6/6] Setup complete!"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Copy the fantribe-theme plugin to the server:"
echo "   scp -r plugins/fantribe-theme root@your-server:/tmp/"
echo ""
echo "2. Copy your app.yml configuration:"
echo "   scp deployment/app.yml root@your-server:/var/discourse/containers/"
echo ""
echo "3. Build and launch Discourse:"
echo "   cd /var/discourse"
echo "   ./launcher rebuild app"
echo ""
echo "4. Monitor the build (takes 5-15 minutes):"
echo "   ./launcher logs app"
echo ""
echo "=========================================="
