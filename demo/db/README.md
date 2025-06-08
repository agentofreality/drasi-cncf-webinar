# Database Setup for Drasi CNCF Webinar Demo

This directory contains the database schema and initialization scripts for the Drasi CNCF webinar demo.

## Overview

The demo uses two PostgreSQL databases configured with **logical replication** (required by Drasi):

1. **retail_operations** - Handles customer orders and order items
2. **inventory_management** - Manages products, suppliers, and supplier orders

## Files

### Database Schema
- `retail_operations.sql` - Schema for the retail operations database
- `inventory_management.sql` - Schema for the inventory management database  
- `sample-data.sql` - Sample data for demo purposes

### Setup Scripts
- `start-postgres.sh` - Start PostgreSQL with logical replication enabled
- `init-databases.sh` - Initialize both databases with tables and stored procedures
- `setup-replication.sh` - Configure Drasi replication user and permissions
- `load-sample-data.sh` - Load sample data

### Configuration Files
- `docker-compose.yml` - Docker Compose configuration for PostgreSQL
- `postgresql.conf` - PostgreSQL configuration with logical replication enabled
- `pg_hba.conf` - Authentication configuration for replication connections
- `setup-replication.sql` - SQL script for setting up replication user
- `stored-procedures.sql` - Stored procedures for automatic reordering functionality

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Drasi Sources require PostgreSQL with logical replication enabled

### Complete Setup (Recommended)

Follow these steps to set up PostgreSQL with logical replication for Drasi:

```bash
# 1. Start PostgreSQL with logical replication
./start-postgres.sh

# 2. Initialize databases and tables
./init-databases.sh

# 3. Set up Drasi replication user and permissions
./setup-replication.sh

# 4. Load sample data
./load-sample-data.sh
```

## Important: Logical Replication Requirements

Drasi Sources require PostgreSQL to be configured with logical replication enabled. This setup includes:

### PostgreSQL Configuration
- `wal_level = logical` - Enables logical replication
- `max_wal_senders = 10` - Allows replication connections
- `max_replication_slots = 10` - Supports multiple replication slots

### Replication User
- Dedicated user `drasi_replication` with replication privileges
- Proper table ownership and permissions for change data capture

### Network Access
- Configuration allows replication connections from Docker/Kubernetes networks
- Uses `host.docker.internal` for k3d/Docker connectivity

## Verification

After setup, verify the configuration:

```bash
# Check logical replication is enabled
docker exec postgres-demo psql -U postgres -c "SHOW wal_level;"

# Verify replication user exists
docker exec postgres-demo psql -U postgres -c "SELECT usename, userepl FROM pg_user WHERE usename = 'drasi_replication';"

# Test replication connection
docker exec postgres-demo psql -U drasi_replication -d retail_operations -c "SELECT COUNT(*) FROM customer_order;"
```

## Connection Information

**For Drasi Sources:**
- Host: `host.docker.internal` (when Drasi runs in k3d)
- Port: `5432`  
- User: `drasi_replication`
- Password: `drasi_password`

**For Demo/Testing:**
- Host: `localhost`
- Port: `5432`
- User: `postgres`
- Password: `password`

## Stored Procedures

### public.add_order(supplier_id, product_id, quantity)

This stored procedure is used by Drasi reactions to automatically create supplier orders:

**Parameters:**
- `supplier_id` (VARCHAR(50)) - ID of the supplier to order from
- `product_id` (VARCHAR(50)) - Product ID to reorder
- `quantity` (INTEGER) - Quantity to order

**Returns:** VARCHAR(50) - The generated order ID

**Example:**
```sql
SELECT public.add_order('SUPP-001', 'PROD-001', 20);
```

**Functionality:**
- Generates unique order ID with format: `AUTO-YYYYMMDD-HHMMSS-{product_id}`
- Creates entry in `supplier_order` table with current timestamp
- Creates entry in `supplier_order_item` table with product price
- Logs the reorder action with NOTICE for demo visibility
- Used by Drasi StoredProc reactions for automatic reordering

## Troubleshooting

### Logical Replication Not Enabled
If you see `wal_level = replica`, restart PostgreSQL with the custom configuration:
```bash
./start-postgres.sh
```

### Connection Issues from k3d
Ensure `host.docker.internal` resolves from within k3d containers:
```bash
kubectl run test-pod --image=busybox --rm -it -- nslookup host.docker.internal
```

### Replication User Issues
Re-run the replication setup:
```bash
./setup-replication.sh
```

### Stored Procedure Issues
Test the stored procedure manually:
```bash
docker exec postgres-demo psql -U drasi_replication -d inventory_management -c "SELECT public.add_order('SUPP-001', 'PROD-001', 20);"
```

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