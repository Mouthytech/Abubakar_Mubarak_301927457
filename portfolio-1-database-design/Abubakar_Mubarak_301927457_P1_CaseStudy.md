# Portfolio 1: Case Study – Muhab Gadget Store

**Student:** Abubakar Mubarak (301927457)
**Course:** MIT 8103 Advanced Database Systems

## Organisation
Muhab is a simulated online store that sells consumer gadgets: smartphones, laptops,
tablets, smartwatches, earbuds, power banks and accessories. Customers browse the
catalogue, place orders, pay online or on delivery, and receive items through a
delivery partner. The database is the central record for the catalogue, stock,
orders, payments and deliveries.

## Users of the database
- **Customers** – register, save delivery addresses, browse products, place orders, track deliveries, leave reviews.
- **Store administrators** – add and update products and prices, manage categories and brands, view sales reports.
- **Inventory staff** – record incoming stock, adjust quantities, monitor low-stock items.
- **Customer support** – look up orders, handle cancellations and refunds.
- **Delivery partners** – update delivery status.

## Major data stored
- Customers and their delivery addresses
- Categories and brands
- Products, whose specifications differ by type (a phone has storage and screen size; earbuds have battery life and noise cancellation)
- Stock quantity for each product
- Orders and the items in each order
- Payments and refunds
- Deliveries and their status
- Product reviews and ratings

## Key operations
1. Add or update a product and its specifications.
2. Search the catalogue by category, brand and price range.
3. Place an order: check stock, reduce stock, and create the order and its items as one transaction.
4. Record a payment, or refund a cancelled order.
5. Update and track delivery status.
6. Produce reports: best-selling products, monthly revenue, low-stock alerts.

## Why this case study suits the portfolio
- **P1 Design:** clear entities with one-to-many and many-to-many relationships (orders and products are linked through order items).
- **P2 Queries:** realistic reports (sales by category, customer order history) that benefit from indexing.
- **P3 Transactions:** two customers trying to buy the last unit of a phone at the same time is a natural concurrency problem.
- **P4 NoSQL:** gadget specifications vary by product type, which suits a document model.
- **P5 Distributed:** a growing store needs replication for availability and could partition order data as volume grows.
