"""
Main FastAPI application module
"""
from fastapi import FastAPI

from api.routers import groups, products

app = FastAPI(
    title="Iset Katalog API",
    description="""
    API для каталога соединителей 2РМТ, 2РМДТ и других типов.
    
    ## Функциональность
    
    * Получение списка групп изделий
    * Получение списка продуктов в группе с пагинацией
    * Детальная информация по конкретному изделию
    
    ## Формат данных
    
    Все данные передаются в формате JSON.
    """,
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Добавляем глобальный префикс /api для всех маршрутов
app.include_router(groups.router, prefix="/api")
app.include_router(products.router, prefix="/api")

@app.get("/")
async def root():
    """
    Корневой маршрут
    """
    return {"message": "Добро пожаловать в API каталога соединителей", 
            "docs_url": "/docs",
            "api_version": "0.1.0"} 