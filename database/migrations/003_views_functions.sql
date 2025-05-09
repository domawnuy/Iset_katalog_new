-- Миграция 003: Создание представлений и функций
-- Версия: 1.0
-- Дата: 2023-06-21

-- Начало транзакции
BEGIN;

-- Проверка, что миграция еще не применялась
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM connector_schema.migrations WHERE migration_name = '003_views_functions') THEN
        RAISE EXCEPTION 'Миграция 003_views_functions уже применена';
    END IF;
END $$;

-- Включаем файлы с представлениями и функциями
\i 'database/views/01_connector_views.sql'
\i 'database/functions/01_connector_functions.sql'
\i 'database/indexes/01_connector_indexes.sql'

-- Запись информации о текущей миграции
INSERT INTO connector_schema.migrations (migration_name, version)
VALUES ('003_views_functions', '1.0');

-- Завершение транзакции
COMMIT; 