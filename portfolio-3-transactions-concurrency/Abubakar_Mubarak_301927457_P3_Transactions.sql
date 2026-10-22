-- Muhab Gadget Store: transaction scenarios (Portfolio 3)
-- Student: Abubakar Mubarak (301927457)
-- Expected: exactly 3 ERROR lines (in T3 and T4). They are part of the demonstration.

\echo '=== T1: successful order with COMMIT ==='
SELECT product_id, name, stock_qty FROM products WHERE product_id = 16;

BEGIN;
INSERT INTO orders (customer_id, address_id, status)
VALUES (8, 9, 'paid') RETURNING order_id \gset
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, product_id, 2, unit_price FROM products WHERE product_id = 16;
UPDATE products SET stock_qty = stock_qty - 2 WHERE product_id = 16;
INSERT INTO payments (order_id, amount, method, status)
VALUES (:order_id, 19000, 'card', 'successful');
COMMIT;

\echo '--- after COMMIT: stock reduced by 2, and the order exists with its item and payment ---'
SELECT product_id, name, stock_qty FROM products WHERE product_id = 16;
SELECT o.order_id, o.status, oi.product_id, oi.quantity, p.amount, p.status AS payment
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments p     ON p.order_id  = o.order_id
WHERE o.order_id = :order_id;

\echo '=== T2: mistake undone with ROLLBACK ==='
SELECT COUNT(*) AS pending_before FROM orders WHERE status = 'pending';

BEGIN;
UPDATE orders SET status = 'cancelled' WHERE status = 'pending';
SELECT COUNT(*) AS pending_inside_transaction FROM orders WHERE status = 'pending';
ROLLBACK;

\echo '--- after ROLLBACK: the pending orders are back ---'
SELECT COUNT(*) AS pending_after FROM orders WHERE status = 'pending';

\echo '=== T3: atomicity - ordering 2 Redmi phones when only 1 is in stock ==='
SELECT product_id, name, stock_qty FROM products WHERE product_id = 5;
SELECT COUNT(*) AS orders_before FROM orders;

BEGIN;
INSERT INTO orders (customer_id, address_id, status)
VALUES (8, 9, 'pending') RETURNING order_id \gset
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, product_id, 2, unit_price FROM products WHERE product_id = 5;
UPDATE products SET stock_qty = stock_qty - 2 WHERE product_id = 5;   -- ERROR: stock would be -1
INSERT INTO payments (order_id, amount, method, status)
VALUES (:order_id, 420000, 'card', 'successful');                     -- ERROR: transaction already aborted
ROLLBACK;

\echo '--- after ROLLBACK: no half-finished order was left behind ---'
SELECT product_id, name, stock_qty FROM products WHERE product_id = 5;
SELECT COUNT(*) AS orders_after FROM orders;

\echo '=== T4: SAVEPOINT - keep the FreePods, drop the out-of-stock iPad ==='
BEGIN;
INSERT INTO orders (customer_id, address_id, status)
VALUES (8, 9, 'pending') RETURNING order_id \gset
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, product_id, 1, unit_price FROM products WHERE product_id = 12;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 12;

SAVEPOINT before_ipad;
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, product_id, 1, unit_price FROM products WHERE product_id = 10;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 10;  -- ERROR: iPad stock is 0
ROLLBACK TO SAVEPOINT before_ipad;
COMMIT;

\echo '--- after COMMIT: the order contains only the FreePods ---'
SELECT oi.order_id, p.name, oi.quantity
FROM order_items oi JOIN products p ON p.product_id = oi.product_id
WHERE oi.order_id = :order_id;
SELECT product_id, name, stock_qty FROM products WHERE product_id IN (10, 12);
