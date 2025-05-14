@echo off
echo Проверка статуса контейнеров Docker для Iset Katalog...
cd %~dp0

echo.
echo Статус контейнеров:
docker-compose ps

echo.
echo Логи API контейнера (последние 20 строк):
docker logs iset-katalog-api --tail 20

echo.
echo Проверка доступности API:
curl -s -o nul -w "%%{http_code}" http://localhost:8000/ || echo API недоступен

echo.
echo Проверка подключения к базе данных:
docker exec iset-katalog-db pg_isready -U postgres -d connector_catalog || echo База данных недоступна

echo. 