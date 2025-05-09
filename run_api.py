"""
Скрипт для запуска API каталога соединителей.
"""
import os
import uvicorn
from dotenv import load_dotenv

# Загружаем переменные окружения из .env файла
load_dotenv()

if __name__ == "__main__":
    # Определяем порт из переменных окружения или используем порт по умолчанию
    port = int(os.getenv("API_PORT", 8000))
    
    # Настройки хоста
    host = os.getenv("API_HOST", "0.0.0.0")
    
    # Режим отладки
    debug = os.getenv("API_DEBUG", "False").lower() in ("true", "1", "t")
    
    print(f"Запуск API сервера на http://{host}:{port}")
    print(f"Документация доступна по адресу: http://{host}:{port}/docs")
    
    # Запускаем сервер uvicorn
    uvicorn.run(
        "api.main:app", 
        host=host, 
        port=port, 
        reload=debug
    ) 