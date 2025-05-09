"""
Main FastAPI application module
"""
from fastapi import FastAPI

from api.routers import groups, products

app = FastAPI(
    title="Iset Katalog API",
    description="API для каталога соединителей",
    version="0.1.0"
)

# Подключаем роутеры
app.include_router(groups.router)
app.include_router(products.router)

@app.get("/")
async def root():
    """
    Корневой маршрут
    """
    return {"message": "Добро пожаловать в API каталога соединителей"} 