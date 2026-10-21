-- Muhab Gadget Store: sample data
-- Student: Abubakar Mubarak (301927457)
-- Safe to re-run: clears tables and resets IDs first.

TRUNCATE customers, addresses, categories, brands, products, orders,
         order_items, payments, deliveries, reviews RESTART IDENTITY CASCADE;

INSERT INTO categories (name) VALUES
('Smartphones'), ('Laptops'), ('Tablets'), ('Audio'), ('Wearables'), ('Accessories');

INSERT INTO brands (name) VALUES
('Apple'), ('Samsung'), ('Tecno'), ('Infinix'), ('HP'), ('Lenovo'), ('Xiaomi'), ('Oraimo'), ('Anker');

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Aisha',    'Bello',    'aisha.bello@mail.com',    '08031110001'),
('Emeka',    'Okoro',    'emeka.okoro@mail.com',    '08031110002'),
('Fatima',   'Yusuf',    'fatima.yusuf@mail.com',   '08031110003'),
('Tunde',    'Adeyemi',  'tunde.adeyemi@mail.com',  '08031110004'),
('Ngozi',    'Eze',      'ngozi.eze@mail.com',      '08031110005'),
('Ibrahim',  'Sani',     'ibrahim.sani@mail.com',   '08031110006'),
('Blessing', 'Okon',     'blessing.okon@mail.com',  '08031110007'),
('Musa',     'Danjuma',  'musa.danjuma@mail.com',   '08031110008');  -- no orders yet

INSERT INTO addresses (customer_id, street, city, state, is_default) VALUES
(1, '12 Market Road',        'Lagos',         'Lagos',       TRUE),
(1, '5 Allen Avenue',        'Ikeja',         'Lagos',       FALSE),
(2, '8 Zik Avenue',          'Enugu',         'Enugu',       TRUE),
(3, '22 Ahmadu Bello Way',   'Kaduna',        'Kaduna',      TRUE),
(4, '14 Ring Road',          'Ibadan',        'Oyo',         TRUE),
(5, '3 Aba Road',            'Port Harcourt', 'Rivers',      TRUE),
(6, '17 Zoo Road',           'Kano',          'Kano',        TRUE),
(7, '9 Calabar Road',        'Calabar',       'Cross River', TRUE),
(8, '30 Wuse Zone 4',        'Abuja',         'FCT',         TRUE);

INSERT INTO products (category_id, brand_id, sku, name, unit_price, stock_qty) VALUES
(1, 1, 'APL-IP15-128',  'iPhone 15 128GB',              950000,  6),
(1, 2, 'SAM-S24-256',   'Samsung Galaxy S24 256GB',     820000,  8),
(1, 3, 'TEC-CAM30-256', 'Tecno Camon 30 256GB',         285000, 20),
(1, 4, 'INF-HOT40-128', 'Infinix Hot 40 128GB',         165000, 25),
(1, 7, 'XIA-RN13-128',  'Redmi Note 13 128GB',          210000,  1),  -- last unit (P3 test)
(2, 1, 'APL-MBA-M3',    'MacBook Air M3 13-inch',      1650000,  3),
(2, 5, 'HP-PAV15-I5',   'HP Pavilion 15 Core i5',       780000,  5),
(2, 6, 'LEN-IDP5-R7',   'Lenovo IdeaPad 5 Ryzen 7',     720000,  4),
(3, 2, 'SAM-TABA9-64',  'Samsung Galaxy Tab A9 64GB',   195000, 10),
(3, 1, 'APL-IPAD10-64', 'iPad 10th Gen 64GB',           540000,  0),  -- out of stock
(4, 1, 'APL-APP2',      'AirPods Pro 2',                250000, 12),
(4, 8, 'ORA-FP4',       'Oraimo FreePods 4',             28000, 40),
(5, 2, 'SAM-GW6-44',    'Galaxy Watch 6 44mm',          310000,  7),
(5, 7, 'XIA-SB8',       'Xiaomi Smart Band 8',           45000, 30),
(6, 9, 'ANK-PC-20K',    'Anker PowerCore 20000mAh',      52000, 35),
(6, 8, 'ORA-CHG-20W',   'Oraimo 20W USB-C Charger',       9500, 60);

