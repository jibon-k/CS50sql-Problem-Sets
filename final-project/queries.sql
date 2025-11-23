-- ---------- SAMPLE DATA ----------
PRAGMA foreign_keys = ON;
-- Suppliers
INSERT INTO "suppliers" ("id", "name", "contact_email") VALUES
(1, 'ToyCo Suppliers', 'contact@toyco.example'),
(2, 'Fun Imports', 'sales@funimports.example');

-- Categories
INSERT INTO "categories" ("id", "name") VALUES
(1, 'Action Figures'),
(2, 'Board Games'),
(3, 'Puzzles'),
(4, 'Educational');

-- Products
INSERT INTO "products" ("id", "sku", "name", "supplier_id", "category_id", "price_cents") VALUES
(1, 'SKU-A001', 'Action Hero 12in', 1, 1, 1999),
(2, 'SKU-A002', 'Action Sidekick 8in', 1, 1, 1299),
(3, 'SKU-B001', 'Family Board Game', 2, 2, 3499),
(4, 'SKU-C001', '1000pc Puzzle', 2, 3, 1599),
(5, 'SKU-D001', 'Learning Blocks', 1, 4, 2499);

-- Warehouses
INSERT INTO "warehouses" ("id", "name", "address") VALUES
(1, 'Dhaka Warehouse', 'Mirpur, Dhaka'),
(2, 'Secondary Warehouse', 'Gulshan, Dhaka');

-- Inventory
INSERT INTO "inventory" ("id", "product_id", "warehouse_id", "quantity") VALUES
(1, 1, 1, 50),
(2, 2, 1, 30),
(3, 3, 2, 20),
(4, 4, 2, 15),
(5, 5, 1, 10);

-- Customers
INSERT INTO "customers" ("id", "email", "name") VALUES
(1, 'alice@example.com', 'Alice'),
(2, 'bob@example.com', 'Bob'),
(3, 'carol@example.com', 'Carol');

-- Addresses
INSERT INTO "addresses" ("id", "customer_id", "line1", "city", "postal_code", "country") VALUES
(1, 1, 'House 12, Road 3', 'Dhaka', '1207', 'Bangladesh'),
(2, 2, 'House 55, Road 2', 'Dhaka', '1212', 'Bangladesh');

-- Sessions (marketing attribution)
INSERT INTO "sessions" ("id", "customer_id", "started_at", "marketing_channel") VALUES
(1, 1, '2026-05-10 10:00:00', 'organic'),
(2, 2, '2026-05-15 12:00:00', 'facebook_ads'),
(3, 3, '2026-06-01 09:00:00', 'email_campaign');

-- Orders and items
INSERT INTO "orders" ("id", "customer_id", "order_date", "total_cents", "status", "session_id") VALUES
(1, 1, '2026-05-10 10:10:00', 3298, 'completed', 1),
(2, 2, '2026-05-15 12:20:00', 3499, 'completed', 2),
(3, 1, '2026-06-05 14:00:00', 1999, 'completed', 1);

INSERT INTO "order_items" ("id", "order_id", "product_id", "unit_price_cents", "quantity", "discount_cents") VALUES
(1, 1, 1, 1999, 1, 0),
(2, 1, 2, 1299, 1, 0),
(3, 2, 3, 3499, 1, 0),
(4, 3, 1, 1999, 1, 0);

-- Payments
INSERT INTO "payments" ("id", "order_id", "amount_cents", "method", "status", "paid_at") VALUES
(1, 1, 3298, 'card', 'succeeded', '2026-05-10 10:11:00'),
(2, 2, 3499, 'paypal', 'succeeded', '2026-05-15 12:21:00'),
(3, 3, 1999, 'card', 'succeeded', '2026-06-05 14:01:00');

-- Shipments
INSERT INTO "shipments" ("id", "order_id", "warehouse_id", "carrier", "tracking_code", "shipped_at", "delivered_at") VALUES
(1, 1, 1, 'LocalCarrier', 'TRK001', '2026-05-11 08:00:00', '2026-05-13 09:30:00'),
(2, 2, 2, 'LocalCarrier', 'TRK002', '2026-05-16 09:00:00', '2026-05-18 10:00:00'),
(3, 3, 1, 'LocalCarrier', 'TRK003', '2026-06-06 08:00:00', '2026-06-08 10:00:00');

