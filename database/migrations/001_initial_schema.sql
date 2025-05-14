-- Миграция 001: Создание начальной схемы базы данных
-- Версия: 1.0
-- Дата: 2023-06-21

-- Начало транзакции
BEGIN;

-- Использование схемы public
SET search_path TO public;

-- Создание таблицы миграций для отслеживания выполненных миграций
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Запись информации о текущей миграции
INSERT INTO migrations (migration_name, version)
VALUES ('001_initial_schema', '1.0');

-- Включаем все основные файлы схемы
\i 'database/schema/01_base_tables.sql'
\i 'database/schema/02_dictionary_tables.sql'
\i 'database/schema/03_technical_tables.sql'
\i 'database/schema/04_relation_tables.sql'

-- Завершение транзакции
COMMIT; 