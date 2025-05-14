#!/bin/bash
echo "Остановка контейнеров Docker для Iset Katalog..."
cd "$(dirname "$0")"
docker-compose down
echo ""
echo "Контейнеры остановлены."
echo "Данные базы данных сохранены в томе docker." 