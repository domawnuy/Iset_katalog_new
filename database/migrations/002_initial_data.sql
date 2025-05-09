-- Миграция 002: Заполнение базы данных начальными данными
-- Версия: 1.0
-- Дата: 2023-06-21

-- Начало транзакции
BEGIN;

-- Проверка, что миграция еще не применялась
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM connector_schema.migrations WHERE migration_name = '002_initial_data') THEN
        RAISE EXCEPTION 'Миграция 002_initial_data уже применена';
    END IF;
END $$;

-- Включаем все файлы с данными
\i 'database/data/01_base_dictionary_data.sql'
\i 'database/data/02_technical_data.sql'
\i 'database/data/03_relation_data.sql'
\i 'database/data/04_connectors_data.sql'

-- Запись информации о текущей миграции
INSERT INTO connector_schema.migrations (migration_name, version)
VALUES ('002_initial_data', '1.0');

-- Завершение транзакции
COMMIT; 