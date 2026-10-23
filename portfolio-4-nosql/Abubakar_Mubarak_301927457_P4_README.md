# Portfolio 4: NoSQL and Advanced Data Models

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store

## Files
| File | Purpose |
|---|---|
| `Abubakar_Mubarak_301927457_P4_MongoDBSource.list` | MongoDB 8.0 apt source (configuration evidence) |
| `Abubakar_Mubarak_301927457_P4_SetupOutput.txt` | Server and shell versions, ping result |
| `Abubakar_Mubarak_301927457_P4_MongoDB.js` | Collections, validation, documents, queries, aggregations, indexes, carts |
| `Abubakar_Mubarak_301927457_P4_MongoDBOutput.txt` | Full output of the script |
| `Abubakar_Mubarak_301927457_P4_NoSQLAnalysis.md` | Suitability analysis and recommended architecture |
| `*.png` files | Screenshots |

## How to reproduce

    mongod --dbpath /data/db --fork --logpath /tmp/mongod.log
    mongosh --quiet muhab --file Abubakar_Mubarak_301927457_P4_MongoDB.js

## Summary of results
- 16 product documents with category-specific specifications; 2 invalid inserts rejected.
- Queries on nested fields, $exists, arrays; aggregations with $group and $unwind.
- New specifications added to one product without any schema change.
- Compound index: documents examined fell from 16 (COLLSCAN) to 3 (IXSCAN).
- Key-value carts: lookup by key via EXPRESS_IXSCAN; TTL index removes carts after 7 days.

## Issue encountered
The first run failed at the aggregation stage with "The $round accumulator is a unary
operator", because $round was placed inside $group, where only accumulators are allowed.
It was fixed by calculating $avg in $group and rounding in a following $set stage
(see the commit history).
