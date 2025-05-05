-- Скрипт инициализации базы данных соединителей 2РМТ, 2РМДТ
-- Разработчик: Claude
-- Версия: 1.0
-- Дата: 2023-06-21

-- Убедимся, что скрипт выполняется в транзакции
BEGIN;

-- Проверка и создание базы данных
-- Примечание: следующая строка должна быть выполнена вне транзакции
-- CREATE DATABASE connector_catalog;

-- Создание схемы
CREATE SCHEMA IF NOT EXISTS connector_schema;
SET search_path TO connector_schema, public;

-- Установка кодировки и локали
SET client_encoding TO 'UTF8';

-- Включаем логи для отслеживания выполнения
\echo 'Инициализация базы данных соединителей 2РМТ, 2РМДТ...'

-- Подключаем файлы с определениями таблиц
\echo 'Создание базовых таблиц...'
\i 'database/schema/01_base_tables.sql'

\echo 'Создание таблиц справочников...'
\i 'database/schema/02_dictionary_tables.sql'

\echo 'Создание таблиц технических характеристик...'
\i 'database/schema/03_technical_tables.sql'

\echo 'Создание таблиц связей и зависимостей...'
\i 'database/schema/04_relation_tables.sql'

-- Подключаем файлы с данными
\echo 'Заполнение базовых справочников...'
\i 'database/data/01_base_dictionary_data.sql'

\echo 'Заполнение справочников технических характеристик...'
\i 'database/data/02_technical_data.sql'

\echo 'Заполнение таблиц зависимостей...'
\i 'database/data/03_relation_data.sql'

\echo 'Заполнение таблицы соединителей...'
\i 'database/data/04_connectors_data.sql'

-- Создание представлений
\echo 'Создание представлений...'
\i 'database/views/01_connector_views.sql'

-- Создание функций и триггеров
\echo 'Создание функций и триггеров...'
\i 'database/functions/01_connector_functions.sql'

-- Создание индексов
\echo 'Создание индексов...'
\i 'database/indexes/01_connector_indexes.sql'

-- Проверка целостности базы данных
\echo 'Проверка целостности базы данных...'
\i 'database/tests/01_integrity_tests.sql'

-- Примеры запросов
\echo 'Выполнение примеров запросов...'
\i 'database/examples/01_example_queries.sql'

\echo 'Инициализация базы данных успешно завершена!'

-- Завершаем транзакцию
COMMIT; 