-- Sample Data for Drasi CNCF Webinar Demo
-- This script inserts sample data into the demo databases

-- Connect to inventory_management database and insert products
\c inventory_management;

-- Insert sample products with qty_on_hand higher than reorder_level
INSERT INTO product (product_id, supplier_id, name, description, price, reorder_level, qty_on_hand) VALUES
('PROD-001', 'SUPP-001', 'Wireless Headphones', 'Premium wireless headphones with noise cancellation', 99.99, 10, 25),
('PROD-002', 'SUPP-001', 'Bluetooth Speaker', 'Portable bluetooth speaker with 12-hour battery', 49.99, 5, 18),
('PROD-003', 'SUPP-002', 'Laptop Stand', 'Adjustable aluminum laptop stand for better ergonomics', 29.99, 15, 40),
('PROD-004', 'SUPP-002', 'USB-C Cable', 'High-speed USB-C charging and data cable 6ft', 12.99, 25, 75),
('PROD-005', 'SUPP-003', 'Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 24.99, 8, 20)
ON CONFLICT (product_id) DO NOTHING;

-- Connect to retail_operations database and insert customer orders
\c retail_operations;

-- Insert customer orders
INSERT INTO customer_order (order_id, customer_id, order_date) VALUES
('ORD-001', 'CUST-001', '2025-01-15 10:30:00'),
('ORD-002', 'CUST-002', '2025-01-15 14:45:00'),
('ORD-003', 'CUST-003', '2025-01-16 09:15:00')
ON CONFLICT (order_id) DO NOTHING;

-- Insert customer order items
-- Order 1: Customer ordered headphones and speaker
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) VALUES
('ITEM-001', 'ORD-001', 'PROD-001', 2, 99.99),
('ITEM-002', 'ORD-001', 'PROD-002', 1, 49.99)
ON CONFLICT (id) DO NOTHING;

-- Order 2: Customer ordered laptop stand and cables
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) VALUES
('ITEM-003', 'ORD-002', 'PROD-003', 1, 29.99),
('ITEM-004', 'ORD-002', 'PROD-004', 3, 12.99)
ON CONFLICT (id) DO NOTHING;

-- Order 3: Customer ordered wireless mouse and more cables
INSERT INTO customer_order_item (id, order_id, product_id, quantity, price) VALUES
('ITEM-005', 'ORD-003', 'PROD-005', 1, 24.99),
('ITEM-006', 'ORD-003', 'PROD-004', 2, 12.99),
('ITEM-007', 'ORD-003', 'PROD-001', 1, 99.99)
ON CONFLICT (id) DO NOTHING;