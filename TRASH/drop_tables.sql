-- Скрипт для удаления таблиц и зависимостей
BEGIN;

-- Сначала удаляем зависимые таблицы
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

COMMIT; 