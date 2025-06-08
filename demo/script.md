# CNCF Webinar Demo Script - SQL Commands

This document contains the SQL statements to execute during the live demo to demonstrate Drasi's change-driven capabilities.

## Demo Overview

We'll demonstrate two use cases:
1. **Reacting to Change**: Trigger automatic reordering when inventory drops below reorder levels
2. **Reacting to Absence of Change**: Flag supplier orders missing delivery dates

## Current Product Inventory

| Product | Name | Reorder Level | Current Qty | Available for Demo |
|---------|------|---------------|-------------|-------------------|
| PROD-001 | Wireless Headphones | 10 | 25 | 15 units |
| PROD-002 | Bluetooth Speaker | 5 | 18 | 13 units |
| PROD-003 | Laptop Stand | 15 | 40 | 25 units |
| PROD-004 | USB-C Cable | 25 | 75 | 50 units |
| PROD-005 | Wireless Mouse | 8 | 20 | 12 units |

## Demo Sequence: Progressive Customer Orders

### Step 1: Check Initial State

Before starting the demo, verify the current state:

```sql
-- Connect to inventory_management database
\c inventory_management;

-- Show current product inventory
SELECT product_id, name, reorder_level, qty_on_hand, 
       (qty_on_hand - reorder_level) AS buffer
FROM product 
ORDER BY product_id;
```

Expected result: All products should have positive buffer (qty_on_hand > reorder_level).

### Step 2: Check Drasi Query Results

```sql
-- Check if any products currently need reordering (should be empty initially)
-- This simulates what Drasi's continuous query would return
SELECT 
  p.product_id,
  p.name AS product_name,
  p.reorder_level,
  p.qty_on_hand,
  COALESCE(
    (SELECT SUM(coi.quantity) 
     FROM customer_order_item coi 
     JOIN customer_order co ON coi.order_id = co.order_id 
     WHERE coi.product_id = p.product_id 
     AND co.order_date >= NOW() - INTERVAL '7 days'),
    0
  ) AS recent_customer_orders,
  (p.qty_on_hand - COALESCE(
    (SELECT SUM(coi.quantity) 
     FROM customer_order_item coi 
     JOIN customer_order co ON coi.order_id = co.order_id 
     WHERE coi.product_id = p.product_id 
     AND co.order_date >= NOW() - INTERVAL '7 days'),
    0
  )) AS available_inventory
FROM product p
WHERE (p.qty_on_hand - COALESCE(
  (SELECT SUM(coi.quantity) 
   FROM customer_order_item coi 
   JOIN customer_order co ON coi.order_id = co.order_id 
   WHERE coi.product_id = p.product_id 
   AND co.order_date >= NOW() - INTERVAL '7 days'),
  0
)) <= p.reorder_level;
```

Expected result: No rows (no products need reordering yet).

## Live Demo: Creating Customer Orders

### Customer Order 1 - Large Headphone Order

**Scenario**: A corporate customer places a bulk order for wireless headphones for their office.

```sql
-- Switch to retail_operations database
\c retail_operations;

-- Create customer order 1
INSERT INTO customer_order (order_id, customer_id, order_date) 
VALUES ('DEMO-001', 'CORP-CLIENT-001', NOW());

-- Add 12 wireless headphones to the order
-- This will reduce available inventory from 25 to 13 (still above reorder level of 10)
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) 
VALUES ('DEMO-ITEM-001', 'DEMO-001', 'PROD-001', 12, 99.99);
```

**Expected Result**: 
- Available inventory for PROD-001: 25 - 12 = 13 (still above reorder level of 10)
- No Drasi reaction yet

**Verify the change**:
```sql
\c inventory_management;
SELECT 
  p.product_id, p.name, p.reorder_level, p.qty_on_hand,
  COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
           JOIN customer_order co ON coi.order_id = co.order_id 
           WHERE coi.product_id = p.product_id 
           AND co.order_date >= NOW() - INTERVAL '7 days'), 0) AS recent_orders,
  (p.qty_on_hand - COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
                            JOIN customer_order co ON coi.order_id = co.order_id 
                            WHERE coi.product_id = p.product_id 
                            AND co.order_date >= NOW() - INTERVAL '7 days'), 0)) AS available
FROM product p WHERE product_id = 'PROD-001';
```

### Customer Order 2 - Mixed Electronics Order

**Scenario**: An online customer orders headphones and speakers for a home setup.

