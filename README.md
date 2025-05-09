# Каталог соединителей Iset

Проект представляет собой каталог соединителей типа 2РМТ, 2РМДТ и других электрических соединителей с реализацией API для получения данных.

## Описание проекта

Система предоставляет API для получения информации о соединителях из базы данных PostgreSQL. Проект состоит из трех слоев:
1. БД - PostgreSQL база данных с таблицами, хранящими информацию о соединителях
2. API - FastAPI приложение, предоставляющее REST API для доступа к данным
3. Frontend (планируется в будущем) - React Native приложение для отображения каталога

## Структура проекта

```
Iset_katalog4/
├── api/                    # Модуль API
│   ├── models/             # Модели данных (Pydantic)
│   ├── routers/            # Маршруты API
│   ├── database.py         # Работа с базой данных
│   └── main.py             # Основное FastAPI приложение
├── database/               # Модуль работы с базой данных
│   ├── connection/         # Подключение к БД
│   ├── data/               # Данные для заполнения БД
│   ├── schema/             # Схемы таблиц
│   ├── queries/            # SQL запросы
│   ├── migrations/         # Миграции БД
│   └── functions/          # Функции для работы с БД
├── .env                    # Переменные окружения
├── run_api_server.py       # Скрипт запуска API сервера
└── requirements.txt        # Зависимости проекта
```

## Требования

- Python 3.9+
- PostgreSQL 13+
- Зависимости из requirements.txt

## Установка и настройка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/domawnuy/Iset_katalog_new.git
cd Iset_katalog_new
```

2. Создайте виртуальное окружение и установите зависимости:
```bash
python -m venv .venv
source .venv/bin/activate  # На Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

3. Настройте подключение к базе данных PostgreSQL:
   - Создайте файл `.env` в корневой директории проекта
   - Укажите параметры подключения к БД:
```
DB_NAME=iset_katalog
DB_USER=postgres
DB_PASSWORD=ваш_пароль
DB_HOST=localhost
DB_PORT=5432
```

4. Инициализируйте базу данных с помощью миграций:
```bash
python -m database.migrations.migration_runner
```

## Запуск API сервера

Для запуска API сервера выполните:
```bash
python run_api_server.py
```

Сервер будет доступен по адресу: http://localhost:8000

Документация API (Swagger): http://localhost:8000/docs

## API эндпоинты

### 1. Получение списка групп изделий

```
GET /api/Groups/GetGroups
```

**Ответ:**
```json
[
  {
    "group_id": 1,
    "group_name": "2РМТ"
  },
  {
    "group_id": 2,
    "group_name": "2РМДТ"
  }
]
```

### 2. Получение списка изделий в группе с пагинацией

```
GET /api/Products/GetProductsByGroupId?group_id=1&page=1&page_size=10
```

**Параметры:**
- `group_id` - идентификатор группы изделий
- `page` - номер страницы (начиная с 1)
- `page_size` - количество элементов на странице (от 1 до 100)

**Ответ:**
```json
{
  "items": [
    {
      "product_id": 1,
      "product_name": "2РМТ14Б4Ш1В1В",
      "product_image_path": "/images/2rmt14b4sh1v1v.jpg"
    }
  ],
  "total_count": 150,
  "page": 1,
  "page_size": 10
}
```

### 3. Получение детальной информации об изделии

```
GET /api/Products/GetById?product_id=1
```

**Параметры:**
- `product_id` - идентификатор изделия

**Ответ:**
```json
{
  "connector_id": 1,
  "full_code": "2РМТ14Б4Ш1В1В",
  "gost": "ГОСТ 23325-78",
  "connector_type": "2РМТ",
  "body_size": "14",
  "body_type": "Блочный",
  "nozzle_type": "Прямой",
  "nut_type": "С гайкой",
  "contacts_quantity": 4,
  "connector_part": "Вилка",
  "contact_combination": "Ш",
  "contact_coating": "Золото",
  "heat_resistance": 250,
  "special_design": null,
  "climate_design": "Обычное",
  "connection_type": "Резьбовое",
  "contacts_info": [
    {
      "diameter": 1.5,
      "max_resistance": 4.0,
      "max_current": 10.0
    }
  ],
  "documentation": [
    {
      "doc_name": "Техническая спецификация",
      "doc_path": "/docs/spec_2rmt14b4sh1v1v.pdf",
      "description": "Подробная техническая спецификация",
      "upload_date": "2023-01-01T00:00:00"
    }
  ],
  "created_at": "2023-01-01T00:00:00",
  "updated_at": "2023-01-01T00:00:00"
}
```

## Разработка

### Структура API

1. `api/models/` - Pydantic модели для валидации и сериализации данных
2. `api/routers/` - Маршруты API с разделением по функциональности
3. `api/database.py` - Модуль для работы с базой данных

### Работа с базой данных

Для работы с базой данных используется контекстные менеджеры:
```python
from api.database import get_db_cursor

with get_db_cursor() as cursor:
    cursor.execute("SELECT * FROM connector_types")
    results = cursor.fetchall()
``` 