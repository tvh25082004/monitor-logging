#!/bin/bash

echo "🚀 Setting up Monitoring System with PLG Stack..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Docker
echo "📋 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"

# Create directories
echo "📁 Creating log directories..."
mkdir -p logs app-logs nginx-logs
mkdir -p audit-logs/mongodb
mkdir -p audit-logs/postgres
mkdir -p audit-logs/application
echo -e "${GREEN}✓ Directories created${NC}"

# Set permissions
chmod -R 755 logs app-logs nginx-logs audit-logs

# Check if config files exist
echo "🔍 Checking configuration files..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

if [ ! -f "loki-config.yml" ]; then
    echo "❌ loki-config.yml not found!"
    exit 1
fi

if [ ! -f "promtail-config.yml" ]; then
    echo "❌ promtail-config.yml not found!"
    exit 1
fi

echo -e "${GREEN}✓ Config files found${NC}"

# Check port availability
echo "🔌 Checking ports..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}⚠ Port 3000 is in use${NC}"
fi

if lsof -Pi :3100 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}⚠ Port 3100 is in use${NC}"
fi

# Start containers
echo "🐳 Starting containers..."
docker compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Containers started successfully${NC}"
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📍 Access Grafana at: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: admin"
    echo ""
    echo "📍 Loki is available at: http://localhost:3100"
    echo ""
    echo "🔍 Check container status:"
    echo "   docker compose ps"
    echo ""
    echo "📊 View logs:"
    echo "   docker compose logs -f"
else
    echo "❌ Failed to start containers"
    exit 1
fi

