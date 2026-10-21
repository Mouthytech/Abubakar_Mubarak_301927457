# Portfolio 1: Normalisation – Muhab Gadget Store

## Starting point: an unnormalised order record (UNF)
Before a database, Muhab staff could record a sale as one row per order, like this:

| order_id | order_date | customer | email | phone | delivery_address | products_bought | total |
|---|---|---|---|---|---|---|---|
| 1001 | 2026-10-02 | Aisha Bello | aisha@mail.com | 0803... | 12 Market Rd, Lagos | iPhone 15 (Apple, Smartphones) x1 @ 950000; AirPods Pro (Apple, Audio) x2 @ 250000 | 1450000 |

Problems:
- `products_bought` holds several values in one cell (a repeating group), so you cannot query or index individual products.
- Customer details repeat on every order, so a changed phone number must be updated in many rows (**update anomaly**).
- A new product cannot be recorded until someone buys it (**insertion anomaly**).
- Deleting a customer's only order also deletes the only record of that customer (**deletion anomaly**).
- `total` can disagree with the item prices.

## First Normal Form (1NF)
Rule: every cell holds one atomic value, and there are no repeating groups.

Split the product list so there is one row per product per order. The key becomes **(order_id, product_id)**.

| order_id | product_id | order_date | customer_name | email | product_name | brand | category | quantity | unit_price |
|---|---|---|---|---|---|---|---|---|---|
| 1001 | 7 | 2026-10-02 | Aisha Bello | aisha@mail.com | iPhone 15 | Apple | Smartphones | 1 | 950000 |
| 1001 | 12 | 2026-10-02 | Aisha Bello | aisha@mail.com | AirPods Pro | Apple | Audio | 2 | 250000 |

The table is in 1NF, but order and customer details still repeat on every line.

## Second Normal Form (2NF)
Rule: 1NF, and no non-key attribute depends on only *part* of a composite key.

With key (order_id, product_id):
- `order_date` and the customer details depend on **order_id only** (a partial dependency).
- `product_name`, `brand` and `category` depend on **product_id only** (a partial dependency).
- Only `quantity` and `unit_price` (the price paid) depend on the **whole key**.

Decomposition:
- **ORDERS**(order_id, order_date, customer_name, email, phone, address)
- **PRODUCTS**(product_id, product_name, brand, category, current_price)
- **ORDER_ITEMS**(order_id, product_id, quantity, unit_price)

## Third Normal Form (3NF)
Rule: 2NF, and no transitive dependencies (a non-key attribute depending on another non-key attribute).

- In ORDERS: order_id → customer_id → name, email, phone. Customer details depend on the customer, not the order. Move them to **CUSTOMERS**. A customer can have several delivery addresses, so addresses go to **ADDRESSES**, and orders keep `customer_id` and `address_id`.
- In PRODUCTS: product_id → brand → brand name, and product_id → category → category name. Move these to **BRANDS** and **CATEGORIES**; products keep `brand_id` and `category_id`.
- The `total` column is removed. It is derived from SUM(quantity × unit_price) over order_items, so storing it would create a transitive dependency and a risk of inconsistency.
- Payments, deliveries and reviews are separate facts with their own keys, so they get their own tables.

Result: the 10 tables in the ER diagram.

## Boyce–Codd Normal Form (BCNF) check
Every determinant in the final design is a candidate key. In CUSTOMERS, both `customer_id` and `email` determine the other attributes, and both are keys (email is UNIQUE), so BCNF holds. The same applies to `sku` in PRODUCTS and `tracking_number` in DELIVERIES.

## A value that looks redundant but is not
`order_items.unit_price` looks like a copy of `products.unit_price`, but it records a different fact: the price **when the order was placed**. The product price can change tomorrow without altering what Aisha paid in October. Removing it would make historical revenue reports wrong, so it stays.

## Anomalies resolved
| Anomaly | Before | After |
|---|---|---|
| Update | Phone stored on every order | Stored once in CUSTOMERS |
| Insertion | Product exists only once sold | PRODUCTS stands alone |
| Deletion | Deleting an order loses the customer | Customer row is independent |