-- Returns
INSERT INTO "returns" ("id", "order_item_id", "reason", "refund_cents", "created_at") VALUES
(1, 2, 'Damaged item', 1299, '2026-05-14 09:00:00'); -- Bob returned product 2

-- Stock movements (sell reduces inventory)
INSERT INTO "stock_movements" ("id", "inventory_id", "delta", "reason", "created_at") VALUES
(1, 1, -1, 'sale order 1', '2026-05-10 10:11:00'),
(2, 2, -1, 'sale order 1', '2026-05-10 10:11:00'),
(3, 3, -1, 'sale order 2', '2026-05-15 12:21:00'),
(4, 1, -1, 'sale order 3', '2026-06-05 14:01:00');

-- Update inventory quantities to reflect movements
UPDATE "inventory" SET "quantity" = "quantity" - 1 WHERE "id" IN (1,2,3,1);

-- ---------- VALIDATION / KPI QUERIES ----------
-- 1. Monthly revenue (use view)
SELECT * FROM "monthly_revenue";

-- 2. Top products by revenue
SELECT
  "p"."id",
  "p"."sku",
  "p"."name",
  SUM(("oi"."unit_price_cents" * "oi"."quantity") - "oi"."discount_cents") AS "revenue_cents",
  SUM("oi"."quantity") AS "units_sold"
FROM "order_items" "oi"
JOIN "products" "p" ON "oi"."product_id" = "p"."id"
GROUP BY "p"."id", "p"."sku", "p"."name"
ORDER BY "revenue_cents" DESC;

-- 3. Repeat customer rate (customers with >1 orders / total customers with orders)
WITH "customer_order_counts" AS (
  SELECT "customer_id", COUNT(*) AS "orders_count"
  FROM "orders"
  GROUP BY "customer_id"
)
SELECT
  SUM(CASE WHEN "orders_count" > 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS "repeat_rate"
FROM "customer_order_counts";

-- 4. Stockouts and low stock alerts (threshold 5)
SELECT
  "p"."id",
  "p"."sku",
  "p"."name",
  "w"."name" AS "warehouse",
  "i"."quantity"
FROM "inventory" "i"
JOIN "products" "p" ON "i"."product_id" = "p"."id"
JOIN "warehouses" "w" ON "i"."warehouse_id" = "w"."id"
WHERE "i"."quantity" <= 5
ORDER BY "i"."quantity" ASC;

-- 5. Returns rate by product
SELECT
  "p"."id",
  "p"."sku",
  "p"."name",
  COUNT("r"."id") AS "returns_count",
  SUM("r"."refund_cents") AS "total_refund_cents"
FROM "returns" "r"
JOIN "order_items" "oi" ON "r"."order_item_id" = "oi"."id"
JOIN "products" "p" ON "oi"."product_id" = "p"."id"
GROUP BY "p"."id", "p"."sku", "p"."name"
ORDER BY "returns_count" DESC;

-- 6. Marketing channel revenue attribution
SELECT
  "s"."marketing_channel",
  COUNT(DISTINCT "o"."id") AS "orders",
  SUM("o"."total_cents") AS "revenue_cents"
FROM "orders" "o"
LEFT JOIN "sessions" "s" ON "o"."session_id" = "s"."id"
GROUP BY "s"."marketing_channel"
ORDER BY "revenue_cents" DESC;

-- 7. Customer lifetime value (basic: total spend per customer)
SELECT
  "c"."id",
  "c"."email",
  "c"."name",
  SUM("o"."total_cents") AS "lifetime_value_cents"
FROM "customers" "c"
LEFT JOIN "orders" "o" ON "c"."id" = "o"."customer_id"
GROUP BY "c"."id", "c"."email", "c"."name"
ORDER BY "lifetime_value_cents" DESC;
