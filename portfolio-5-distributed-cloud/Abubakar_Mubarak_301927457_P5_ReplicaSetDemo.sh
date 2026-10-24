#!/usr/bin/env bash
# Muhab Gadget Store: 3-node MongoDB replica set demo (Portfolio 5)
# Student: Abubakar Mubarak (301927457)
# Shows: replication, majority write concern, reads from secondaries,
#        automatic failover (election), recovery and catch-up.
# Run: bash Abubakar_Mubarak_301927457_P5_ReplicaSetDemo.sh

PORTS="27018 27019 27020"
URI="mongodb://localhost:27018,localhost:27019,localhost:27020/muhab?replicaSet=rs0"
STATUS='rs.status().members.forEach(m => print("  " + m.name + "  " + m.stateStr + (m.health === 1 ? "" : "  (unreachable)")))'

start_node() {
  mongod --replSet rs0 --port "$1" --dbpath "/data/rs0-$1" --bind_ip localhost \
         --wiredTigerCacheSizeGB 0.25 --fork --logpath "/tmp/rs0-$1.log" > /dev/null
  echo "  started mongod on port $1"
}

echo "=== 0. Clean start (stop any old nodes, empty data folders) ==="
for p in $PORTS; do
  mongosh --quiet --port "$p" admin --eval 'db.adminCommand({shutdown: 1, force: true})' > /dev/null 2>&1
done
sleep 2
for p in $PORTS; do rm -rf "/data/rs0-$p"; mkdir -p "/data/rs0-$p"; done
echo "  done"

echo; echo "=== 1. Start three MongoDB nodes (ports 27018, 27019, 27020) ==="
for p in $PORTS; do start_node "$p"; done

echo; echo "=== 2. Initiate replica set rs0 and wait for an election ==="
mongosh --quiet --port 27018 --eval 'printjson(rs.initiate({_id: "rs0", members: [
  {_id: 0, host: "localhost:27018"}, {_id: 1, host: "localhost:27019"}, {_id: 2, host: "localhost:27020"}]}))'
P=""
for i in $(seq 1 30); do
  P=$(mongosh --quiet --port 27018 --eval 'print(db.hello().primary || "")' 2>/dev/null)
  [ -n "$P" ] && break
  sleep 1
done
echo "  primary elected: $P"
sleep 3
mongosh --quiet --port 27018 --eval "$STATUS"

echo; echo "=== 3. Write catalogue documents to the primary with writeConcern majority ==="
mongosh --quiet "$URI" --eval '
const r = db.products.insertMany([
  { sku: "APL-IP15-128",  name: "iPhone 15 128GB",      category: "Smartphones", price: 950000 },
  { sku: "TEC-CAM30-256", name: "Tecno Camon 30 256GB", category: "Smartphones", price: 285000 },
  { sku: "ORA-FP4",       name: "Oraimo FreePods 4",    category: "Audio",       price: 28000 }
], { writeConcern: { w: "majority", wtimeout: 5000 } });
print("  inserted " + Object.keys(r.insertedIds).length + " documents on primary " + db.hello().primary + " (acknowledged by a majority)");'
sleep 1

echo; echo "=== 4. Read from every node: the data has been replicated ==="
for p in $PORTS; do
  mongosh --quiet --port "$p" muhab --eval 'db.getMongo().setReadPref("secondaryPreferred");
    const h = db.hello();
    print("  " + h.me + "  " + (h.isWritablePrimary ? "PRIMARY  " : "SECONDARY") + "  products = " + db.products.countDocuments({}));'
done

echo; echo "=== 5. Failover: shut down the primary ==="
OLD=$(mongosh --quiet "$URI" --eval 'print(db.hello().primary)')
OLDPORT=${OLD##*:}
echo "  current primary: $OLD -> shutting it down"
mongosh --quiet --port "$OLDPORT" admin --eval 'db.adminCommand({shutdown: 1, force: true})' > /dev/null 2>&1
for p in $PORTS; do [ "$p" != "$OLDPORT" ] && SURVIVOR=$p && break; done
START=$(date +%s)
NEW=""
for i in $(seq 1 60); do
  NEW=$(mongosh --quiet --port "$SURVIVOR" --eval 'print(db.hello().primary || "")' 2>/dev/null)
  if [ -n "$NEW" ] && [ "$NEW" != "$OLD" ]; then break; fi
  sleep 1
done
echo "  new primary elected: $NEW (after about $(( $(date +%s) - START )) seconds)"
mongosh --quiet --port "$SURVIVOR" --eval "$STATUS"

echo; echo "=== 6. The shop keeps working: write to the new primary ==="
mongosh --quiet "$URI" --eval '
db.products.insertOne({ sku: "ANK-PC-20K", name: "Anker PowerCore 20000mAh", category: "Accessories", price: 52000 },
                      { writeConcern: { w: "majority", wtimeout: 5000 } });
print("  write accepted by " + db.hello().primary + "; products now = " + db.products.countDocuments({}));'

echo; echo "=== 7. Recovery: restart the old primary; it rejoins as a SECONDARY and catches up ==="
start_node "$OLDPORT"
for i in $(seq 1 30); do
  S=$(mongosh --quiet --port "$OLDPORT" --eval 'print(db.hello().secondary)' 2>/dev/null)
  [ "$S" = "true" ] && break
  sleep 1
done
sleep 2
mongosh --quiet --port "$OLDPORT" muhab --eval 'db.getMongo().setReadPref("secondaryPreferred");
  print("  " + db.hello().me + " is now " + (db.hello().secondary ? "SECONDARY" : "other") + "; products = " + db.products.countDocuments({}) + " (includes the write made while it was down)");'
mongosh --quiet "$URI" --eval "$STATUS"

echo; echo "=== 8. Replication lag of each secondary ==="
mongosh --quiet "$URI" --eval 'rs.printSecondaryReplicationInfo()'