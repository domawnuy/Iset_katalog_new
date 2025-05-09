# База данных соединителей 2РМТ, 2РМДТ

Система для хранения и управления данными о соединителях серий 2РМТ и 2РМДТ, их технических характеристиках, взаимосвязях и функциональных возможностях.

## Структура проекта

```
.
├── database/                      # Основная директория проекта
│   ├── connection/                # Модули для подключения к базе данных
│   │   ├── db_config.py           # Конфигурация подключения
│   │   ├── db_connector.py        # Базовый коннектор
│   │   ├── connection_pool.py     # Пул соединений для эффективной работы
│   │   └── db_utils.py            # Утилиты для работы с БД
│   ├── migrations/                # Управление миграциями базы данных
│   │   ├── 001_initial_schema.sql # Начальная схема БД
│   │   ├── 002_initial_data.sql   # Начальные данные
│   │   ├── 003_views_functions.sql # Представления и функции
│   │   └── migration_runner.py    # Утилита для управления миграциями
│   ├── queries/                   # Часто используемые запросы
│   │   ├── connector_info.sql     # Получение информации о соединителе
│   │   ├── search_by_specs.sql    # Поиск соединителей по характеристикам
│   │   ├── tech_specs.sql         # Технические характеристики
│   │   └── lifetime_calc.sql      # Расчет срока службы
│   ├── schema/                    # Схемы таблиц базы данных
│   │   ├── 01_base_tables.sql     # Основные таблицы
│   │   ├── 02_dictionary_tables.sql # Справочные таблицы
│   │   ├── 03_technical_tables.sql # Таблицы технических характеристик
│   │   └── 04_relation_tables.sql # Таблицы связей
│   ├── data/                      # Данные для заполнения таблиц
│   │   ├── 01_base_dictionary_data.sql # Данные базовых справочников
│   │   ├── 02_technical_data.sql  # Технические характеристики
│   │   ├── 03_relation_data.sql   # Данные связей
│   │   └── 04_connectors_data.sql # Данные соединителей
│   ├── views/                     # Представления
│   │   └── 01_connector_views.sql # Представления для соединителей
│   ├── functions/                 # Функции и триггеры
│   │   └── 01_connector_functions.sql # Функции для работы с соединителями
│   ├── indexes/                   # Индексы
│   │   └── 01_connector_indexes.sql # Индексы базы данных
│   ├── tests/                     # Тесты целостности
│   │   └── 01_integrity_tests.sql # Тесты целостности БД
│   ├── examples/                  # Примеры запросов
│   │   └── 01_example_queries.sql # Примеры запросов к БД
│   ├── Zapchasti/                 # Исходные данные и материалы
│   │   ├── 2РМТ, 2РМДТ/           # Данные по сериям 2РМТ и 2РМДТ
│   │   └── СНЦ23/                 # Данные по серии СНЦ23
│   ├── cli.py                     # Интерфейс командной строки
│   └── init_db_unified.sql        # Объединенный скрипт инициализации
├── .env                           # Параметры подключения к PostgreSQL
├── .pgpass                        # Файл паролей PostgreSQL
├── .gitignore                     # Игнорируемые Git файлы
└── create_unified_script.ps1      # Скрипт создания объединенного файла
```

## Установка и настройка

### Предварительные требования

- Python 3.8+
- PostgreSQL 12+
- Библиотеки Python: `psycopg2-binary`, `python-dotenv`

### Установка зависимостей

```bash
pip install psycopg2-binary python-dotenv
```

### Настройка конфигурации

1. Создайте файл `.env` в корне проекта:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=connector_catalog
DB_USER=postgres
DB_PASSWORD=your_password
DB_SCHEMA=connector_schema
```

## Инициализация базы данных

### Через интерфейс командной строки Python

#### Вариант 1: Объединенный скрипт (рекомендуется)

```bash
python -m database.cli init-db
```

#### Вариант 2: Последовательное выполнение скриптов

```bash
python -m database.cli init-db --sequential
```

### Через управление миграциями (для разработки)

```bash
# Показать статус миграций
python -m database.migrations.migration_runner status

# Применить все миграции
python -m database.migrations.migration_runner apply

# Применить миграции до указанной
python -m database.migrations.migration_runner apply --target 003_views_functions.sql
```

### Вручную через psql

```bash
psql -U postgres -h localhost -d connector_catalog -f database/init_db_unified.sql
```

## Основные возможности

- Полная информация о соединителях 2РМТ и 2РМДТ
- Технические характеристики (сопротивление, токи, температуры)
- Расчеты сроков службы в зависимости от условий эксплуатации
- Анализ совместимости соединителей
- Поиск и фильтрация по различным параметрам
- Конструктор для формирования и разбора кодов соединителей

## Примеры использования

### Программное использование

```python
from database import execute_query, execute_query_single_result

# Получение информации о соединителе
connector_code = '2РМТ18Б4Г1В1В'
result = execute_query(
    "SELECT * FROM connector_schema.v_connectors_full WHERE full_code = %s", 
    (connector_code,)
)

# Поиск соединителей по параметрам
connectors = execute_query("""
    SELECT full_code, size_value, body_type, contact_quantity, connector_part
    FROM connector_schema.v_connectors_search
    WHERE type_name = %s AND contact_coating = %s
    ORDER BY size_value, contact_quantity
""", ('2РМТ', 'золото'))

# Получение технических характеристик
specs = execute_query("SELECT * FROM connector_schema.v_contact_specs")

# Использование функций для анализа
lifetime = execute_query(
    "SELECT * FROM connector_schema.calculate_lifetime_at_temperature(%s)",
    (100,)
)
```

### Исполнение запросов из файлов

```bash
# Выполнение запроса из файла
python -m database.cli execute database/queries/connector_info.sql

# Или через psql
psql -U postgres -h localhost -d connector_catalog -f database/queries/search_by_specs.sql
```

## Технические характеристики

База данных содержит:

- Сопротивление контактов в зависимости от диаметра
- Максимальный ток в зависимости от диаметра контактов
- Минимальная наработка в зависимости от температуры
- Температура перегрева контактов в зависимости от токовой нагрузки
- Общие технические характеристики (изоляция, напряжение и т.д.)

## Требования

- PostgreSQL 12+
- Python 3.8+
- Кодировка UTF-8
- Доступ к базе данных с правами на создание схем и таблиц

## Безопасность

- Используются параметризованные запросы для предотвращения SQL-инъекций
- Пароли и конфиденциальные данные хранятся в файле `.env`
- Используется пул соединений для эффективного управления ресурсами БД

## Разработка и поддержка

Система находится в активной разработке. Предложения по улучшению принимаются через issues. 