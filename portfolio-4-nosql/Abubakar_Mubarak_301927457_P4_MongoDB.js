// Muhab Gadget Store: MongoDB implementation (Portfolio 4)
// Student: Abubakar Mubarak (301927457)
// Run: mongosh --quiet muhab --file Abubakar_Mubarak_301927457_P4_MongoDB.js
// Specifications are illustrative sample data for the case study.

db.products.drop();
db.carts.drop();

// Helper: summarise a query plan
function showExplain(label, cursor) {
  const e = cursor.explain("executionStats");
  let p = e.queryPlanner.winningPlan;
  p = p.queryPlan || p;
  const stages = [];
  while (p) { stages.push(p.stage); p = p.inputStage; }
  print(label + ": stages = " + stages.join(" <- ") +
        " | docsExamined = " + e.executionStats.totalDocsExamined +
        " | keysExamined = " + e.executionStats.totalKeysExamined +
        " | returned = " + e.executionStats.nReturned);
}

print("=== 1. Create products collection with a validation rule ===");
db.createCollection("products", {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["sku", "name", "brand", "category", "price", "specs"],
    properties: {
      sku:   { bsonType: "string" },
      price: { bsonType: "number", minimum: 1 },
      specs: { bsonType: "object" }
    }
  }}
});
db.products.createIndex({ sku: 1 }, { unique: true, name: "uniq_sku" });
print("products collection created with $jsonSchema validator and unique index on sku");

