-- Миграция 004: Добавление таблиц для групп продуктов и связи с соединителями
-- Версия: 1.0
-- Дата: 2023-06-22

-- Начало транзакции
BEGIN;

-- Установка кодировки клиента UTF-8
SET client_encoding TO 'UTF8';

-- Проверка, что миграция еще не применялась
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM migrations WHERE migration_name = '004_product_groups') THEN
        RAISE EXCEPTION 'Миграция 004_product_groups уже применена';
    END IF;
END $$;

-- Создание таблицы групп продуктов
CREATE TABLE product_groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Триггер для обновления updated_at при изменении группы
CREATE OR REPLACE FUNCTION update_product_group_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_group_timestamp
BEFORE UPDATE ON product_groups
FOR EACH ROW
EXECUTE FUNCTION update_product_group_timestamp();

-- Создание таблицы продуктов (для каталога)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    group_id INTEGER NOT NULL REFERENCES product_groups(id),
    connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(connector_id)
);

-- Триггер для обновления updated_at при изменении продукта
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_product_timestamp();

-- Заполнение таблицы групп продуктов
INSERT INTO product_groups (name, description)
VALUES 
('2РМТ, 2РМДТ', 'Соединители типа 2РМТ и 2РМДТ'),
('СНЦ23', 'Соединители типа СНЦ23');

-- Создание продуктов для существующих соединителей
-- Соединители 2РМТ, 2РМДТ попадают в первую группу
INSERT INTO products (name, description, group_id, connector_id)
SELECT 
    c.full_code, 
    ct.description || ' ' || c.full_code,
    1, -- ID первой группы (2РМТ, 2РМДТ)
    c.connector_id
FROM 
    connectors c
    JOIN connector_types ct ON c.type_id = ct.type_id
WHERE 
    ct.type_name IN ('2РМТ', '2РМДТ');

-- Запись информации о текущей миграции
INSERT INTO migrations (migration_name, version)
VALUES ('004_product_groups', '1.0');

-- Завершение транзакции
COMMIT; 