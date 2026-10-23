# Portfolio 4: NoSQL and Advanced Data Models – Analysis

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store
**Environment:** MongoDB 8.0.34 and mongosh 2.13.0 in GitHub Codespaces

## The problem the NoSQL model solves
Muhab's products are not uniform. A smartphone has RAM, storage, camera and battery; a
laptop has a CPU and weight; earbuds have noise cancelling and playtime; a power bank has
capacity and ports. In Portfolio 1 these specifications were deliberately left out of
PostgreSQL. Storing them relationally would need one of these:
- **One wide table:** dozens of columns, most of them NULL for any given product, and a schema change for every new kind of gadget.
- **Entity-attribute-value (EAV):** a table of (product, attribute, value) rows. It is flexible, but every value is stored as text, and simple filters need self-joins.
- **A JSONB column in PostgreSQL:** a reasonable middle ground, noted here as a valid alternative.

A document model stores each product's specifications in the shape that product actually has.

## Models implemented

### 1. Document model: `products` collection
- 16 documents, one per product, with SKUs matching PostgreSQL so both databases describe the same catalogue.
- `specs` is a nested object whose fields differ by category (compare the Tecno and Anker documents in the output).
- `colours` is an array; `reviews` are **embedded** sub-documents.
- **Validation:** a `$jsonSchema` rule requires sku, name, brand, category, price (≥ 1) and specs, and a unique index protects sku. Both invalid inserts were rejected, so the schema is flexible but not uncontrolled.

**Queries demonstrated:** filtering on nested spec fields (Q1: smartphones with ≥ 8 GB RAM and ≥ 5000 mAh), matching a feature only some products have (Q2: noise cancelling), `$exists` to find products with a given attribute (Q3: CPU, so laptops only), array matching (Q4: available in Black), and aggregation pipelines for price per category and average rating using `$unwind` on embedded reviews.

**Schema evolution:** NFC and charging wattage were added to the Redmi Note 13 alone with one `$set`. No migration was needed, and no other document changed.

**Indexing:**

| Query: smartphones with ≥ 8 GB RAM | Plan | Docs examined | Keys examined | Returned |
|---|---|---|---|---|
| Before index | COLLSCAN | 16 | 0 | 3 |
| After compound index `{category: 1, "specs.ram_gb": 1}` | IXSCAN → FETCH | 3 | 3 | 3 |

After indexing, MongoDB examined only the documents it returned, which is the same principle as Portfolio 2: an index on a nested field works just like one on a top-level field.

### 2. Key-value style: `carts` collection
- Key: `_id = "cart:customer:<id>"`. Value: the cart's item list.
- Items are added with `$push` (the cart is created automatically by `upsert`) and removed with `$pull`.
- A lookup by key used **EXPRESS_IXSCAN**, examining 1 key and 1 document, which is MongoDB's fastest path.
- A **TTL index** deletes carts not updated for 7 days, so abandoned carts clean themselves up with no scheduled job.

## Embedding vs referencing
Reviews are embedded because each product here has few reviews and they are always shown with
the product, so one read returns everything. If a popular product collected thousands of
reviews, the document would keep growing (MongoDB's limit is 16 MB per document). Reviews
would then move to their own collection, referencing the product SKU.

## Where MongoDB does NOT fit Muhab
Orders, payments and stock stay in PostgreSQL:
- They need **multi-table consistency**: an order, its items, a stock decrement and a payment must succeed or fail together (Portfolio 3). MongoDB supports multi-document transactions, but the relational model with foreign keys and CHECK constraints enforces these rules structurally.
- Stock needs **row locking** to prevent overselling (Portfolio 3, Demo 2).
- Reporting needs **joins and aggregation** across orders, items, products and customers (Portfolio 2).

Stock was therefore deliberately left out of the MongoDB documents. Storing it in both
databases would create two sources of truth that could disagree.

## Recommended architecture: polyglot persistence
| Data | Database | Reason |
|---|---|---|
| Orders, order items, payments, stock, customers | PostgreSQL | ACID transactions, constraints, joins |
| Product catalogue and specifications | MongoDB (document) | Varied structure, flexible schema, fast browsing and filtering |
| Shopping carts | MongoDB (key-value style) | Lookup by key, frequent changes, automatic expiry |

The SKU links the two systems. Prices are owned by PostgreSQL and copied to the catalogue when they change.

## Other NoSQL models considered
- **Graph** (e.g. Neo4j): suits "customers who bought this also bought..." recommendations, where relationships between customers and products are the main query.
- **Wide-column** (e.g. Cassandra): suits very high-volume, append-only data such as website click and browsing logs.
Neither was implemented, because Muhab's current needs are covered by the document and key-value models.
