CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_namename VARCHAR(150),
    phone_number VARCHAR(150),
    email_address VARCHAR(150),
    country VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IS NOT EXISTS products (
    product_sku INT PRIMARY_KEY AUTO_INCREMENT,
    product_name VARCHAR(150),
    unit_price DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS channels (
    channel_id INT PRIMARY KEY AUTO_INCREMENT,
    channel_name VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);




CREATE TABLE IF NOT EXISTS purchase_history AS (
    customer_id INTEGER,
    product_sku INTEGER,
    channel_id INTEGER,
    quantity INT,
    discount DOUBLE DEFAULT 0,
    order_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN_KEY(channel_id) REFERENCES channels(channel_id),
    FOREIGN_KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN_KEY(product_sku) REFERENCES products(product_sku)
);

CREATE TABLE IF NOT EXISTS visit_history AS (
    customer_id INTEGER,
    channel_id INTEGER,
    visit_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bounce_timestamp TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN_KEY(channel_id) REFERENCES channels(channel_id),
    FOREIGN_KEY(customer_id) REFERENCES customers(customer_id)
);

{{ config(materialized = 'table') }}

SELECT 
    SUM(orders.revenue) AS total_revenue
FROM {{ ref('orders') }} AS orders

CREATE PROCEDURE etl_example AS 
BEGIN
    -- Extract data from the sales invoices table
    SELECT * INTO #temp_table FROM `tabSales Invoice`;

    -- Transform the data
    UPDATE #temp_table
    SET last_updated = CURDATE(),
        customer_name = UPPER(customer_name);

    -- Load the data into a target table
    INSERT INTO target_table
    SELECT * FROM #temp_table;

END