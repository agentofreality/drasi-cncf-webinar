-- Setup PostgreSQL Logical Replication for Drasi
-- This script creates the necessary users and permissions for Drasi Sources

-- Create a dedicated replication user for Drasi
CREATE USER drasi_replication WITH REPLICATION LOGIN PASSWORD 'drasi_password';

-- Grant necessary permissions to the replication user
GRANT CONNECT ON DATABASE retail_operations TO drasi_replication;
GRANT CONNECT ON DATABASE inventory_management TO drasi_replication;

-- Create replication groups for table ownership management
CREATE ROLE retail_operations_replication;
CREATE ROLE inventory_management_replication;

-- Add the postgres user to both replication groups (since postgres owns the tables)
GRANT retail_operations_replication TO postgres;
GRANT inventory_management_replication TO postgres;

-- Add the Drasi replication user to both replication groups
GRANT retail_operations_replication TO drasi_replication;
GRANT inventory_management_replication TO drasi_replication;

-- Switch to retail_operations database to set up table permissions
\c retail_operations;

-- Grant usage on schema and select on all tables
GRANT USAGE ON SCHEMA public TO drasi_replication;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO drasi_replication;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO drasi_replication;

-- Grant permissions on future tables (in case new tables are created)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO drasi_replication;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO drasi_replication;

-- Transfer table ownership to replication group for retail_operations
ALTER TABLE customer_order OWNER TO retail_operations_replication;
ALTER TABLE customer_order_item OWNER TO retail_operations_replication;

-- Switch to inventory_management database to set up table permissions
\c inventory_management;

-- Grant usage on schema and select on all tables
GRANT USAGE ON SCHEMA public TO drasi_replication;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO drasi_replication;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO drasi_replication;

-- Grant permissions on future tables (in case new tables are created)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO drasi_replication;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO drasi_replication;

-- Transfer table ownership to replication group for inventory_management
ALTER TABLE product OWNER TO inventory_management_replication;
ALTER TABLE supplier_order OWNER TO inventory_management_replication;
ALTER TABLE supplier_order_item OWNER TO inventory_management_replication;

-- Switch back to postgres database
\c postgres;

-- Display confirmation
SELECT 'Drasi replication setup completed successfully!' as status;