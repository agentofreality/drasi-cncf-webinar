#!/bin/bash

# PostgreSQL with Logical Replication Setup Script for Drasi CNCF Webinar Demo
# This script starts PostgreSQL with logical replication enabled and sets up the demo databases

set -e

echo "Starting PostgreSQL with logical replication for Drasi demo..."

# Stop and remove any existing container
echo "Stopping any existing PostgreSQL container..."
docker stop postgres-demo 2>/dev/null || true
docker rm postgres-demo 2>/dev/null || true

# Start PostgreSQL with Docker Compose
echo "Starting PostgreSQL with logical replication configuration..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
timeout=30
while ! docker exec postgres-demo pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        echo "Error: PostgreSQL failed to start within 30 seconds"
        docker-compose logs postgres
        exit 1
    fi
done

echo "PostgreSQL is ready!"

# Verify logical replication is enabled
echo "Verifying logical replication configuration..."
wal_level=$(docker exec postgres-demo psql -U postgres -t -c "SHOW wal_level;" | xargs)
if [ "$wal_level" = "logical" ]; then
    echo "✅ Logical replication is enabled (wal_level = $wal_level)"
else
    echo "❌ Logical replication is not enabled (wal_level = $wal_level)"
    echo "Please check the PostgreSQL configuration"
    exit 1
fi

echo ""
echo "PostgreSQL with logical replication is running!"
echo "Container: postgres-demo"
echo "Port: 5432"
echo "Connection: postgresql://postgres:password@localhost:5432"
echo ""
echo "Next steps:"
echo "1. Run ./init-databases.sh to create the demo databases"
echo "2. Run ./setup-replication.sh to configure Drasi replication user"
echo "3. Run ./load-sample-data.sh to load sample data"