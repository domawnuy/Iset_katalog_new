-- 001: Добавление поля type_id в таблицу connector_series для связи с connector_types
-- Версия: 1.0
-- Дата: 2024-05-19

-- Начало транзакции
BEGIN;

-- Проверяем наличие записи о миграции
SELECT 'Добавляем поле type_id в таблицу connector_series...' as log;

-- Проверяем существование таблицы
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'connector_series'
    ) THEN
        -- Проверяем наличие колонки
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'connector_series' 
            AND column_name = 'type_id'
        ) THEN
            -- Добавляем колонку type_id
            ALTER TABLE connector_series ADD COLUMN type_id INTEGER;
            
            -- Устанавливаем type_id для существующих записей на основе имени серии
            UPDATE connector_series cs
            SET type_id = ct.type_id
            FROM connector_types ct
            WHERE substring(cs.series_name, 1, position(' ' in cs.series_name || ' ')-1) = ct.code;
            
            -- Делаем колонку NOT NULL
            ALTER TABLE connector_series ALTER COLUMN type_id SET NOT NULL;
            
            -- Добавляем внешний ключ
            ALTER TABLE connector_series
            ADD CONSTRAINT fk_connector_series_connector_types
            FOREIGN KEY (type_id) REFERENCES connector_types(type_id);
            
            -- Добавляем индекс для улучшения производительности
            CREATE INDEX idx_connector_series_type_id ON connector_series(type_id);
            
            -- Записываем в лог информацию об успешно примененной миграции
            RAISE NOTICE 'Миграция 001_add_type_id_to_connector_series.sql успешно применена';
        ELSE
            RAISE NOTICE 'Колонка type_id уже существует в таблице connector_series';
        END IF;
    ELSE
        RAISE NOTICE 'Таблица connector_series не существует';
    END IF;
END$$;

-- Добавляем запись о миграции
INSERT INTO migrations (migration_name, version, applied_at) 
VALUES ('001_add_type_id_to_connector_series', '1.0', NOW())
ON CONFLICT DO NOTHING;

-- Завершение транзакции
COMMIT; 