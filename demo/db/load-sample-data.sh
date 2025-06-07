#!/bin/bash

# Sample Data Loading Script for Drasi CNCF Webinar Demo
# This script loads sample data into both PostgreSQL databases

set -e

# Configuration
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}

echo "Loading sample data for Drasi CNCF Webinar Demo..."

# Check if PostgreSQL is accessible
echo "Checking PostgreSQL connection..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "SELECT 1;" > /dev/null

if [ $? -eq 0 ]; then
    echo "PostgreSQL connection successful."
else
    echo "Failed to connect to PostgreSQL. Please check your connection parameters."
    exit 1
fi

# Load sample data
echo "Loading sample data..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -f "$(dirname "$0")/sample-data.sql"

echo "Sample data loaded successfully!"
echo ""
echo "Sample data includes:"
echo "  Products (5): PROD-001 through PROD-005 with varying reorder levels"
echo "  Customer Orders (3): ORD-001, ORD-002, ORD-003"
echo "  Order Items (7): Various quantities across different products"
echo ""
echo "You can verify the data with:"
echo "  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d inventory_management -c 'SELECT * FROM product;'"
echo "  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d retail_operations -c 'SELECT * FROM customer_order;'"