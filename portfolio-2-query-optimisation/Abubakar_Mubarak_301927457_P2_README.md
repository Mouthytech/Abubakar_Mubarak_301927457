# Portfolio 2: Query Processing and Optimisation

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store

## Files
| File | Purpose |
|---|---|
| `Abubakar_Mubarak_301927457_P2_BulkData.sql` | Generates 2,000 customers and 50,000 orders (repeatable with setseed) |
| `Abubakar_Mubarak_301927457_P2_Queries.sql` | Eight business queries (history, revenue, best sellers, stock, follow-ups, ratings) |
| `Abubakar_Mubarak_301927457_P2_Optimisation.sql` | EXPLAIN ANALYZE before and after four indexes |
| `Abubakar_Mubarak_301927457_P2_PlanSummary.txt` | Scan types and execution times extracted from the plans |
| `Abubakar_Mubarak_301927457_P2_PerformanceAnalysis.md` | Results table, analysis, trade-offs, recommendation |
| `*Output.txt` and `*.png` files | Full output and screenshots |

## How to reproduce
Run after the Portfolio 1 schema and sample data:

    psql -d muhab -f Abubakar_Mubarak_301927457_P2_BulkData.sql
    psql -d muhab -e -f Abubakar_Mubarak_301927457_P2_Queries.sql
    psql -d muhab -f Abubakar_Mubarak_301927457_P2_Optimisation.sql

## Summary of results
- Foreign-key index on orders.customer_id: about 8× faster customer history.
- Partial index on pending orders: about 40× faster, and only 56 kB.
- Covering index on order_items: Index Only Scan, about 2.5× faster.
- Date index: improved the filter step, but not the joined report, because the join still scans order_items.
- Whole-table aggregation: sequential scan remains the best plan.
