-- Session A (customer Aisha). Run step by step alongside Session B. Product 5 = Redmi Note 13.

-- DEMO 1: lost update (the problem)
UPDATE products SET stock_qty = 1 WHERE product_id = 5;        -- A1 reset
BEGIN;                                                         -- A2
SELECT stock_qty FROM products WHERE product_id = 5;           -- A3 sees 1
UPDATE products SET stock_qty = 0 WHERE product_id = 5;        -- A6 app-calculated value
COMMIT;                                                        -- A8 releases B

-- DEMO 2: SELECT ... FOR UPDATE (pessimistic locking)
UPDATE products SET stock_qty = 1 WHERE product_id = 5;        -- A1 reset
BEGIN;                                                         -- A2
SELECT stock_qty FROM products WHERE product_id = 5 FOR UPDATE; -- A3 locks the row
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 5; -- A6
COMMIT;                                                        -- A7 releases B

-- DEMO 3: REPEATABLE READ
UPDATE products SET stock_qty = 1 WHERE product_id = 5;        -- A1 reset
BEGIN ISOLATION LEVEL REPEATABLE READ;                         -- A2
SELECT stock_qty FROM products WHERE product_id = 5;           -- A3 sees 1
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 5; -- A6
COMMIT;                                                        -- A7
UPDATE products SET stock_qty = 1 WHERE product_id = 5;        -- A11 reset
