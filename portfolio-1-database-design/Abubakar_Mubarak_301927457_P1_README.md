# Portfolio 1: Database Design and Modelling

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store, an online retailer of smartphones, laptops, tablets, audio, wearables and accessories.

## Files
| File | Purpose |
|---|---|
| `Abubakar_Mubarak_301927457_P1_CaseStudy.md` | Organisation, users, data and key operations |
| `Abubakar_Mubarak_301927457_P1_ERDiagram.md` / `.png` | ER diagram, relationships, keys and constraints |
| `Abubakar_Mubarak_301927457_P1_Normalisation.md` | UNF to 1NF, 2NF, 3NF and BCNF, with anomalies explained |
| `Abubakar_Mubarak_301927457_P1_Schema.sql` | PostgreSQL schema (10 tables) |
| `Abubakar_Mubarak_301927457_P1_TablesOutput.txt` | Output proving the tables exist |
| `Abubakar_Mubarak_301927457_P1_SampleData.sql` | Sample records plus verification queries |
| `Abubakar_Mubarak_301927457_P1_ConstraintTests.sql` | Invalid operations that the constraints must reject |
| `*Output.txt` and `*.png` files | Captured output and screenshots |

## Environment
PostgreSQL 16 on Ubuntu 24.04, running inside GitHub Codespaces.

## How to reproduce

    sudo service postgresql start
    createdb muhab
    psql -d muhab -f Abubakar_Mubarak_301927457_P1_Schema.sql
    psql -d muhab -f Abubakar_Mubarak_301927457_P1_SampleData.sql
    psql -d muhab -e -f Abubakar_Mubarak_301927457_P1_ConstraintTests.sql

## What was tested and the results
- **Schema:** all 10 tables were created with primary keys, foreign keys, UNIQUE and CHECK constraints.
- **Sample data:** loaded with no errors (8 customers, 16 products, 10 orders, 16 order items, 11 payments, 7 deliveries, 8 reviews). Order totals are calculated from order_items; order 1 totals 1,450,000, matching the normalisation example.
- **Constraint tests:** 9 out of 9 invalid operations were rejected (negative price, duplicate email, non-existent customer, rating of 6, invalid status, negative stock, duplicate review, delivery before dispatch, deleting a customer with orders). The data was unchanged afterwards.

## Key design decisions
- order_items resolves the many-to-many relationship between orders and products, with a composite primary key.
- The price at the time of purchase is stored in order_items, so later price changes do not alter past orders (see order 8, where AirPods were bought on promotion).
- No stored order total, because it is derived data that could become inconsistent.
- Product specifications vary by product type, so they are modelled in MongoDB in Portfolio 4 rather than as many empty columns.
- Foreign keys are deliberately not indexed yet; indexing is measured in Portfolio 2.
