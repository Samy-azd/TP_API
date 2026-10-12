-- =============================================================
-- TP 2 : Script SQL de création de la Base de Données (H2 / SQL)
-- =============================================================

-- 1. Table des utilisateurs (Sécurité & BCrypt)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

-- 2. Table des Refresh Tokens (JWT)
CREATE TABLE refresh_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP NOT NULL,
    CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Table des relevés IMC (BMI)
CREATE TABLE bmi_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    weight DOUBLE NOT NULL,
    height DOUBLE NOT NULL,
    bmi DOUBLE NOT NULL,
    category VARCHAR(50),
    interpretation VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_bmi_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Table des opérations de la calculatrice (Exercice 1)
CREATE TABLE operations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    operateur VARCHAR(50) NOT NULL,
    a DOUBLE NOT NULL,
    b DOUBLE NOT NULL,
    resultat DOUBLE NOT NULL,
    date TIMESTAMP NOT NULL
);

-- 5. Table des transactions de devises (Exercice 2)
CREATE TABLE currency_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    amount DOUBLE NOT NULL,
    converted_amount DOUBLE NOT NULL,
    rate DOUBLE NOT NULL,
    rate_source VARCHAR(50),
    timestamp TIMESTAMP NOT NULL
);

-- 6. Table des taux de change locaux personnalisés (Exercice 2)
CREATE TABLE custom_exchange_rates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate DOUBLE NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