print("\n=== 2. Insert 16 product documents (each category has different specs) ===");
const result = db.products.insertMany([
  { sku: "APL-IP15-128", name: "iPhone 15 128GB", brand: "Apple", category: "Smartphones", price: 950000,
    specs: { storage_gb: 128, ram_gb: 6, screen_in: 6.1, camera_mp: 48, battery_mah: 3349, os: "iOS 17", network: "5G" },
    colours: ["Black", "Blue", "Pink"],
    reviews: [ { customer: "Aisha B.", rating: 5, comment: "Battery lasts all day." } ] },
  { sku: "SAM-S24-256", name: "Samsung Galaxy S24 256GB", brand: "Samsung", category: "Smartphones", price: 820000,
    specs: { storage_gb: 256, ram_gb: 8, screen_in: 6.2, camera_mp: 50, battery_mah: 4000, os: "Android 14", network: "5G" },
    colours: ["Black", "Grey", "Violet"],
    reviews: [ { customer: "Blessing O.", rating: 5, comment: "Excellent camera." } ] },
  { sku: "TEC-CAM30-256", name: "Tecno Camon 30 256GB", brand: "Tecno", category: "Smartphones", price: 285000,
    specs: { storage_gb: 256, ram_gb: 8, screen_in: 6.78, camera_mp: 50, battery_mah: 5000, os: "Android 14", network: "4G" },
    colours: ["Black", "Green"] },
  { sku: "INF-HOT40-128", name: "Infinix Hot 40 128GB", brand: "Infinix", category: "Smartphones", price: 165000,
    specs: { storage_gb: 128, ram_gb: 8, screen_in: 6.78, camera_mp: 50, battery_mah: 5000, os: "Android 13", network: "4G" } },
  { sku: "XIA-RN13-128", name: "Redmi Note 13 128GB", brand: "Xiaomi", category: "Smartphones", price: 210000,
    specs: { storage_gb: 128, ram_gb: 6, screen_in: 6.67, camera_mp: 108, battery_mah: 5000, os: "Android 13", network: "4G" } },
  { sku: "APL-MBA-M3", name: "MacBook Air M3 13-inch", brand: "Apple", category: "Laptops", price: 1650000,
    specs: { cpu: "Apple M3", ram_gb: 8, storage_gb: 256, screen_in: 13.6, weight_kg: 1.24, os: "macOS" } },
  { sku: "HP-PAV15-I5", name: "HP Pavilion 15 Core i5", brand: "HP", category: "Laptops", price: 780000,
    specs: { cpu: "Intel Core i5", ram_gb: 8, storage_gb: 512, screen_in: 15.6, weight_kg: 1.75, os: "Windows 11" },
    reviews: [ { customer: "Emeka O.", rating: 4, comment: "Good laptop for work." } ] },
  { sku: "LEN-IDP5-R7", name: "Lenovo IdeaPad 5 Ryzen 7", brand: "Lenovo", category: "Laptops", price: 720000,
    specs: { cpu: "AMD Ryzen 7", ram_gb: 16, storage_gb: 512, screen_in: 14, weight_kg: 1.46, os: "Windows 11" } },
  { sku: "SAM-TABA9-64", name: "Samsung Galaxy Tab A9 64GB", brand: "Samsung", category: "Tablets", price: 195000,
    specs: { storage_gb: 64, ram_gb: 4, screen_in: 8.7, battery_mah: 5100, stylus_support: false } },
  { sku: "APL-IPAD10-64", name: "iPad 10th Gen 64GB", brand: "Apple", category: "Tablets", price: 540000,
    specs: { storage_gb: 64, chip: "A14 Bionic", screen_in: 10.9, stylus_support: true } },
  { sku: "APL-APP2", name: "AirPods Pro 2", brand: "Apple", category: "Audio", price: 250000,
    specs: { fit: "in-ear", noise_cancelling: true, playtime_hours: 6, connector: "USB-C", water_resistance: "IP54" },
    colours: ["White"],
    reviews: [ { customer: "Aisha B.", rating: 4, comment: "Great sound, a bit pricey." } ] },
  { sku: "ORA-FP4", name: "Oraimo FreePods 4", brand: "Oraimo", category: "Audio", price: 28000,
    specs: { fit: "in-ear", noise_cancelling: true, playtime_hours: 5, connector: "USB-C" },
    reviews: [ { customer: "Emeka O.", rating: 3, comment: "Decent for the price." } ] },
  { sku: "SAM-GW6-44", name: "Galaxy Watch 6 44mm", brand: "Samsung", category: "Wearables", price: 310000,
    specs: { display: "AMOLED", heart_rate: true, gps: true, battery_days: 2, water_resistance: "5ATM" },
    colours: ["Graphite", "Silver"] },
  { sku: "XIA-SB8", name: "Xiaomi Smart Band 8", brand: "Xiaomi", category: "Wearables", price: 45000,
    specs: { display: "AMOLED", heart_rate: true, gps: false, battery_days: 16, water_resistance: "5ATM" },
    reviews: [ { customer: "Aisha B.", rating: 4, comment: "Accurate step count." } ] },
  { sku: "ANK-PC-20K", name: "Anker PowerCore 20000mAh", brand: "Anker", category: "Accessories", price: 52000,
    specs: { capacity_mah: 20000, output_w: 20, ports: ["USB-C", "USB-A", "USB-A"] },
    reviews: [ { customer: "Aisha B.", rating: 5, comment: "Very reliable power bank." } ] },
  { sku: "ORA-CHG-20W", name: "Oraimo 20W USB-C Charger", brand: "Oraimo", category: "Accessories", price: 9500,
    specs: { output_w: 20, ports: ["USB-C"], fast_charge: "PD 3.0" },
    reviews: [ { customer: "Emeka O.", rating: 5, comment: "Charges quickly." } ] }
]);
print("Inserted documents: " + Object.keys(result.insertedIds).length);

print("\nOne full document (smartphone):");
printjson(db.products.findOne({ sku: "TEC-CAM30-256" }, { _id: 0 }));
print("\nOne full document (power bank) - completely different specs:");
printjson(db.products.findOne({ sku: "ANK-PC-20K" }, { _id: 0 }));