```sql
\c retail_operations;

-- Create customer order 2
INSERT INTO customer_order (order_id, customer_id, order_date) 
VALUES ('DEMO-002', 'HOME-USER-001', NOW());

-- Add 4 more wireless headphones
-- This will reduce PROD-001 available inventory to 9 (below reorder level of 10) 
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) 
VALUES ('DEMO-ITEM-002', 'DEMO-002', 'PROD-001', 4, 99.99);

-- Add 10 bluetooth speakers  
-- This will reduce PROD-002 available inventory from 18 to 8 (still above reorder level of 5)
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) 
VALUES ('DEMO-ITEM-003', 'DEMO-002', 'PROD-002', 10, 49.99);
```

**🚨 EXPECTED DRASI REACTION**: 
- PROD-001 (Wireless Headphones) available inventory: 25 - 12 - 4 = 9 (below reorder level of 10)
- Drasi should automatically create a supplier order for PROD-001

**Verify the trigger**:
```sql
\c inventory_management;

-- Check which products now need reordering
SELECT 
  p.product_id, p.name, p.reorder_level, p.qty_on_hand,
  COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
           JOIN customer_order co ON coi.order_id = co.order_id 
           WHERE coi.product_id = p.product_id 
           AND co.order_date >= NOW() - INTERVAL '7 days'), 0) AS recent_orders,
  (p.qty_on_hand - COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
                            JOIN customer_order co ON coi.order_id = co.order_id 
                            WHERE coi.product_id = p.product_id 
                            AND co.order_date >= NOW() - INTERVAL '7 days'), 0)) AS available
FROM product p 
WHERE (p.qty_on_hand - COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
                                JOIN customer_order co ON coi.order_id = co.order_id 
                                WHERE coi.product_id = p.product_id 
                                AND co.order_date >= NOW() - INTERVAL '7 days'), 0)) <= p.reorder_level;
```

**Check for automatic supplier order creation**:
```sql
-- Look for the supplier order that Drasi should have created
SELECT so.order_id, so.supplier_id, so.order_date, so.delivery_date,
       soi.product_id, soi.quantity, soi.price
FROM supplier_order so
JOIN supplier_order_item soi ON so.order_id = soi.order_id
WHERE so.order_date >= NOW() - INTERVAL '5 minutes'
ORDER BY so.order_date DESC;
```

### Customer Order 3 - Conference Equipment Order

**Scenario**: A conference organizer orders speakers and mice for their event.

```sql
\c retail_operations;

-- Create customer order 3  
INSERT INTO customer_order (order_id, customer_id, order_date) 
VALUES ('DEMO-003', 'CONF-ORG-001', NOW());

-- Add 9 more bluetooth speakers
-- This will reduce PROD-002 available inventory from 8 to -1 (well below reorder level of 5)
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) 
VALUES ('DEMO-ITEM-004', 'DEMO-003', 'PROD-002', 9, 49.99);

-- Add 13 wireless mice  
-- This will reduce PROD-005 available inventory from 20 to 7 (below reorder level of 8)
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) 
VALUES ('DEMO-ITEM-005', 'DEMO-003', 'PROD-005', 13, 24.99);
```

**🚨 EXPECTED DRASI REACTIONS**: 
- PROD-002 (Bluetooth Speaker) available inventory: 18 - 10 - 9 = -1 (well below reorder level of 5)
- PROD-005 (Wireless Mouse) available inventory: 20 - 13 = 7 (below reorder level of 8)
- Drasi should automatically create supplier orders for both PROD-002 and PROD-005

**Final verification**:
```sql
\c inventory_management;

-- Show all products that now need reordering
SELECT 
  p.product_id, p.name, p.reorder_level, p.qty_on_hand,
  COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
           JOIN customer_order co ON coi.order_id = co.order_id 
           WHERE coi.product_id = p.product_id 
           AND co.order_date >= NOW() - INTERVAL '7 days'), 0) AS recent_orders,
  (p.qty_on_hand - COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
                            JOIN customer_order co ON coi.order_id = co.order_id 
                            WHERE coi.product_id = p.product_id 
                            AND co.order_date >= NOW() - INTERVAL '7 days'), 0)) AS available_inventory
FROM product p 
WHERE (p.qty_on_hand - COALESCE((SELECT SUM(coi.quantity) FROM customer_order_item coi 
                                JOIN customer_order co ON coi.order_id = co.order_id 
                                WHERE coi.product_id = p.product_id 
                                AND co.order_date >= NOW() - INTERVAL '7 days'), 0)) <= p.reorder_level
ORDER BY available_inventory;
```

