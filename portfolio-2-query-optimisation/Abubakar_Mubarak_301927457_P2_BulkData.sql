-- Muhab Gadget Store: bulk data for performance testing
-- Run AFTER the Portfolio 1 schema and sample data.
-- Adds 2,000 customers and 50,000 orders so execution plans and indexes can be measured.

SELECT setseed(0.42);  -- makes the random data repeatable

-- 2,000 extra customers
INSERT INTO customers (first_name, last_name, email, phone, created_at)
SELECT
  (ARRAY['Aisha','Emeka','Fatima','Tunde','Ngozi','Ibrahim','Blessing','Musa',
         'Chidi','Zainab','Segun','Halima','Kelechi','Amina','Femi','Hauwa'])[1 + g % 16],
  (ARRAY['Bello','Okoro','Yusuf','Adeyemi','Eze','Sani','Okon','Danjuma',
         'Nwosu','Lawal','Balogun','Abdullahi','Obi','Ogunleye'])[1 + g % 14],
  'customer' || g || '@muhab-test.com',
  '0809' || LPAD(g::text, 7, '0'),
  TIMESTAMP '2025-01-01' + (g % 600) * INTERVAL '1 day'
FROM generate_series(1, 2000) AS g;

-- One address per new customer
INSERT INTO addresses (customer_id, street, city, state, is_default)
SELECT c.customer_id,
       (10 + c.customer_id % 90) || ' ' ||
       (ARRAY['Market Road','Station Road','Church Street','Airport Road','Unity Avenue'])[1 + c.customer_id % 5],
       (ARRAY['Lagos','Abuja','Kano','Ibadan','Port Harcourt','Enugu','Kaduna','Benin City'])[1 + c.customer_id % 8],
       (ARRAY['Lagos','FCT','Kano','Oyo','Rivers','Enugu','Kaduna','Edo'])[1 + c.customer_id % 8],
       TRUE
FROM customers c
WHERE c.email LIKE '%@muhab-test.com';

-- 50,000 orders on the new customers' addresses
-- Status mix: 85% delivered, 5% cancelled, 4% shipped, 3% paid, 3% pending
INSERT INTO orders (customer_id, address_id, order_date, status)
SELECT a.customer_id, a.address_id, g.order_date, g.status
FROM (
  SELECT 10 + floor(random() * ((SELECT MAX(address_id) FROM addresses) - 9))::int AS addr,
         TIMESTAMP '2025-01-01' + random() * (TIMESTAMP '2026-10-20' - TIMESTAMP '2025-01-01') AS order_date,
         CASE WHEN r < 0.85 THEN 'delivered'
              WHEN r < 0.90 THEN 'cancelled'
              WHEN r < 0.94 THEN 'shipped'
              WHEN r < 0.97 THEN 'paid'
              ELSE 'pending' END AS status
  FROM (SELECT random() AS r FROM generate_series(1, 50000)) s
) g
JOIN addresses a ON a.address_id = g.addr;

-- 1 to 3 different products per new order, at the current price
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, 1 + floor(random() * 2)::int, p.unit_price
FROM orders o
CROSS JOIN LATERAL (
  SELECT product_id, unit_price FROM products
  ORDER BY random()
  LIMIT 1 + (o.order_id % 3)
) p
WHERE o.order_id > 10;

-- One successful payment for each new paid, shipped or delivered order
INSERT INTO payments (order_id, amount, method, status, paid_at)
SELECT o.order_id,
       SUM(oi.quantity * oi.unit_price),
       (ARRAY['card','bank_transfer','pay_on_delivery'])[1 + o.order_id % 3],
       'successful',
       o.order_date + INTERVAL '10 minutes'
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_id > 10 AND o.status IN ('paid','shipped','delivered')
GROUP BY o.order_id, o.order_date;

-- Refresh planner statistics after the big load
ANALYZE;

-- Row counts after loading
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'addresses',   COUNT(*) FROM addresses
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments',    COUNT(*) FROM payments;