print("\n=== Validation tests (both should be rejected) ===");
try { db.products.insertOne({ name: "Mystery Gadget", price: -5 }); }
catch (e) { print("Rejected as expected (validator): " + e.message); }
try { db.products.insertOne({ sku: "ORA-FP4", name: "Duplicate", brand: "X", category: "Audio", price: 100, specs: {} }); }
catch (e) { print("Rejected as expected (duplicate sku): " + e.message); }

print("\n=== 3. Queries on specifications ===");
print("Q1. Smartphones with at least 8GB RAM and a 5000mAh battery:");
printjson(db.products.find(
  { category: "Smartphones", "specs.ram_gb": { $gte: 8 }, "specs.battery_mah": { $gte: 5000 } },
  { _id: 0, name: 1, price: 1, "specs.ram_gb": 1, "specs.battery_mah": 1 }).toArray());

print("\nQ2. Anything with noise cancelling:");
printjson(db.products.find({ "specs.noise_cancelling": true }, { _id: 0, name: 1, price: 1 }).toArray());

print("\nQ3. Products that have a CPU field (only laptops do):");
printjson(db.products.find({ "specs.cpu": { $exists: true } }, { _id: 0, name: 1, "specs.cpu": 1, "specs.ram_gb": 1 }).toArray());

print("\nQ4. Products available in Black (array match):");
printjson(db.products.find({ colours: "Black" }, { _id: 0, name: 1, colours: 1 }).toArray());

print("\n=== 4. Aggregations ===");
print("A1. Number of products and price range per category:");
printjson(db.products.aggregate([
  { $group: { _id: "$category", products: { $sum: 1 },
              avg_price: { $round: [{ $avg: "$price" }, 0] },
              min_price: { $min: "$price" }, max_price: { $max: "$price" } } },
  { $sort: { avg_price: -1 } }
]).toArray());

print("\nA2. Average rating per product from embedded reviews:");
printjson(db.products.aggregate([
  { $unwind: "$reviews" },
  { $group: { _id: "$name", avg_rating: { $avg: "$reviews.rating" }, reviews: { $sum: 1 } } },
  { $sort: { avg_rating: -1, _id: 1 } }
]).toArray());

print("\n=== 5. Schema evolution: add new specs to one phone only ===");
db.products.updateOne({ sku: "XIA-RN13-128" }, { $set: { "specs.nfc": true, "specs.charging_w": 33 } });
printjson(db.products.findOne({ sku: "XIA-RN13-128" }, { _id: 0, name: 1, specs: 1 }));

print("\n=== 6. Index: query plan before and after ===");
const phoneQuery = { category: "Smartphones", "specs.ram_gb": { $gte: 8 } };
showExplain("Before index", db.products.find(phoneQuery));
db.products.createIndex({ category: 1, "specs.ram_gb": 1 }, { name: "idx_category_ram" });
showExplain("After index ", db.products.find(phoneQuery));
print("Indexes on products: " + db.products.getIndexes().map(i => i.name).join(", "));

print("\n=== 7. Key-value style: shopping carts (key = customer) ===");
db.carts.createIndex({ updated_at: 1 }, { expireAfterSeconds: 604800, name: "ttl_cart_7_days" });
const cartKey = "cart:customer:25";
db.carts.updateOne({ _id: cartKey },
  { $push: { items: { sku: "APL-APP2", qty: 1 } }, $set: { updated_at: new Date() } }, { upsert: true });
db.carts.updateOne({ _id: cartKey },
  { $push: { items: { sku: "ANK-PC-20K", qty: 2 } }, $set: { updated_at: new Date() } });
print("Cart after adding two items:");
printjson(db.carts.findOne({ _id: cartKey }));
db.carts.updateOne({ _id: cartKey },
  { $pull: { items: { sku: "APL-APP2" } }, $set: { updated_at: new Date() } });
print("Cart after removing AirPods:");
printjson(db.carts.findOne({ _id: cartKey }));
showExplain("Cart lookup by key", db.carts.find({ _id: cartKey }));
print("Carts not updated for 7 days are deleted automatically by the TTL index.");