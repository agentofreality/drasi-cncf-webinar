# Database Setup for Drasi CNCF Webinar Demo

This directory contains the database schema and initialization scripts for the Drasi CNCF webinar demo.

## Overview

The demo uses two PostgreSQL databases:

1. **retail_operations** - Handles customer orders and order items
2. **inventory_management** - Manages products, suppliers, and supplier orders

## Files

- `retail_operations.sql` - Schema for the retail operations database
- `inventory_management.sql` - Schema for the inventory management database  
- `init-databases.sh` - Script to initialize both databases
- `sample-data.sql` - Sample data for demo purposes
- `load-sample-data.sh` - Script to load sample data
- `README.md` - This file

## Quick Start

### Prerequisites

- PostgreSQL server running and accessible
- `psql` command-line tool installed

### Running PostgreSQL with Docker (Recommended)

The easiest way to run PostgreSQL for this demo is using Docker:

```bash
# Start PostgreSQL container
docker run --name postgres-demo \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_USER=postgres \
  -p 5432:5432 \
  -d postgres:15

# Verify it's running
docker ps
```

To stop and clean up after the demo:
```bash
# Stop the container
docker stop postgres-demo

# Remove the container
docker rm postgres-demo
```

**Alternative: Docker Compose**

Create a `docker-compose.yml` file:
```yaml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Then run:
```bash
# Start PostgreSQL
docker-compose up -d

# Stop PostgreSQL
docker-compose down
```

### Environment Variables

Configure these environment variables (optional, defaults shown):

```bash
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=password
```

### Initialize Databases

Run the initialization script:

```bash
./init-databases.sh
```

This will:
1. Create the two databases if they don't exist
2. Create all required tables with proper indexes
3. Set up foreign key relationships

### Load Sample Data

After initializing the databases, load sample data:

```bash
./load-sample-data.sh
```

This will insert:
- 5 products with different reorder levels (PROD-001 through PROD-005)
- 3 customer orders (ORD-001, ORD-002, ORD-003)  
- 7 order items across the customer orders

## Database Schema

### Retail Operations Database

**customer_order**
- order_id (VARCHAR(50) PRIMARY KEY)
- customer_id (VARCHAR(50))
- order_date (TIMESTAMP)

**customer_order_item**
- id (VARCHAR(50) PRIMARY KEY)
- order_id (VARCHAR(50), FK to customer_order)
- product_id (VARCHAR(50))
- quantity (INTEGER)
- price (DECIMAL)

### Inventory Management Database

**product**
- product_id (VARCHAR(50) PRIMARY KEY)
- supplier_id (VARCHAR(50))
- name (VARCHAR(255))
- description (TEXT)
- price (DECIMAL)
- reorder_level (INTEGER)

**supplier_order**
- order_id (VARCHAR(50) PRIMARY KEY)
- supplier_id (VARCHAR(50))
- order_date (TIMESTAMP)
- delivery_date (TIMESTAMP, nullable)

**supplier_order_item**
- id (VARCHAR(50) PRIMARY KEY)
- order_id (VARCHAR(50), FK to supplier_order)
- product_id (VARCHAR(50), FK to product)
- quantity (INTEGER)
- price (DECIMAL)