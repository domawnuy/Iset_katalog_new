# База данных соединителей 2РМТ, 2РМДТ

База данных для хранения и управления данными о соединителях типа 2РМТ и 2РМДТ, их технических характеристиках и взаимосвязях.

## Структура проекта

```
database/
├── schema/                   # Схемы таблиц базы данных
│   ├── 01_base_tables.sql    # Основные таблицы
│   ├── 02_dictionary_tables.sql # Справочные таблицы
│   ├── 03_technical_tables.sql # Таблицы технических характеристик
│   └── 04_relation_tables.sql # Таблицы связей
├── data/                     # Данные для заполнения таблиц
│   ├── 01_base_dictionary_data.sql # Данные базовых справочников
│   ├── 02_technical_data.sql # Технические характеристики
│   ├── 03_relation_data.sql  # Данные связей
│   └── 04_connectors_data.sql # Данные соединителей
├── views/                    # Представления
│   └── 01_connector_views.sql # Представления для соединителей
├── functions/                # Функции и триггеры
│   └── 01_connector_functions.sql # Функции для работы с соединителями
├── indexes/                  # Индексы
│   └── 01_connector_indexes.sql # Индексы базы данных
├── tests/                    # Тесты целостности
│   └── 01_integrity_tests.sql # Тесты целостности БД
└── examples/                 # Примеры запросов
    └── 01_example_queries.sql # Примеры запросов к БД
init_db_unified.sql           # Объединенный скрипт инициализации
```

## Инициализация базы данных

### Способ 1: Использование объединенного скрипта

Для полной инициализации базы данных одним скриптом выполните следующую команду:

```bash
psql -U postgres -h localhost -d connector_catalog -f database/init_db_unified.sql
```

### Способ 2: Последовательное выполнение скриптов

Вы также можете выполнить скрипты по отдельности в следующем порядке:

1. Создание схемы и основных структур:

```sql
BEGIN;
CREATE SCHEMA IF NOT EXISTS connector_schema;
SET search_path TO connector_schema, public;
SET client_encoding TO 'UTF8';
COMMIT;
```

2. Выполнение скриптов в указанной последовательности:

```
database/schema/01_base_tables.sql
database/schema/02_dictionary_tables.sql
database/schema/03_technical_tables.sql
database/schema/04_relation_tables.sql
database/data/01_base_dictionary_data.sql
database/data/02_technical_data.sql
database/data/03_relation_data.sql
database/data/04_connectors_data.sql
database/views/01_connector_views.sql
database/functions/01_connector_functions.sql
database/indexes/01_connector_indexes.sql
database/tests/01_integrity_tests.sql
database/examples/01_example_queries.sql
```

Пример выполнения отдельного скрипта:

```bash
psql -U postgres -h localhost -d connector_catalog -f database/schema/01_base_tables.sql
```

### Обновление объединенного скрипта

Если вы внесли изменения в отдельные файлы и хотите обновить объединенный скрипт, выполните:

```bash
./create_unified_script.ps1
```

Скрипт инициализации выполнит следующие действия:
- Создаст схему и служебные таблицы
- Создаст все необходимые таблицы базы данных
- Заполнит базовые справочники
- Заполнит таблицы с внешними ключами и зависимостями
- Создаст представления, функции и триггеры
- Создаст индексы для оптимизации запросов
- Выполнит проверки целостности базы данных
- Выполнит примеры запросов

## Основные возможности

1. Хранение полной информации о соединителях 2РМТ, 2РМДТ
2. Учет технических характеристик (сопротивление, токи, температуры)
3. Расчет сроков службы в зависимости от температуры
4. Анализ совместимости соединителей
5. Поиск и фильтрация по различным параметрам
6. Генерация и разбор кодов соединителей

## Примеры использования

### Получение информации о соединителе

```sql
SELECT * FROM v_connectors_full WHERE full_code = '2РМТ18Б4Г1В1В';
```

### Поиск соединителей с определенными характеристиками

```sql
SELECT full_code, size_value, body_type, contact_quantity, connector_part
FROM v_connectors_search
WHERE type_name = '2РМТ' AND contact_coating = 'золото'
ORDER BY size_value, contact_quantity;
```

### Получение технических характеристик

```sql
SELECT * FROM v_contact_specs;
```

### Использование функций для анализа

```sql
SELECT * FROM calculate_lifetime_at_temperature(100);
```

## Технические характеристики

База данных содержит следующие технические характеристики соединителей:

- Сопротивление контактов в зависимости от диаметра
- Максимальный ток в зависимости от диаметра контактов
- Минимальная наработка в зависимости от температуры
- Температура перегрева контактов в зависимости от токовой нагрузки
- Общие технические характеристики (сопротивление изоляции, рабочее напряжение и т.д.)

## Документация

Полная документация по структуре базы данных и примеры запросов находятся в каталоге `database/examples/`. 