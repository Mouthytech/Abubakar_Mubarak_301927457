-- Muhab Gadget Store: execution plans before and after indexing (Portfolio 2)
-- Student: Abubakar Mubarak (301927457)

-- Reset: remove the test indexes so the script can be re-run
DROP INDEX IF EXISTS idx_orders_customer_id, idx_orders_order_date,
                     idx_orders_pending_date, idx_order_items_product_qty;
VACUUM ANALYZE;

-- Warm-up so both runs read from memory (fairer comparison)
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

\echo '=================== BEFORE INDEXING ==================='

\echo '=== A BEFORE: order history for customer 25 ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.order_date, o.status, SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = 25
GROUP BY o.order_id ORDER BY o.order_date DESC;

\echo '=== B BEFORE: daily sales, 1 to 7 October 2026 ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_date::date AS day, COUNT(DISTINCT o.order_id) AS orders,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= '2026-10-01' AND o.order_date < '2026-10-08'
  AND o.status <> 'cancelled'
GROUP BY 1 ORDER BY 1;

\echo '=== C BEFORE: oldest pending orders ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.customer_id, o.order_date
FROM orders o
WHERE o.status = 'pending' AND o.order_date < CURRENT_TIMESTAMP - INTERVAL '3 days'
ORDER BY o.order_date LIMIT 10;

\echo '=== D BEFORE: units and revenue for Redmi Note 13 (product 5) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT SUM(quantity) AS units, SUM(quantity * unit_price) AS revenue
FROM order_items WHERE product_id = 5;

\echo '=== E BEFORE: revenue by category (whole table) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p   ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.name ORDER BY revenue DESC;

\echo '=================== CREATING INDEXES ==================='
CREATE INDEX idx_orders_customer_id  ON orders (customer_id);
CREATE INDEX idx_orders_order_date   ON orders (order_date);
CREATE INDEX idx_orders_pending_date ON orders (order_date) WHERE status = 'pending';
CREATE INDEX idx_order_items_product_qty ON order_items (product_id) INCLUDE (quantity, unit_price);
VACUUM ANALYZE;

\echo '=================== AFTER INDEXING ==================='

\echo '=== A AFTER: order history for customer 25 ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.order_date, o.status, SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = 25
GROUP BY o.order_id ORDER BY o.order_date DESC;

\echo '=== B AFTER: daily sales, 1 to 7 October 2026 ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_date::date AS day, COUNT(DISTINCT o.order_id) AS orders,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= '2026-10-01' AND o.order_date < '2026-10-08'
  AND o.status <> 'cancelled'
GROUP BY 1 ORDER BY 1;

\echo '=== C AFTER: oldest pending orders ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.customer_id, o.order_date
FROM orders o
WHERE o.status = 'pending' AND o.order_date < CURRENT_TIMESTAMP - INTERVAL '3 days'
ORDER BY o.order_date LIMIT 10;

\echo '=== D AFTER: units and revenue for Redmi Note 13 (product 5) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT SUM(quantity) AS units, SUM(quantity * unit_price) AS revenue
FROM order_items WHERE product_id = 5;

\echo '=== E AFTER: revenue by category (whole table) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p   ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.name ORDER BY revenue DESC;

\echo '=== Index sizes ==='
SELECT indexrelname AS index_name, pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'idx_%'
ORDER BY indexrelname;
