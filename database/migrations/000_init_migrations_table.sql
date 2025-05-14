-- Миграция 000: Инициализация таблицы миграций для уже существующей БД
-- Версия: 1.0
-- Дата: 2025-05-12

-- Начало транзакции
BEGIN;

-- Создание таблицы миграций
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Добавление записей о уже примененных миграциях
INSERT INTO migrations (migration_name, version, applied_at)
VALUES 
('001_initial_schema', '1.0', NOW() - INTERVAL '1 day'),
('002_initial_data', '1.0', NOW() - INTERVAL '1 day'),
('003_views_functions', '1.0', NOW() - INTERVAL '1 day');

-- Завершение транзакции
COMMIT; 