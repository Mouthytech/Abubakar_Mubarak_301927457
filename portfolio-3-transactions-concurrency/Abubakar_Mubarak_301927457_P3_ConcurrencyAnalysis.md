# Portfolio 3: Transactions and Concurrency – Analysis

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store

## Why transactions matter for Muhab
Placing an order is not one action. It inserts an order, inserts its items, reduces stock
and records a payment. If any step fails halfway, Muhab could have a paid order with no
items, or stock that was reduced for an order that never existed. Transactions make these
steps behave as a single unit.

## Part A: single-session transactions (ACID in practice)

| Scenario | What was done | Result | ACID property |
|---|---|---|---|
| T1 COMMIT | Order for 2 chargers: order, item, stock update, payment | All four changes saved together; stock 60 → 58 | Atomicity, Durability |
| T2 ROLLBACK | Accidentally cancelled every pending order, then ROLLBACK | Pending count went to 0 inside the transaction, then was fully restored | Atomicity |
| T3 Error | Ordered 2 Redmi phones with 1 in stock | CHECK (stock_qty >= 0) failed; PostgreSQL aborted the transaction and refused further statements; ROLLBACK left no partial order | Consistency, Atomicity |
| T4 SAVEPOINT | Order with FreePods plus an out-of-stock iPad | ROLLBACK TO SAVEPOINT removed only the iPad step; the FreePods order committed | Partial rollback |

T3 is the key result. Without a transaction, the order row and order item would have been
saved before the stock update failed, leaving an orphan order. With a transaction,
`orders_before` equalled `orders_after`.

## Part B: two concurrent sessions, one phone left
Two customers (Session A: Aisha, Session B: Emeka) tried to buy the last Redmi Note 13
(product 5, stock = 1) at the same time.

| Demo | Method | What happened | Outcome |
|---|---|---|---|
| 1 | Read stock, then write a calculated value (READ COMMITTED) | Both read 1. A wrote 0. B's update **waited** for A's row lock, then overwrote it with 0. | **Lost update:** one phone sold twice, with no error raised |
| 2 | SELECT ... FOR UPDATE | A locked the row. B's read **waited** until A committed, then saw 0 and rolled back | One sale only (pessimistic locking) |
| 3 | REPEATABLE READ | B kept seeing stock = 1 (its snapshot) after A committed. B's update failed with *could not serialize access due to concurrent update* | One sale only; B must retry |

### Explanation
- **Demo 1:** PostgreSQL's default level, READ COMMITTED, does lock a row while it is being updated. That is why B froze at step 7. But the application had already decided the new value (0) from a read that was out of date by the time it wrote. The database protected the row, but not the business logic, so the shop oversold.
- **Demo 2:** `FOR UPDATE` takes the lock at **read** time, so B cannot even read the stock until A has finished. B then makes its decision using the true value.
- **Demo 3:** under REPEATABLE READ, each transaction works on a snapshot taken at its first query (MVCC). B's step-8 read still showed 1, which is isolation in action. When B tried to update a row that A had changed since B's snapshot, PostgreSQL rejected it rather than let B overwrite a change it had never seen.

### Comparing the solutions
| Approach | Strength | Cost |
|---|---|---|
| FOR UPDATE | Simple; the second customer gets the correct answer after a short wait | Customers queue behind each other on popular products; risk of deadlocks if rows are locked in different orders |
| REPEATABLE READ | No waiting on reads; consistent snapshot | The application must catch the serialisation error and retry |
| Conditional update: `UPDATE ... SET stock_qty = stock_qty - 1 WHERE product_id = 5 AND stock_qty >= 1` | One statement; if it affects 0 rows, the item is sold out | Needs the application to check the row count |

The CHECK constraint from Portfolio 1 (`stock_qty >= 0`) is a final safety net. Any
update using `stock_qty - 1` can never push stock below zero, as T3 showed. The lost update
in Demo 1 slipped past it only because the application wrote a fixed value (0) instead of
a relative change.

## Recommendation for Muhab
At checkout, use the conditional update (or FOR UPDATE) inside a single transaction that
also inserts the order, items and payment. Keep the CHECK constraint as a safety net.
Use READ COMMITTED for normal browsing, because it is fast and reads never block writes.
