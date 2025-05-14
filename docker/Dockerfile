FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование файлов проекта
COPY . .

# Экспорт порта
EXPOSE 8000

# Запуск API-сервера
CMD ["python", "run_api_server.py"] 