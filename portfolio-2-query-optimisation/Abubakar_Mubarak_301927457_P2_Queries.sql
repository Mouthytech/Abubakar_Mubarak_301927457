-- Muhab Gadget Store: business queries (Portfolio 2)
-- Student: Abubakar Mubarak (301927457)

-- Q1. Customer support: full order history for one customer
SELECT o.order_id, o.order_date, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = 25
GROUP BY o.order_id
ORDER BY o.order_date DESC;

-- Q2. Management: monthly revenue for 2026 (excluding cancelled orders)
SELECT date_trunc('month', o.order_date)::date AS month,
       COUNT(DISTINCT o.order_id)          AS orders,
       SUM(oi.quantity * oi.unit_price)    AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
  AND o.order_date >= '2026-01-01' AND o.order_date < '2026-11-01'
GROUP BY 1
ORDER BY 1;

-- Q3. Merchandising: top 5 best-selling products by units sold
SELECT p.name AS product, b.name AS brand, c.name AS category,
       SUM(oi.quantity)                 AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o     ON o.order_id    = oi.order_id
JOIN products p   ON p.product_id  = oi.product_id
JOIN brands b     ON b.brand_id    = p.brand_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status <> 'cancelled'
GROUP BY p.product_id, p.name, b.name, c.name
ORDER BY units_sold DESC
LIMIT 5;

-- Q4. Management: revenue by category
SELECT c.name AS category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN orders o     ON o.order_id    = oi.order_id
JOIN products p   ON p.product_id  = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status <> 'cancelled'
GROUP BY c.name
ORDER BY revenue DESC;

-- Q5. Marketing: registered customers who have never ordered
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q6. Inventory: low-stock alert (fewer than 5 units)
SELECT sku, name, stock_qty
FROM products
WHERE stock_qty < 5
ORDER BY stock_qty;

-- Q7. Customer support: pending orders older than 3 days (oldest 10)
SELECT o.order_id, c.email, o.order_date
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'pending'
  AND o.order_date < CURRENT_TIMESTAMP - INTERVAL '3 days'
ORDER BY o.order_date
LIMIT 10;

-- Q8. Product team: average rating per reviewed product
SELECT p.name, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(*) AS reviews
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.name
ORDER BY avg_rating DESC, reviews DESC;
