-- Muhab Gadget Store: constraint tests
-- Every statement below is EXPECTED TO FAIL. Each failure proves a rule works.

-- 1. CHECK: price must be positive
INSERT INTO products (category_id, brand_id, sku, name, unit_price, stock_qty)
VALUES (1, 1, 'TEST-NEG', 'Faulty Phone', -100, 5);

-- 2. UNIQUE: two customers cannot share an email
INSERT INTO customers (first_name, last_name, email)
VALUES ('Test', 'User', 'aisha.bello@mail.com');

-- 3. FOREIGN KEY: order for a customer who does not exist
INSERT INTO orders (customer_id, address_id) VALUES (999, 1);

-- 4. CHECK: rating must be between 1 and 5
INSERT INTO reviews (customer_id, product_id, rating) VALUES (3, 3, 6);

-- 5. CHECK: order status must be from the allowed list
UPDATE orders SET status = 'lost' WHERE order_id = 1;

-- 6. CHECK: stock cannot go below zero (Redmi Note 13 has 1 unit)
UPDATE products SET stock_qty = stock_qty - 2 WHERE product_id = 5;

-- 7. UNIQUE: a customer can review a product only once
INSERT INTO reviews (customer_id, product_id, rating) VALUES (1, 1, 3);

-- 8. CHECK: delivery cannot arrive before it was dispatched
INSERT INTO deliveries (order_id, courier_name, status, dispatched_at, delivered_at)
VALUES (7, 'DHL', 'delivered', '2026-10-13 10:00', '2026-10-12 10:00');

-- 9. FOREIGN KEY: cannot delete a customer who has orders
DELETE FROM customers WHERE customer_id = 1;

-- Confirm nothing changed
SELECT product_id, name, stock_qty FROM products WHERE product_id = 5;
SELECT COUNT(*) AS customers FROM customers;
