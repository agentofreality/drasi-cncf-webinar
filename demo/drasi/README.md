# Drasi Configuration for CNCF Webinar Demo

This directory contains the Drasi Sources and Continuous Queries for the CNCF webinar demo scenario.

## Overview

The demo showcases two key use cases for change-driven solutions:

1. **Reacting to Change** - Monitoring inventory levels and triggering reorders
2. **Reacting to Absence of Change** - Tracking supplier orders without delivery dates

## Directory Structure

```
demo/drasi/
├── sources/
│   ├── retail-operations-source.yaml
│   └── inventory-management-source.yaml
├── queries/
│   ├── reorder-monitoring-query.yaml
│   └── supplier-delivery-tracking-query.yaml
├── reactions/
│   └── reorder-reaction.yaml
├── deploy-drasi.sh
└── README.md
```

## Sources

### retail-operations-source.yaml
Connects to the retail operations PostgreSQL database and monitors:
- `customer_order` - Customer order headers
- `customer_order_item` - Individual items in customer orders

### inventory-management-source.yaml
Connects to the inventory management PostgreSQL database and monitors:
- `product` - Product catalog with reorder levels
- `supplier_order` - Orders placed with suppliers
- `supplier_order_item` - Individual items in supplier orders

## Continuous Queries

### reorder-monitoring-query.yaml
**Use Case 1: Reacting to Change**

Monitors product inventory levels and identifies products that need reordering when:
- Available inventory (stock + on order - customer orders) ≤ reorder level

The query calculates:
- `available_inventory` - Current stock on hand
- `quantity_on_order` - Items ordered from suppliers but not yet delivered
- `quantity_ordered_by_customers` - Recent customer demand

### supplier-delivery-tracking-query.yaml
**Use Case 2: Reacting to Absence of Change**

Tracks supplier orders that lack delivery dates and flags them for manual review when:
- Order placed with supplier > 15 minutes ago
- No delivery date provided

The query provides:
- `minutes_since_order` - Time elapsed since order placement
- `status` - Current order status for review workflow
- `total_value` - Financial impact of delayed orders

## Reactions

### reorder-reaction.yaml
**Stored Procedure Reaction for Automatic Reordering**

Subscribes to the `reorder-monitoring-query` and automatically creates supplier orders when products need reordering:

- **Trigger**: When a product appears in the reorder monitoring results (INSERT event)
- **Action**: Creates a new supplier order with order quantity = reorder_level × 2
- **Target**: Inserts into `supplier_order` and `supplier_order_item` tables
- **Logging**: Provides NOTICE messages for demo visibility

The reaction demonstrates how Drasi can automatically trigger business processes based on continuous query results.

## Deployment

### Prerequisites
- Drasi installed and running
- Both PostgreSQL databases initialized (see `../db/README.md`)

### Apply Sources
```bash
kubectl apply -f sources/retail-operations-source.yaml
kubectl apply -f sources/inventory-management-source.yaml
```

### Apply Continuous Queries
```bash
kubectl apply -f queries/reorder-monitoring-query.yaml
kubectl apply -f queries/supplier-delivery-tracking-query.yaml
```

### Apply Reactions
```bash
kubectl apply -f reactions/reorder-reaction.yaml
```

### Verify Deployment
```bash
# Check sources
kubectl get sources

# Check continuous queries
kubectl get continuousqueries

# Check reactions
kubectl get reactions

# View query results
kubectl logs -l app=drasi-query-container
```

## Demo Workflow

1. **Setup** - Deploy sources and queries
2. **Simulate Data Changes** - Insert/update database records
3. **Monitor Reactions** - Observe Drasi detecting changes and triggering actions
4. **Show Absence Detection** - Demonstrate time-based alerting for missing delivery dates

## Configuration Notes

- Database connection strings use `localhost:5432` - adjust for your environment
- Queries use PostgreSQL-specific syntax (EXTRACT, INTERVAL)
- Time thresholds (15 minutes, 7 days) can be adjusted for demo timing
- Reorder levels are configurable per product in the database