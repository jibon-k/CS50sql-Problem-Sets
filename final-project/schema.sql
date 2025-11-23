-- Customers
CREATE TABLE "customers" (
    "id" INTEGER PRIMARY KEY,
    "email" TEXT NOT NULL UNIQUE,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Addresses
CREATE TABLE "addresses" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "line1" TEXT NOT NULL,
    "city" TEXT,
    "postal_code" TEXT,
    "country" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE
);

CREATE INDEX "idx_addresses_customer" ON "addresses"("customer_id");

-- Suppliers
CREATE TABLE "suppliers" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "contact_email" TEXT
);

-- Categories
CREATE TABLE "categories" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE
);

-- Products
CREATE TABLE "products" (
    "id" INTEGER PRIMARY KEY,
    "sku" TEXT NOT NULL UNIQUE,
    "name" TEXT NOT NULL,
    "supplier_id" INTEGER,
    "category_id" INTEGER,
    "price_cents" INTEGER NOT NULL CHECK ("price_cents" >= 0),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

CREATE INDEX "idx_products_category" ON "products"("category_id");
CREATE INDEX "idx_products_supplier" ON "products"("supplier_id");

-- Warehouses
CREATE TABLE "warehouses" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "address" TEXT
);

-- Inventory per warehouse
CREATE TABLE "inventory" (
    "id" INTEGER PRIMARY KEY,
    "product_id" INTEGER NOT NULL,
    "warehouse_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 0 CHECK ("quantity" >= 0),
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE,
    FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE CASCADE,
    UNIQUE ("product_id", "warehouse_id")
);

CREATE INDEX "idx_inventory_product_warehouse" ON "inventory"("product_id","warehouse_id");

-- Stock movements
CREATE TABLE "stock_movements" (
    "id" INTEGER PRIMARY KEY,
    "inventory_id" INTEGER NOT NULL,
    "delta" INTEGER NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("inventory_id") REFERENCES "inventory"("id") ON DELETE CASCADE
);

-- Carts
CREATE TABLE "carts" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "active" BOOLEAN DEFAULT 1,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE
);

CREATE UNIQUE INDEX "idx_one_active_cart_per_customer"
ON "carts"("customer_id") WHERE "active" = 1;

-- Cart items
CREATE TABLE "cart_items" (
    "id" INTEGER PRIMARY KEY,
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    FOREIGN KEY ("cart_id") REFERENCES "carts"("id") ON DELETE CASCADE,
    FOREIGN KEY ("product_id") REFERENCES "products"("id")
);

CREATE INDEX "idx_cart_items_cart" ON "cart_items"("cart_id");

-- Sessions
CREATE TABLE "sessions" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER,
    "started_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "marketing_channel" TEXT
);

CREATE INDEX "idx_sessions_customer" ON "sessions"("customer_id");

-- Orders
CREATE TABLE "orders" (
    "id" INTEGER PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "order_date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "total_cents" INTEGER NOT NULL CHECK ("total_cents" >= 0),
    "status" TEXT NOT NULL CHECK ("status" IN ('pending','paid','shipped','completed','cancelled','refunded')),
    "session_id" INTEGER,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id"),
    FOREIGN KEY ("session_id") REFERENCES "sessions"("id")
);

CREATE INDEX "idx_orders_order_date" ON "orders"("order_date");
CREATE INDEX "idx_orders_customer" ON "orders"("customer_id");

-- Order items
CREATE TABLE "order_items" (
    "id" INTEGER PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "unit_price_cents" INTEGER NOT NULL CHECK ("unit_price_cents" >= 0),
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    "discount_cents" INTEGER NOT NULL DEFAULT 0 CHECK ("discount_cents" >= 0),
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE,
    FOREIGN KEY ("product_id") REFERENCES "products"("id")
);

CREATE INDEX "idx_order_items_order" ON "order_items"("order_id");
CREATE INDEX "idx_order_items_product" ON "order_items"("product_id");

-- Payments
CREATE TABLE "payments" (
    "id" INTEGER PRIMARY KEY,
    "order_id" INTEGER NOT NULL UNIQUE,
    "amount_cents" INTEGER NOT NULL CHECK ("amount_cents" >= 0),
    "method" TEXT NOT NULL CHECK ("method" IN ('card','paypal','bank_transfer','cash')),
    "status" TEXT NOT NULL CHECK ("status" IN ('pending','succeeded','failed','refunded')),
    "paid_at" TIMESTAMP,
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE
);

