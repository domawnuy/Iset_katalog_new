#!/bin/bash
# Переходим в корневую директорию проекта
cd "$(dirname "$0")"
echo "Остановка контейнеров Docker для Iset Katalog..."
docker-compose down
echo ""
echo "Контейнеры остановлены."
echo "Данные базы данных сохранены в томе docker." 