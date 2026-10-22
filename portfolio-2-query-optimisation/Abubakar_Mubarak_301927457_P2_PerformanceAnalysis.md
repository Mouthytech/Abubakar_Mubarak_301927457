# Portfolio 2: Performance Analysis – Muhab Gadget Store

**Student:** Abubakar Mubarak (301927457)

## Test setup
- PostgreSQL 16 in GitHub Codespaces (2 CPU cores).
- Data: 2,008 customers, 50,010 orders, 100,015 order items, 45,972 payments.
- Each query was run with `EXPLAIN (ANALYZE, BUFFERS)` with no extra indexes, then again after four indexes were created. `VACUUM ANALYZE` was run before each set, so planner statistics were up to date.
- Full plans: `Abubakar_Mubarak_301927457_P2_OptimisationOutput.txt`. Key lines: `..._P2_PlanSummary.txt`.

## Results

| Test | Business question | Index | Before | After | Plan change |
|---|---|---|---|---|---|
| A | Order history for one customer | `orders(customer_id)` | 2.228 ms | 0.271 ms | Seq Scan → Bitmap Index Scan (~8× faster) |
| B | Daily sales, 1–7 Oct 2026 | `orders(order_date)` | 14.538 ms | 18.791 ms | Orders: Seq Scan → Bitmap Index Scan, but join unchanged |
| C | Oldest pending orders | partial: `orders(order_date) WHERE status='pending'` | 3.239 ms | 0.081 ms | Seq Scan + sort → Index Scan with early stop (~40× faster) |
| D | Units and revenue for one product | covering: `order_items(product_id) INCLUDE (quantity, unit_price)` | 5.650 ms | 2.242 ms | Seq Scan → Index Only Scan (~2.5× faster) |
| E | Revenue by category | none | 70.574 ms | 71.039 ms | Seq Scan in both runs |

## Analysis

**A – Indexing a foreign key.** PostgreSQL does not index foreign keys automatically. Before the index, finding customer 25's orders meant reading all 50,010 orders to return 31. With `idx_orders_customer_id`, the planner jumps straight to those 31 rows. The join to `order_items` was already efficient in both runs, because the composite primary key `(order_id, product_id)` starts with `order_id`. The planner's estimate (24 rows) was close to the actual count (31), showing that the statistics were accurate.

**B – An index that did not help the whole query.** The date index worked for its part: the orders step fell from about 2.2 ms (full scan) to about 0.5 ms (bitmap scan of 486 rows). The total did not improve, because the expensive step is the hash join, which still reads all 100,015 `order_items`. The planner could instead look up each of the 486 orders through `order_items_pkey` (a nested loop), but its cost model estimated about 486 index lookups as dearer than one sequential scan. PostgreSQL's default `random_page_cost` assumes slow random disk reads, while here the whole database fits in memory. The 4 ms difference between runs is within normal timing variation, so the honest conclusion is "no gain", not "slower". **Lesson:** an index only helps if it removes the bottleneck step, so the plan must be read as a whole, not just the filter.

**C – Partial index.** Only about 3% of orders are pending. A partial index stores only those rows, so it is 56 kB, compared with 1,112 kB for the full date index. Because the index is already in `order_date` order, `ORDER BY ... LIMIT 10` reads the first 10 entries and stops (actual rows = 10). Before, PostgreSQL read 50,010 rows, kept 1,547 and sorted them. This was the largest gain of all, from the smallest index.

**D – Covering index.** The query needs only `product_id`, `quantity` and `unit_price`. Adding the last two with `INCLUDE` lets PostgreSQL answer entirely from the index (Index Only Scan) without visiting the table. `VACUUM` was needed first, so that the visibility map confirmed the table pages were all-visible. The product appears in about 6% of rows (6,152), a proportion where an ordinary index often loses to a sequential scan. The covering index is what made it worthwhile.

**E – When no index helps.** Revenue by category needs every order item. Reading the whole table sequentially is the cheapest option, and the planner correctly kept the Seq Scan. An index would only add random reads.

## Trade-offs
- **Storage:** the four indexes add about 4.6 MB. The covering index is the largest (3.1 MB), because it stores two extra columns.
- **Write cost:** every new order now updates two extra indexes (three if pending), and every order item updates one more. Muhab inserts orders far less often than staff run lookups, so this is acceptable.
- **Measurement limits:** each figure is a single run on a small, in-memory dataset, so differences of a few milliseconds are noise. Results on disk-based production data would differ in size but likely not in direction.

## Recommendation
Keep A, C and D. Keep B for reports on narrow date ranges, but on its own it does not speed up joined reports. Possible further work: lower `random_page_cost` to reflect SSD or in-memory storage and re-test B, or pre-aggregate daily sales (a materialised view) for reports like B and E.
