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

{{
    config(
        materialized = 'table',
        unique_key = 'author_id',
        sort = 'author_id
    )
}}

WITH book_counts AS (
)