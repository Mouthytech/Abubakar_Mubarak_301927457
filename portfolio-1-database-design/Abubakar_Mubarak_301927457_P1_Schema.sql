-- Muhab Gadget Store: relational schema (PostgreSQL)
-- Student: Abubakar Mubarak (301927457)

DROP TABLE IF EXISTS reviews, deliveries, payments, order_items, orders,
                     products, brands, categories, addresses, customers CASCADE;

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    phone        VARCHAR(20)  UNIQUE,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id   SERIAL PRIMARY KEY,
    customer_id  INT          NOT NULL REFERENCES customers(customer_id),
    street       VARCHAR(150) NOT NULL,
    city         VARCHAR(60)  NOT NULL,
    state        VARCHAR(60)  NOT NULL,
    is_default   BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE TABLE categories (
    category_id  SERIAL PRIMARY KEY,
    name         VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE brands (
    brand_id     SERIAL PRIMARY KEY,
    name         VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    category_id  INT           NOT NULL REFERENCES categories(category_id),
    brand_id     INT           NOT NULL REFERENCES brands(brand_id),
    sku          VARCHAR(30)   NOT NULL UNIQUE,
    name         VARCHAR(120)  NOT NULL,
    unit_price   NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    stock_qty    INT           NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    is_active    BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT         NOT NULL REFERENCES customers(customer_id),
    address_id   INT         NOT NULL REFERENCES addresses(address_id),
    order_date   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       VARCHAR(20) NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','paid','shipped','delivered','cancelled'))
);

CREATE TABLE order_items (
    order_id     INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id   INT           NOT NULL REFERENCES products(product_id),
    quantity     INT           NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),  -- price at time of purchase
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id   SERIAL PRIMARY KEY,
    order_id     INT           NOT NULL REFERENCES orders(order_id),
    amount       NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    method       VARCHAR(20)   NOT NULL
                 CHECK (method IN ('card','bank_transfer','pay_on_delivery')),
    status       VARCHAR(20)   NOT NULL
                 CHECK (status IN ('successful','failed','refunded')),
    paid_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE deliveries (
    delivery_id     SERIAL PRIMARY KEY,
    order_id        INT         NOT NULL UNIQUE REFERENCES orders(order_id),
    courier_name    VARCHAR(60) NOT NULL,
    tracking_number VARCHAR(40) UNIQUE,
    status          VARCHAR(20) NOT NULL DEFAULT 'preparing'
                    CHECK (status IN ('preparing','in_transit','delivered','returned')),
    dispatched_at   TIMESTAMP,
    delivered_at    TIMESTAMP,
    CHECK (delivered_at IS NULL OR (dispatched_at IS NOT NULL AND delivered_at >= dispatched_at))
);

CREATE TABLE reviews (
    review_id    SERIAL PRIMARY KEY,
    customer_id  INT      NOT NULL REFERENCES customers(customer_id),
    product_id   INT      NOT NULL REFERENCES products(product_id),
    rating       SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (customer_id, product_id)
);

-- Note: no extra indexes on foreign keys yet. PostgreSQL does not create them
-- automatically; they are added and measured in Portfolio 2.
