-- Миграция 005: Удаление таблиц
-- Версия: 1.0
-- Дата: 2025-05-12

-- Начало транзакции
BEGIN;

-- Установка кодировки клиента UTF-8
SET client_encoding TO 'UTF8';

-- Проверка, что миграция еще не применялась
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM migrations WHERE migration_name = '005_remove_tables') THEN
        RAISE EXCEPTION 'Миграция 005_remove_tables уже применена';
    END IF;
END $$;

-- Сначала удаляем зависимые представления
DROP VIEW IF EXISTS v_connectors_full CASCADE;
DROP VIEW IF EXISTS v_connectors_search CASCADE;

-- Удаляем зависимые таблицы
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS connector_documentation CASCADE;
DROP TABLE IF EXISTS compatible_connectors CASCADE;
DROP TABLE IF EXISTS connector_design_options CASCADE;

-- Теперь удаляем основные таблицы
DROP TABLE IF EXISTS product_groups CASCADE;
DROP TABLE IF EXISTS connectors CASCADE;

-- Удаляем связанные функции и триггеры
DROP FUNCTION IF EXISTS update_product_timestamp() CASCADE;
DROP FUNCTION IF EXISTS update_product_group_timestamp() CASCADE;
DROP FUNCTION IF EXISTS update_connector_timestamp() CASCADE;

-- Удаляем запись миграции 004, так как эти таблицы больше не нужны
DELETE FROM migrations WHERE migration_name = '004_product_groups';

-- Запись информации о текущей миграции
INSERT INTO migrations (migration_name, version)
VALUES ('005_remove_tables', '1.0');

-- Завершение транзакции
COMMIT; 