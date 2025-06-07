-- Inventory Management Database Schema
-- This script creates tables for inventory management
-- Note: Database creation is handled by the init script

-- Products Table
CREATE TABLE IF NOT EXISTS product (
    product_id VARCHAR(50) PRIMARY KEY,
    supplier_id VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    reorder_level INTEGER NOT NULL CHECK (reorder_level >= 0)
);

-- Supplier Orders Table
CREATE TABLE IF NOT EXISTS supplier_order (
    order_id VARCHAR(50) PRIMARY KEY,
    supplier_id VARCHAR(50) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date TIMESTAMP NULL
);

-- Supplier Order Items Table
CREATE TABLE IF NOT EXISTS supplier_order_item (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES supplier_order(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_product_supplier_id ON product(supplier_id);
CREATE INDEX IF NOT EXISTS idx_product_name ON product(name);
CREATE INDEX IF NOT EXISTS idx_supplier_order_supplier_id ON supplier_order(supplier_id);
CREATE INDEX IF NOT EXISTS idx_supplier_order_date ON supplier_order(order_date);
CREATE INDEX IF NOT EXISTS idx_supplier_order_delivery_date ON supplier_order(delivery_date);
CREATE INDEX IF NOT EXISTS idx_supplier_order_item_order_id ON supplier_order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_supplier_order_item_product_id ON supplier_order_item(product_id);