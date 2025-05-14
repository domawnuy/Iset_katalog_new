"""
Main FastAPI application module
"""
from fastapi import FastAPI
import logging
import os
import sys

from api.routers import groups, products, images, documents

# Настройка логирования
log_level = os.environ.get("LOG_LEVEL", "INFO")
numeric_level = getattr(logging, log_level.upper(), logging.INFO)

# Формат сообщений лога
log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Настраиваем корневой логгер
logging.basicConfig(
    level=numeric_level,
    format=log_format,
    handlers=[
        # Вывод в консоль
        logging.StreamHandler(sys.stdout),
        # Вывод в файл
        logging.FileHandler("api_server.log")
    ]
)

# Получаем логгер для модуля
logger = logging.getLogger(__name__)
logger.info("API сервер запущен с уровнем логирования: %s", log_level)

app = FastAPI(
    title="Iset Katalog API",
    description="""
    API для каталога соединителей 2РМТ, 2РМДТ и других типов.
    
    ## Функциональность
    
    * Получение списка групп изделий
    * Получение списка продуктов в группе с пагинацией
    * Детальная информация по конкретному изделию
    * Получение изображений и технических чертежей
    * Доступ к технической документации
    * Поиск по каталогу
    
    ## Формат данных
    
    Все данные передаются в формате JSON.
    """,
    version="0.2.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Добавляем глобальный префикс /api для всех маршрутов
app.include_router(groups.router, prefix="/api")
app.include_router(products.router, prefix="/api")
app.include_router(images.router, prefix="/api")
app.include_router(documents.router, prefix="/api")

@app.get("/")
async def root():
    """
    Корневой маршрут
    """
    logger.info("Запрос к корневому маршруту")
    return {"message": "Добро пожаловать в API каталога соединителей", 
            "docs_url": "/docs",
            "api_version": "0.2.0"} 