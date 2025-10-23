# MYSQL QUERIES
# Calculate the total net revenue from all orders [assuming net revenue = list_price * quantity * (1 - discount)]
SELECT SUM(list_price*quantity*(1-discount)) AS total_net_revenue
FROM order_items;

# Total sales per store
SELECT 
    s.store_name,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_sales
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

# Top stores by net revenue
WITH first_join AS (
  SELECT 
      s.store_id,
      s.store_name,
      o.order_id
  FROM orders o
  JOIN stores s ON o.store_id = s.store_id
)
SELECT 
    f.store_name,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS net_revenue
FROM first_join f
JOIN order_items oi ON f.order_id = oi.order_id
GROUP BY f.store_name
ORDER BY net_revenue DESC;

# Top 5 best-selling products by quantity
SELECT p.product_name AS products, SUM(oi.quantity) as total_quantity_sold
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

# Top 5 best-selling products by net revenue
SELECT p.product_name, SUM(oi.list_price*oi.quantity - oi.list_price*oi.quantity*oi.discount) as net_revenue
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY net_revenue DESC
LIMIT 5;

# Top 5 customers by average order value (AOV)
SELECT 
  p.product_name, 
  SUM(oi.list_price*oi.quantity - oi.list_price*oi.quantity*oi.discount) AS net_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY net_revenue DESC
LIMIT 5;

# Products that out of stock in all stores
SELECT 
    p.product_name,
    p.product_id,
    MAX(CASE WHEN s.store_id = 1 THEN 1 ELSE 0 END) AS store_1,
    MAX(CASE WHEN s.store_id = 2 THEN 1 ELSE 0 END) AS store_2,
    MAX(CASE WHEN s.store_id = 3 THEN 1 ELSE 0 END) AS store_3
FROM products p
LEFT JOIN stocks s ON p.product_id = s.product_id
GROUP BY p.product_name, p.product_id
HAVING 
    MAX(CASE WHEN s.store_id = 1 THEN 1 ELSE 0 END) = 0
    AND MAX(CASE WHEN s.store_id = 2 THEN 1 ELSE 0 END) = 0
    AND MAX(CASE WHEN s.store_id = 3 THEN 1 ELSE 0 END) = 0
ORDER BY p.product_id;

# Inventory value per store
SELECT 
    stores.store_name,
    SUM(stocks.quantity * products.list_price) AS total_inventory_value
FROM stocks
JOIN products ON stocks.product_id = products.product_id
JOIN stores ON stocks.store_id = stores.store_id
GROUP BY stores.store_name
ORDER BY total_inventory_value DESC;

# Staff members who haven't processed any orders
SELECT 
    s.first_name,
    s.last_name
FROM staffs s
LEFT JOIN orders o ON s.staff_id = o.staff_id
WHERE o.order_id IS NULL;

# List customers who have never placed an order
SELECT 
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

# List customers who have placed orde
SELECT 
    c.first_name, c.last_name,
    COUNT(o.customer_id) as times_of_order
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC;

# Most expensive products in each category
SELECT 
    c.category_name,
    p.product_name,
    p.list_price AS max_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN (
    SELECT 
        category_id, 
        MAX(list_price) AS max_price
    FROM products
    GROUP BY category_id
) AS max_per_cat 
  ON p.category_id = max_per_cat.category_id 
  AND p.list_price = max_per_cat.max_price
ORDER BY max_price DESC;

# Month-over-month sales growth
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;