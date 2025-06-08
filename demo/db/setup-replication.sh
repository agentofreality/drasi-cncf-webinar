#!/bin/bash

# Setup Drasi Logical Replication Script
# This script configures PostgreSQL for Drasi logical replication

set -e

# Configuration
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}

echo "Setting up Drasi logical replication configuration..."

# Check if PostgreSQL is accessible
echo "Checking PostgreSQL connection..."
if ! docker exec postgres-demo pg_isready -U postgres > /dev/null 2>&1; then
    echo "Error: PostgreSQL is not accessible. Please start PostgreSQL first with ./start-postgres.sh"
    exit 1
fi

# Verify logical replication is enabled
echo "Verifying logical replication is enabled..."
wal_level=$(docker exec postgres-demo psql -U postgres -t -c "SHOW wal_level;" | xargs)
if [ "$wal_level" != "logical" ]; then
    echo "Error: Logical replication is not enabled (wal_level = $wal_level)"
    echo "Please ensure PostgreSQL is started with the correct configuration using ./start-postgres.sh"
    exit 1
fi

echo "✅ Logical replication is enabled"

# Execute the replication setup SQL script
echo "Creating Drasi replication user and setting up permissions..."
docker exec -i postgres-demo psql -U postgres < "$(dirname "$0")/setup-replication.sql"

# Verify the replication user was created
echo "Verifying replication user setup..."
user_exists=$(docker exec postgres-demo psql -U postgres -t -c "SELECT COUNT(*) FROM pg_user WHERE usename = 'drasi_replication';" | xargs)
if [ "$user_exists" = "1" ]; then
    echo "✅ Drasi replication user created successfully"
else
    echo "❌ Failed to create Drasi replication user"
    exit 1
fi

# Test replication connection
echo "Testing replication connection..."
if docker exec postgres-demo psql -U drasi_replication -d postgres -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Replication user can connect successfully"
else
    echo "❌ Replication user cannot connect"
    exit 1
fi

echo ""
echo "🎉 Drasi logical replication setup completed successfully!"
echo ""
echo "Replication user: drasi_replication"
echo "Replication password: drasi_password"
echo ""
echo "Your PostgreSQL databases are now ready for Drasi Sources!"
echo ""
echo "Next steps:"
echo "1. Update Drasi source configurations to use the replication user"
echo "2. Deploy Drasi sources with: cd ../drasi && ./deploy-drasi.sh"