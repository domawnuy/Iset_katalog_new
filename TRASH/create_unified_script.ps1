# PowerShell скрипт для создания единого файла инициализации базы данных
# Автор: Claude
# Версия: 1.2
# Дата: 2025-05-12

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
-- Версия: 1.2
-- Дата: 2025-05-12

-- Убедимся, что скрипт выполняется в транзакции
BEGIN;

-- Установка пути поиска для схемы
SET search_path TO public;

-- Установка кодировки и локали
SET client_encoding TO 'UTF8';
SET standard_conforming_strings TO on;

-- Включаем логи для отслеживания выполнения
SELECT 'Инициализация базы данных соединителей 2РМТ, 2РМДТ...' as log;

"@ | Out-File -Append -Encoding utf8 $outputFile

# Список файлов для объединения в порядке выполнения
$files = @(
    "database/migrations/000_init_migrations_table.sql",
    "database/schema/01_base_tables.sql",
    "database/schema/02_dictionary_tables.sql",
    "database/schema/03_technical_tables.sql",
    "database/data/01_base_dictionary_data.sql",
    "database/data/02_technical_data.sql",
    "database/data/03_relation_data.sql",
    "database/views/01_connector_views.sql",
    "database/functions/01_connector_functions.sql",
    "database/indexes/01_connector_indexes.sql",
    "database/migrations/005_remove_tables.sql"
)

# Секции для файлов
$sections = @(
    "Инициализация таблицы миграций",
    "Создание базовых таблиц",
    "Создание таблиц справочников",
    "Создание таблиц технических характеристик",
    "Заполнение базовых справочников",
    "Заполнение справочников технических характеристик",
    "Заполнение таблиц зависимостей",
    "Создание представлений",
    "Создание функций и триггеров",
    "Создание индексов",
    "Удаление ненужных таблиц"
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
        $content = Get-Content -Encoding utf8 $file
        
        # Фильтруем строки BEGIN; и COMMIT; для избежания вложенных транзакций
        $filteredContent = $content | Where-Object { $_ -notmatch '^\s*(BEGIN|COMMIT)\s*;\s*$' }
        
        # Фильтруем строки с командами \i, так как они не поддерживаются в чистом SQL
        $filteredContent = $filteredContent | Where-Object { $_ -notmatch '^\s*\\i\s' }
        
        # Записываем отфильтрованный контент в файл
        $filteredContent | Out-File -Append -Encoding utf8 $outputFile
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