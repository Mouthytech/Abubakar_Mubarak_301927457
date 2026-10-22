# Portfolio 3: Transactions and Concurrency

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store

## Files
| File | Purpose |
|---|---|
| `Abubakar_Mubarak_301927457_P3_Transactions.sql` | T1 commit, T2 rollback, T3 atomicity on error, T4 savepoint |
| `Abubakar_Mubarak_301927457_P3_TransactionsOutput.txt` | Full output (3 deliberate errors in T3 and T4) |
| `Abubakar_Mubarak_301927457_P3_SessionA.sql` | Session A steps for the three concurrency demos |
| `Abubakar_Mubarak_301927457_P3_SessionB.sql` | Session B steps for the three concurrency demos |
| `Abubakar_Mubarak_301927457_P3_ConcurrencyAnalysis.md` | Results, explanation and recommendation |
| `*.png` files | Screenshots of each scenario and both sessions side by side |

## How to reproduce
Part A (one session):

    psql -d muhab -e -f Abubakar_Mubarak_301927457_P3_Transactions.sql

Part B (two sessions): open two terminals, run `psql -d muhab` in each, and type the
numbered steps from SessionA.sql and SessionB.sql in order (A1, A2, A3, B4, B5, ...).

## Summary of results
- COMMIT saved a four-step order as one unit; ROLLBACK fully undid a mass cancellation.
- A failed stock check aborted the whole order, leaving no partial records (atomicity).
- A savepoint removed one failed item while keeping the rest of the order.
- Two sessions buying the last phone caused a lost update under READ COMMITTED.
- SELECT ... FOR UPDATE and REPEATABLE READ each prevented the double sale.
