CREATE TYPE user_role AS ENUM ('customer', 'seller', 'admin');
CREATE TYPE user_status AS ENUM ('active', 'blocked', 'banned');
CREATE TYPE user_log_action AS ENUM ('blocked', 'banned', 'reactivated');
CREATE TYPE store_status AS ENUM ('pending', 'active', 'suspended');
CREATE TYPE stock_movement_type AS ENUM ('entry', 'sale', 'return', 'adjustment');
CREATE TYPE cart_status AS ENUM ('active', 'converted', 'abandoned');
CREATE TYPE order_status AS ENUM ('pending', 'paid', 'shipped', 'delivered', 'cancelled');
CREATE TYPE payment_method AS ENUM ('pix', 'credit_card', 'boleto');
CREATE TYPE payment_status AS ENUM ('pending', 'approved', 'refused', 'refunded');
CREATE TYPE shipment_status AS ENUM ('preparing', 'in_transit', 'delivered', 'returned');

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at= NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE users (
    uuid_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cpf VARCHAR(11) NOT NULL UNIQUE CHECK (cpf ~ '^[0-9]{11}$'),
    name VARCHAR(120) NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE CHECK (email = LOWER(email)),
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TABLE categories (
    uuid_category UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_parent UUID,
    name VARCHAR(80) NOT NULL,
    CONSTRAINT fk_categories_parent
        FOREIGN KEY (uuid_parent) REFERENCES categories (uuid_category)
        ON DELETE RESTRICT
);
CREATE INDEX idx_categories_parent ON categories (uuid_parent);

CREATE TABLE stores (
    uuid_store UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_user UUID NOT NULL,
    name VARCHAR(120) NOT NULL,
    cnpj VARCHAR(14) NOT NULL UNIQUE CHECK (cnpj ~ '^[0-9]{14}$'),
    description TEXT,
    status store_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_stores_users
        FOREIGN KEY (uuid_user) REFERENCES users (uuid_user)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_stores_updated_at
BEFORE UPDATE ON stores
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_stores_user ON stores (uuid_user);

CREATE TABLE addresses (
    uuid_address UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_user UUID NOT NULL,
    street VARCHAR(150) NOT NULL,
    number VARCHAR(10) NOT NULL,
    complement VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code CHAR(8) NOT NULL CHECK (zip_code ~ '^[0-9]{8}$'),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_addresses_users
        FOREIGN KEY (uuid_user) REFERENCES users (uuid_user)
        ON DELETE RESTRICT
);
CREATE UNIQUE INDEX uq_addresses_one_default_per_user
ON addresses (uuid_user)
WHERE is_default AND deleted_at IS NULL;

CREATE INDEX idx_addresses_user ON addresses (uuid_user);

CREATE TABLE user_status_log (
    uuid_status_log UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_user UUID NOT NULL,
    uuid_admin UUID NOT NULL,
    action user_log_action NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_status_log_values
        CHECK (uuid_user <> uuid_admin),
    CONSTRAINT fk_status_log_users
        FOREIGN KEY (uuid_user) REFERENCES users (uuid_user)
        ON DELETE RESTRICT,
    CONSTRAINT fk_status_log_users_admin
        FOREIGN KEY (uuid_admin) REFERENCES users (uuid_user)
        ON DELETE RESTRICT
);
CREATE INDEX idx_user_status_log_user ON user_status_log (uuid_user);

CREATE TABLE products (
    uuid_product UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_store UUID NOT NULL,
    uuid_category UUID NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_products_stores
        FOREIGN KEY (uuid_store) REFERENCES stores (uuid_store)
        ON DELETE RESTRICT,
    CONSTRAINT fk_products_categories
        FOREIGN KEY (uuid_category) REFERENCES categories (uuid_category)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_products_store ON products (uuid_store);
CREATE INDEX idx_products_category ON products (uuid_category);

CREATE TABLE inventory (
    uuid_product UUID PRIMARY KEY, 
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_inventory_products
        FOREIGN KEY (uuid_product) REFERENCES products (uuid_product)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_inventory_updated_at
BEFORE UPDATE ON inventory
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TABLE stock_movements (
    uuid_stock_movement UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_product UUID NOT NULL,
    type stock_movement_type NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity <> 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_stock_movements_products
        FOREIGN KEY (uuid_product) REFERENCES products (uuid_product)
        ON DELETE RESTRICT
);
CREATE INDEX idx_stock_movements_product ON stock_movements (uuid_product);

CREATE TABLE carts (
    uuid_cart UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_user UUID NOT NULL,
    status cart_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_carts_users
        FOREIGN KEY (uuid_user) REFERENCES users (uuid_user)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_carts_updated_at
BEFORE UPDATE ON carts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE UNIQUE INDEX uq_carts_one_active_per_user
ON carts (uuid_user)
WHERE status = 'active';

CREATE INDEX idx_carts_user ON carts (uuid_user);

CREATE TABLE cart_items (
    uuid_cart_product UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_cart UUID NOT NULL,
    uuid_product UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_cart_items_carts
        FOREIGN KEY (uuid_cart) REFERENCES carts (uuid_cart)
        ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_products
        FOREIGN KEY (uuid_product) REFERENCES products (uuid_product)
        ON DELETE RESTRICT,
    CONSTRAINT uq_cart_items_cart_product UNIQUE (uuid_cart, uuid_product)
);
CREATE INDEX idx_cart_items_product ON cart_items (uuid_product);

CREATE TABLE orders (
    uuid_order UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_user UUID NOT NULL,
    uuid_address UUID NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    total NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    shipping_cost NUMERIC(12, 2) NOT NULL,
    discount NUMERIC(12, 2) NOT NULL DEFAULT 0, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_orders_values
        CHECK (total >= 0 AND subtotal >= 0 AND shipping_cost >= 0 AND discount >= 0),
    CONSTRAINT chk_orders_total CHECK (total = subtotal + shipping_cost - discount),
    CONSTRAINT fk_orders_users
        FOREIGN KEY (uuid_user) REFERENCES users (uuid_user)
        ON DELETE RESTRICT,
    CONSTRAINT fk_orders_addresses
        FOREIGN KEY (uuid_address) REFERENCES addresses (uuid_address)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_orders_user ON orders (uuid_user);
CREATE INDEX idx_orders_address ON orders (uuid_address);
CREATE INDEX idx_orders_status ON orders (status);

CREATE TABLE order_items (
    uuid_order_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_order UUID NOT NULL,
    uuid_product UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (uuid_order) REFERENCES orders (uuid_order)
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_products
        FOREIGN KEY (uuid_product) REFERENCES products (uuid_product)
        ON DELETE RESTRICT
);
CREATE INDEX idx_order_items_order ON order_items (uuid_order);
CREATE INDEX idx_order_items_product ON order_items (uuid_product);

CREATE TABLE payments (
    uuid_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_order UUID NOT NULL,
    method payment_method NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending',
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    gateway_ref VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payments_orders
        FOREIGN KEY (uuid_order) REFERENCES orders (uuid_order)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_payments_order ON payments (uuid_order);

CREATE TABLE order_status_history (
    uuid_order_status_history UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_order UUID NOT NULL,
    uuid_changed_by UUID,
    status order_status NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_order_status_history_orders
        FOREIGN KEY (uuid_order) REFERENCES orders (uuid_order)
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_status_history_users
        FOREIGN KEY (uuid_changed_by) REFERENCES users (uuid_user)
        ON DELETE RESTRICT
);
CREATE INDEX idx_order_status_history_order ON order_status_history (uuid_order);

CREATE TABLE shipments (
    uuid_shipment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uuid_order UUID NOT NULL,
    uuid_store UUID NOT NULL,
    carrier VARCHAR(60),
    tracking_code VARCHAR(50),
    status shipment_status NOT NULL DEFAULT 'preparing',
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_shipments_orders
        FOREIGN KEY (uuid_order) REFERENCES orders (uuid_order)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shipments_stores
        FOREIGN KEY (uuid_store) REFERENCES stores (uuid_store)
        ON DELETE RESTRICT
);
CREATE TRIGGER trg_shipments_updated_at
BEFORE UPDATE ON shipments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_shipments_order ON shipments (uuid_order);
CREATE INDEX idx_shipments_store ON shipments (uuid_store);