INSERT INTO orders (customer_id, address_id, order_date, status) VALUES
(1, 1, '2026-10-02 10:15', 'delivered'),
(2, 3, '2026-10-03 14:20', 'delivered'),
(3, 4, '2026-10-05 09:05', 'shipped'),
(4, 5, '2026-10-06 18:40', 'cancelled'),
(5, 6, '2026-10-08 11:30', 'paid'),
(1, 2, '2026-10-10 16:00', 'delivered'),
(6, 7, '2026-10-12 12:10', 'pending'),
(7, 8, '2026-10-14 08:45', 'shipped'),
(2, 3, '2026-10-15 19:25', 'delivered'),
(3, 4, '2026-10-18 13:00', 'paid');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 950000), (1, 11, 2, 250000),      -- matches the normalisation example
(2, 7, 1, 780000), (2, 16, 1, 9500),
(3, 3, 1, 285000), (3, 12, 1, 28000),
(4, 13, 1, 310000),
(5, 6, 1, 1650000),
(6, 15, 2, 52000), (6, 14, 1, 45000),
(7, 4, 1, 165000),
(8, 2, 1, 820000), (8, 11, 1, 240000),      -- AirPods bought on promo: price at purchase differs
(9, 12, 2, 28000),
(10, 9, 1, 195000), (10, 16, 2, 9500);

INSERT INTO payments (order_id, amount, method, status, paid_at) VALUES
(1, 1450000, 'card',            'successful', '2026-10-02 10:16'),
(2,  789500, 'bank_transfer',   'successful', '2026-10-03 14:30'),
(3,  313000, 'card',            'failed',     '2026-10-05 09:06'),  -- first attempt failed
(3,  313000, 'card',            'successful', '2026-10-05 09:10'),
(4,  310000, 'card',            'successful', '2026-10-06 18:41'),
(4,  310000, 'card',            'refunded',   '2026-10-07 09:00'),  -- order cancelled
(5, 1650000, 'bank_transfer',   'successful', '2026-10-08 11:45'),
(6,  149000, 'pay_on_delivery', 'successful', '2026-10-11 15:20'),
(8, 1060000, 'card',            'successful', '2026-10-14 08:46'),
(9,   56000, 'card',            'successful', '2026-10-15 19:26'),
(10, 214000, 'bank_transfer',   'successful', '2026-10-18 13:20');

INSERT INTO deliveries (order_id, courier_name, tracking_number, status, dispatched_at, delivered_at) VALUES
(1,  'GIG Logistics', 'GIG-100001', 'delivered',  '2026-10-03 09:00', '2026-10-04 15:30'),
(2,  'DHL',           'DHL-200002', 'delivered',  '2026-10-04 10:00', '2026-10-06 12:00'),
(3,  'GIG Logistics', 'GIG-100003', 'in_transit', '2026-10-06 08:30', NULL),
(6,  'Kwik Delivery', 'KWK-300006', 'delivered',  '2026-10-11 09:00', '2026-10-11 15:15'),
(8,  'DHL',           'DHL-200008', 'in_transit', '2026-10-15 07:50', NULL),
(9,  'Kwik Delivery', 'KWK-300009', 'delivered',  '2026-10-16 10:00', '2026-10-16 14:40'),
(10, 'GIG Logistics', 'GIG-100010', 'preparing',  NULL,               NULL);

INSERT INTO reviews (customer_id, product_id, rating, comment) VALUES
(1, 1,  5, 'Battery lasts all day.'),
(1, 11, 4, 'Great sound, a bit pricey.'),
(1, 15, 5, 'Very reliable power bank.'),
(1, 14, 4, 'Accurate step count.'),
(2, 7,  4, 'Good laptop for work.'),
(2, 16, 5, 'Charges quickly.'),
(2, 12, 3, 'Decent for the price.'),
(7, 2,  5, 'Excellent camera.');

-- Verification: row count per table
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'addresses',   COUNT(*) FROM addresses
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'brands',      COUNT(*) FROM brands
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments',    COUNT(*) FROM payments
UNION ALL SELECT 'deliveries',  COUNT(*) FROM deliveries
UNION ALL SELECT 'reviews',     COUNT(*) FROM reviews;

-- Verification: order totals calculated from order_items (no stored total)
SELECT o.order_id, c.first_name || ' ' || c.last_name AS customer, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.status
ORDER BY o.order_id;
