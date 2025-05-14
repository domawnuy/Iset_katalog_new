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
│   ├── functions/          # Функции для работы с БД
│   └── Zapchasti/          # Папка с изображениями и исходниками
│       └── 2РМТ, 2РМДТ/    # Изображения для соединителей типа 2РМТ и 2РМДТ
│           └── ishodniki/  # Исходные файлы
│               └── PNG/    # PNG и SVG изображения соединителей
│                   └── PDF/# PDF файлы с техническими чертежами
├── .env                    # Переменные окружения
├── check_db.py             # Скрипт проверки структуры и целостности БД
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
DB_NAME=connector_catalog
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

## Проверка структуры базы данных

Для проверки структуры и целостности базы данных выполните:
```bash
python check_db.py
```

Скрипт проверит:
- Наличие всех необходимых таблиц
- Структуру таблиц (колонки, типы данных)
- Корректность работы ключевых SQL-запросов API
- Наличие внешних ключей и связей между таблицами

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
      "product_id": 5,
      "product_name": "2РМТ",
      "product_image_path": "/api/Images/GetProductImage/5"
    }
  ],
  "total_count": 1,
  "page": 1,
  "page_size": 10
}
```

### 3. Получение детальной информации об изделии

```
GET /api/Products/GetById?product_id=5
```

**Параметры:**
- `product_id` - идентификатор изделия

**Ответ:**
```json
{
  "connector_id": 5,
  "full_code": "2РМТ",
  "gost": "ГОСТ В 23476.8-86",
  "connector_type": "2РМТ",
  "body_size": "стандартный",
  "body_type": "стандартный",
  "contact_coating": "золото",
  "heat_resistance": 100,
  "climate_design": "УХЛ",
  "connection_type": "резьбовое",
  "contacts_info": [
    {
      "diameter": 1.0,
      "max_resistance": 5.0,
      "max_current": 8.0
    }
  ],
  "documentation": [
    {
      "doc_name": "Техническая спецификация",
      "doc_path": "/api/Documents/GetDocumentById/1?product_id=5",
      "description": "Спецификация для 2РМТ",
      "upload_date": "2024-01-01"
    }
  ],
  "images": [
    "/api/Images/GetProductImage/5",
    "/api/Images/GetProductImage/5?view=front",
    "/api/Images/GetProductImage/5?view=side",
    "/api/Images/GetTechnicalDrawing/5"
  ],
  "created_at": "2024-01-01",
  "updated_at": "2024-01-01"
}
```

### 4. Поиск продуктов в каталоге

```
GET /api/Products/Search?query=2РМТ&limit=30
```

**Параметры:**
- `query` - текст для поиска (минимальная длина - 2 символа)
- `limit` - максимальное количество результатов (от 1 до 100, по умолчанию 30)

**Ответ:**
```json
[
  {
    "product_id": 5,
    "product_name": "2РМТ",
    "product_image_path": "/api/Images/GetProductImage/5"
  },
  {
    "product_id": 6,
    "product_name": "2РМДТ",
    "product_image_path": "/api/Images/GetProductImage/6"
  }
]
```

**Особенности поиска:**
- Поиск выполняется по имени серии, описанию, названию и коду типа соединителя, размеру корпуса, параметрам
- Реализована строгая валидация поисковых запросов с информативными сообщениями об ошибках
- Поиск учитывает различные варианты написания обозначений соединителей
- Поддерживается поиск по числовым значениям (например, по размеру корпуса)

**Примеры ошибок валидации:**
```json
{
  "detail": "Размер корпуса 25 не найден в базе данных. Доступные размеры: 14, 18, 22"
}

{
  "detail": "Запрос 'xyz123' не найден в базе данных. Примеры допустимых значений: типы соединителей: 2РМТ, 2РМДТ, серии: 2РМТ, 2РМДТ, размеры: 14, 18, 22."
}
```

### 5. Получение изображений

```
GET /api/Images/GetProductImage/{product_id}
GET /api/Images/GetProductImage/{product_id}?view=front
GET /api/Images/GetProductImage/{product_id}?view=side
GET /api/Images/GetTechnicalDrawing/{product_id}
```

## Разработка

### Структура API

1. `api/models/` - Pydantic модели для валидации и сериализации данных
2. `api/routers/` - Маршруты API с разделением по функциональности:
   - `groups.py` - API группы соединителей
   - `products.py` - API получения информации о соединителях
   - `documents.py` - API работы с документацией
   - `images.py` - API доступа к изображениям
3. `api/database.py` - Модуль для работы с базой данных

### Работа с базой данных

Для работы с базой данных используется контекстные менеджеры:
```python
from api.database import get_db_cursor

with get_db_cursor() as cursor:
    cursor.execute("SELECT * FROM connector_types")
    results = cursor.fetchall()
```

## Последние обновления

### Обновление от 13.05.2024
- Реализован улучшенный эндпоинт поиска продуктов `/api/Products/Search` с расширенной проверкой данных
- Добавлена строгая валидация входных параметров во всех API-эндпоинтах
- Улучшены информативные сообщения об ошибках с рекомендациями по допустимым значениям
- Реализована нормализация поисковых запросов для учета различных вариантов написания обозначений
- Добавлены дополнительные проверки существования таблиц и правильности форматов данных

### Обновление от 13.05.2024 (предыдущее)
- Добавлено поле `type_id` в таблицу `connector_series` для корректной связи с `connector_types`
- Добавлены изображения для соединителей 2РМТ и 2РМДТ (PNG, SVG, PDF)
- Исправлены запросы API для корректного получения продуктов по группе
- Добавлен скрипт проверки структуры и целостности БД (`check_db.py`)
- Обновлена документация и улучшены описания API-эндпоинтов 

## Запуск в Docker

Проект поддерживает запуск в контейнерах Docker, что позволяет быстро развернуть как базу данных, так и API-сервер единой командой.

### Требования
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (для Windows/Mac) или Docker Engine (для Linux)
- Docker Compose

### Запуск проекта
Для запуска проекта в Docker выполните:

**Windows:**
```bash
cd docker
start_docker.bat
```

**Linux/Mac:**
```bash
cd docker
chmod +x start_docker.sh
./start_docker.sh
```

После запуска:
- API будет доступен по адресу: http://localhost:8000
- Документация API (Swagger): http://localhost:8000/docs
- PostgreSQL будет доступен на порту 5432

### Остановка проекта
Для остановки проекта выполните:

**Windows:**
```bash
cd docker
stop_docker.bat
```

**Linux/Mac:**
```bash
cd docker
chmod +x stop_docker.sh
./stop_docker.sh
```

### Структура Docker-инфраструктуры
- **db** - контейнер с PostgreSQL
- **api** - контейнер с FastAPI-приложением

Данные PostgreSQL сохраняются в именованном томе `iset-katalog-postgres-data` и не удаляются при остановке контейнеров.

Все файлы Docker-инфраструктуры расположены в папке `docker/`:
- **docker/Dockerfile** - образ для API-сервера
- **docker/docker-compose.yml** - конфигурация контейнеров
- **docker/start_docker.bat** и **docker/start_docker.sh** - скрипты запуска
- **docker/stop_docker.bat** и **docker/stop_docker.sh** - скрипты остановки 