CREATE INDEX "idx_payments_paid_at" ON "payments"("paid_at");

-- Shipments
CREATE TABLE "shipments" (
    "id" INTEGER PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "warehouse_id" INTEGER,
    "carrier" TEXT,
    "tracking_code" TEXT,
    "shipped_at" TIMESTAMP,
    "delivered_at" TIMESTAMP,
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE,
    FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id")
);

CREATE INDEX "idx_shipments_order" ON "shipments"("order_id");

-- Returns
CREATE TABLE "returns" (
    "id" INTEGER PRIMARY KEY,
    "order_item_id" INTEGER NOT NULL,
    "reason" TEXT,
    "refund_cents" INTEGER NOT NULL CHECK ("refund_cents" >= 0),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("order_item_id") REFERENCES "order_items"("id") ON DELETE CASCADE
);

-- Promotions
CREATE TABLE "promotions" (
    "id" INTEGER PRIMARY KEY,
    "code" TEXT UNIQUE,
    "discount_cents" INTEGER NOT NULL CHECK ("discount_cents" >= 0),
    "valid_from" TIMESTAMP,
    "valid_to" TIMESTAMP
);

CREATE INDEX "idx_promotions_code" ON "promotions"("code");

-- Promotion applied
CREATE TABLE "promotion_applied" (
    "id" INTEGER PRIMARY KEY,
    "promotion_id" INTEGER NOT NULL,
    "order_item_id" INTEGER NOT NULL,
    FOREIGN KEY ("promotion_id") REFERENCES "promotions"("id") ON DELETE CASCADE,
    FOREIGN KEY ("order_item_id") REFERENCES "order_items"("id") ON DELETE CASCADE
);

-- View: monthly revenue
CREATE VIEW "monthly_revenue" AS
SELECT
    strftime('%Y-%m', "order_date") AS "year_month",
    SUM("total_cents") AS "revenue_cents",
    COUNT(*) AS "orders"
FROM "orders"
WHERE "status" IN ('paid','shipped','completed')
GROUP BY "year_month"
ORDER BY "year_month" DESC;

-- View: product_revenue
CREATE VIEW "product_revenue" AS
SELECT
    "p"."id" AS "product_id",
    "p"."sku" AS "sku",
    "p"."name" AS "product_name",
    "p"."category_id" AS "category_id",
    SUM(("oi"."unit_price_cents" * "oi"."quantity") - "oi"."discount_cents") AS "revenue_cents",
    SUM("oi"."quantity") AS "units_sold",
    COUNT(DISTINCT "oi"."order_id") AS "orders_count"
FROM "order_items" "oi"
JOIN "orders" "o" ON "oi"."order_id" = "o"."id"
JOIN "products" "p" ON "oi"."product_id" = "p"."id"
WHERE "o"."status" IN ('paid','shipped','completed')
GROUP BY "p"."id","p"."sku","p"."name","p"."category_id"
ORDER BY "revenue_cents" DESC;

-- View: returns_summary
CREATE VIEW "returns_summary" AS
SELECT
    "p"."id" AS "product_id",
    "p"."sku" AS "sku",
    "p"."name" AS "product_name",
    COUNT("r"."id") AS "returns_count",
    COALESCE(SUM("r"."refund_cents"), 0) AS "total_refund_cents"
FROM "returns" "r"
JOIN "order_items" "oi" ON "r"."order_item_id" = "oi"."id"
JOIN "products" "p" ON "oi"."product_id" = "p"."id"
GROUP BY "p"."id","p"."sku","p"."name"
ORDER BY "returns_count" DESC;

-- View: customers_order_summary
CREATE VIEW "customers_order_summary" AS
SELECT
    "c"."id" AS "customer_id",
    "c"."email" AS "email",
    "c"."name" AS "name",
    COUNT("o"."id") AS "orders_count",
    COALESCE(SUM("o"."total_cents"), 0) AS "total_spend_cents",
    AVG("o"."total_cents") AS "avg_order_cents",
    MIN("o"."order_date") AS "first_order_date",
    MAX("o"."order_date") AS "last_order_date"
FROM "customers" "c"
LEFT JOIN "orders" "o"
    ON "o"."customer_id" = "c"."id"
    AND "o"."status" IN ('paid','shipped','completed')
GROUP BY "c"."id","c"."email","c"."name"
ORDER BY "total_spend_cents" DESC;
