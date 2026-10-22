-- Session B (customer Emeka). Run step by step alongside Session A. Product 5 = Redmi Note 13.

-- DEMO 1: lost update (the problem)
BEGIN;                                                         -- B4
SELECT stock_qty FROM products WHERE product_id = 5;           -- B5 also sees 1
UPDATE products SET stock_qty = 0 WHERE product_id = 5;        -- B7 waits for A's row lock, then overwrites
COMMIT;                                                        -- B9 result: one phone sold twice

-- DEMO 2: SELECT ... FOR UPDATE (pessimistic locking)
BEGIN;                                                         -- B4
SELECT stock_qty FROM products WHERE product_id = 5 FOR UPDATE; -- B5 waits; after A commits, returns 0
ROLLBACK;                                                      -- B8 sold out, so no sale

-- DEMO 3: REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;                         -- B4
SELECT stock_qty FROM products WHERE product_id = 5;           -- B5 sees 1
SELECT stock_qty FROM products WHERE product_id = 5;           -- B8 still 1 (snapshot) after A committed
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 5; -- B9 ERROR: could not serialize access
ROLLBACK;                                                      -- B10
