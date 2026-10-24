# Portfolio 5: Distributed and Cloud Database

**Student:** Abubakar Mubarak (301927457)
**Case study:** Muhab Gadget Store

## Files
| File | Purpose |
|---|---|
| `Abubakar_Mubarak_301927457_P5_ReplicaSetDemo.sh` | Builds a 3-node MongoDB replica set and tests replication, failover and recovery |
| `Abubakar_Mubarak_301927457_P5_ReplicaSetOutput.txt` | Full output of the demo |
| `Abubakar_Mubarak_301927457_P5_DistributedDesign.md` | Replication, availability, consistency, sharding and cloud deployment design |
| `*.png` files | Screenshots of replication and failover |

## How to reproduce
Requires MongoDB 8.0 (see Portfolio 4) and write access to /data:

    sudo chown $(whoami) /data
    bash Abubakar_Mubarak_301927457_P5_ReplicaSetDemo.sh

## Summary of results
- 3-node replica set rs0: one PRIMARY, two SECONDARY.
- Majority-acknowledged writes replicated to all nodes (products = 3 on each).
- Primary shut down: a new primary was elected and writes continued (products = 4).
- Old primary restarted, rejoined as SECONDARY and caught up automatically.
- Replication lag: 0 seconds.
