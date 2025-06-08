-- Stored Procedures for Drasi CNCF Webinar Demo
-- These procedures support automatic reordering functionality

-- Function to add supplier orders (called by Drasi reactions)
CREATE OR REPLACE FUNCTION public.add_order(
    p_supplier_id VARCHAR(50),
    p_product_id VARCHAR(50), 
    p_quantity INTEGER
) RETURNS VARCHAR(50) AS $$
DECLARE
    v_order_id VARCHAR(50);
    v_product_price DECIMAL(10,2);
    v_product_name VARCHAR(255);
BEGIN
    -- Generate unique order ID
    v_order_id := 'AUTO-' || TO_CHAR(NOW(), 'YYYYMMDD-HH24MISS') || '-' || p_product_id;
    
    -- Get product price for the order item
    SELECT price, name INTO v_product_price, v_product_name
    FROM product 
    WHERE product_id = p_product_id;
    
    -- Check if product exists
    IF v_product_price IS NULL THEN
        RAISE EXCEPTION 'Product % not found', p_product_id;
    END IF;
    
    -- Insert into supplier_order
    INSERT INTO supplier_order (order_id, supplier_id, order_date, delivery_date)
    VALUES (v_order_id, p_supplier_id, NOW(), NULL);
    
    -- Insert into supplier_order_item
    INSERT INTO supplier_order_item (id, order_id, product_id, quantity, price)
    VALUES (
        'ITEM-' || v_order_id, 
        v_order_id, 
        p_product_id, 
        p_quantity, 
        v_product_price
    );
    
    -- Log the automatic reorder for demo visibility
    RAISE NOTICE 'DRASI AUTO-REORDER: Created order % for % units of % (%) with supplier %', 
        v_order_id, p_quantity, v_product_name, p_product_id, p_supplier_id;
        
    -- Return the order ID
    RETURN v_order_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to create supplier order: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to the drasi_replication user
GRANT EXECUTE ON FUNCTION public.add_order(VARCHAR, VARCHAR, INTEGER) TO drasi_replication;

-- Test function (commented out for production)
-- SELECT public.add_order('SUPP-001', 'PROD-001', 20);