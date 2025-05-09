# PowerShell скрипт для создания единого файла инициализации базы данных
# Автор: Claude
# Версия: 1.0

# Имя выходного файла
$outputFile = "database/init_db_unified.sql"

# Очищаем файл, если он существует
if (Test-Path $outputFile) {
    Clear-Content $outputFile
}

# Добавляем заголовок
@"
-- Скрипт инициализации базы данных соединителей 2РМТ, 2РМДТ (Unified version)
-- Разработчик: Claude
-- Версия: 1.1
-- Дата: 2023-06-21

-- Убедимся, что скрипт выполняется в транзакции
BEGIN;

-- Создание схемы
CREATE SCHEMA IF NOT EXISTS connector_schema;
SET search_path TO connector_schema, public;

-- Установка кодировки и локали
SET client_encoding TO 'UTF8';

-- Включаем логи для отслеживания выполнения
SELECT 'Инициализация базы данных соединителей 2РМТ, 2РМДТ...' as log;

"@ | Out-File -Append -Encoding utf8 $outputFile

# Список файлов для объединения в порядке выполнения
$files = @(
    "database/schema/01_base_tables.sql",
    "database/schema/02_dictionary_tables.sql",
    "database/schema/03_technical_tables.sql",
    "database/schema/04_relation_tables.sql",
    "database/data/01_base_dictionary_data.sql",
    "database/data/02_technical_data.sql",
    "database/data/03_relation_data.sql",
    "database/data/04_connectors_data.sql",
    "database/views/01_connector_views.sql",
    "database/functions/01_connector_functions.sql",
    "database/indexes/01_connector_indexes.sql",
    "database/tests/01_integrity_tests.sql",
    "database/examples/01_example_queries.sql"
)

# Секции для файлов
$sections = @(
    "Создание базовых таблиц",
    "Создание таблиц справочников",
    "Создание таблиц технических характеристик",
    "Создание таблиц связей и зависимостей",
    "Заполнение базовых справочников",
    "Заполнение справочников технических характеристик",
    "Заполнение таблиц зависимостей",
    "Заполнение таблицы соединителей",
    "Создание представлений",
    "Создание функций и триггеров",
    "Создание индексов",
    "Проверка целостности базы данных",
    "Выполнение примеров запросов"
)

# Обработка каждого файла
for ($i = 0; $i -lt $files.Length; $i++) {
    $file = $files[$i]
    $section = $sections[$i]
    
    # Добавляем разделитель секции
    @"

-- ======================================
-- $section
-- ======================================
SELECT '$section...' as log;

"@ | Out-File -Append -Encoding utf8 $outputFile

    # Проверяем существование файла
    if (Test-Path $file) {
        # Читаем содержимое файла и добавляем в выходной файл
        Get-Content -Encoding utf8 $file | Out-File -Append -Encoding utf8 $outputFile
    } else {
        # Если файл не существует, добавляем предупреждение
        "-- ОШИБКА: Файл $file не найден" | Out-File -Append -Encoding utf8 $outputFile
    }
}

# Добавляем завершение скрипта
@"

SELECT 'Инициализация базы данных успешно завершена!' as log;

-- Завершаем транзакцию
COMMIT;
"@ | Out-File -Append -Encoding utf8 $outputFile

Write-Host "Единый файл инициализации создан: $outputFile" 