#!/bin/bash

# Database Initialization Script for Drasi CNCF Webinar Demo
# This script initializes both PostgreSQL databases required for the demo

set -e

# Configuration
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}

echo "Initializing databases for Drasi CNCF Webinar Demo..."

# Function to execute SQL file
execute_sql_file() {
    local database=$1
    local sql_file=$2
    
    echo "Executing $sql_file..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $database -f "$sql_file"
}

# Check if PostgreSQL is accessible
echo "Checking PostgreSQL connection..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "SELECT 1;" > /dev/null

if [ $? -eq 0 ]; then
    echo "PostgreSQL connection successful."
else
    echo "Failed to connect to PostgreSQL. Please check your connection parameters."
    exit 1
fi

# Create databases if they don't exist
echo "Creating databases..."

# Create retail_operations database if it doesn't exist
echo "Creating retail_operations database..."
if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -lqt | cut -d \| -f 1 | grep -qw retail_operations; then
    echo "Database retail_operations already exists - skipping creation"
else
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "CREATE DATABASE retail_operations;"
fi

# Create inventory_management database if it doesn't exist  
echo "Creating inventory_management database..."
if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -lqt | cut -d \| -f 1 | grep -qw inventory_management; then
    echo "Database inventory_management already exists - skipping creation"
else
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "CREATE DATABASE inventory_management;"
fi

# Initialize retail operations database
echo "Initializing retail operations database..."
execute_sql_file "retail_operations" "$(dirname "$0")/retail_operations.sql"

# Initialize inventory management database
echo "Initializing inventory management database..."
execute_sql_file "inventory_management" "$(dirname "$0")/inventory_management.sql"

echo "Database initialization completed successfully!"
echo ""
echo "Databases created:"
echo "  - retail_operations (tables: customer_order, customer_order_item)"
echo "  - inventory_management (tables: product, supplier_order, supplier_order_item)"
echo ""
echo "You can now connect to the databases using:"
echo "  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d retail_operations"
echo "  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d inventory_management"