**Check all automatic supplier orders created by Drasi**:
```sql
-- Show all supplier orders created during the demo
SELECT 
  so.order_id, so.supplier_id, so.order_date, so.delivery_date,
  soi.product_id, p.name as product_name, soi.quantity, soi.price,
  'AUTO-REORDER' as created_by
FROM supplier_order so
JOIN supplier_order_item soi ON so.order_id = soi.order_id
JOIN product p ON soi.product_id = p.product_id
WHERE so.order_date >= NOW() - INTERVAL '10 minutes'
ORDER BY so.order_date DESC, soi.product_id;
```

## Testing Results

Based on our test run:

**Current Customer Orders:**
- PROD-001 (Wireless Headphones): 16 units ordered vs 25 on hand = 9 available (below reorder level 10) ✅
- PROD-002 (Bluetooth Speaker): 19 units ordered vs 18 on hand = -1 available (well below reorder level 5) ✅  
- PROD-005 (Wireless Mouse): 13 units ordered vs 20 on hand = 7 available (below reorder level 8) ✅

**Expected Drasi Reactions:**
All three products should trigger automatic supplier orders since their available inventory is at or below reorder levels.

## Demo Summary

After completing these three customer orders, you should observe:

1. **PROD-001 (Wireless Headphones)**: Available inventory dropped to 9 (below reorder level 10) → Automatic supplier order created
2. **PROD-002 (Bluetooth Speaker)**: Available inventory dropped to -1 (below reorder level 5) → Automatic supplier order created  
3. **PROD-005 (Wireless Mouse)**: Available inventory dropped to 7 (below reorder level 8) → Automatic supplier order created

This demonstrates Drasi's ability to:
- ✅ Monitor inventory levels across customer orders in real-time
- ✅ Automatically detect when available inventory falls below reorder thresholds
- ✅ Trigger business logic (create supplier orders) without manual intervention
- ✅ Handle multiple simultaneous triggers efficiently

## Use Case 2 Demo: Delivery Date Monitoring

To demonstrate reacting to **absence of change** (missing delivery dates):

```sql
\c inventory_management;

-- The supplier orders created by Drasi will initially have NULL delivery_date
-- After 15 minutes, Drasi should flag them for manual review
-- You can check this with:

SELECT 
  so.order_id,
  so.supplier_id, 
  so.order_date,
  so.delivery_date,
  EXTRACT(EPOCH FROM (NOW() - so.order_date))/60 AS minutes_since_order,
  CASE 
    WHEN so.delivery_date IS NULL AND EXTRACT(EPOCH FROM (NOW() - so.order_date))/60 > 15 
    THEN 'NEEDS_MANUAL_REVIEW' 
    ELSE 'OK' 
  END AS status
FROM supplier_order so
WHERE so.order_date >= NOW() - INTERVAL '1 hour'
ORDER BY so.order_date DESC;
```

## Testing and Verification

### Single-Database Testing (for validation)

Since the demo involves cross-database queries, here's a manual verification approach:

**Check customer order totals (in retail_operations database):**
```sql
\c retail_operations;
SELECT coi.product_id, SUM(coi.quantity) as total_ordered 
FROM customer_order_item coi 
JOIN customer_order co ON coi.order_id = co.order_id 
WHERE co.order_date >= NOW() - INTERVAL '7 days' 
GROUP BY coi.product_id 
ORDER BY coi.product_id;
```

**Check inventory levels (in inventory_management database):**
```sql
\c inventory_management;
SELECT product_id, name, reorder_level, qty_on_hand 
FROM product 
ORDER BY product_id;
```

**Manual calculation:**
- PROD-001: qty_on_hand (25) - total_ordered (16) = 9 available (≤ reorder_level 10) → **TRIGGER**
- PROD-002: qty_on_hand (18) - total_ordered (19) = -1 available (≤ reorder_level 5) → **TRIGGER**  
- PROD-005: qty_on_hand (20) - total_ordered (13) = 7 available (≤ reorder_level 8) → **TRIGGER**

## Presenter Notes

- **Timing**: Each customer order should be placed with a 2-3 minute gap to show real-time processing
- **Audience Engagement**: Ask audience to predict which products will trigger reorders
- **Technical Details**: Explain how Drasi's continuous query evaluates the WHERE clause on each data change
- **Business Value**: Emphasize zero manual monitoring and immediate response to inventory changes
- **Cross-Database**: Highlight that Drasi handles the complexity of correlating data across multiple databases