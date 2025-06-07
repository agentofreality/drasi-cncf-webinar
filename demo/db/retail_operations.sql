-- Retail Operations Database Schema
-- This script creates tables for retail operations
-- Note: Database creation is handled by the init script

-- Customer Orders Table
CREATE TABLE IF NOT EXISTS customer_order (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer Order Items Table
CREATE TABLE IF NOT EXISTS customer_order_item (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES customer_order(order_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customer_order_customer_id ON customer_order(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_order_date ON customer_order(order_date);
CREATE INDEX IF NOT EXISTS idx_customer_order_item_order_id ON customer_order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_customer_order_item_product_id ON customer_order_item(product_id);