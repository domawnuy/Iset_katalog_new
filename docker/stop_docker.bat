@echo off
echo Остановка контейнеров Docker для Iset Katalog...
cd %~dp0
docker-compose down
echo.
echo Контейнеры остановлены.
echo Данные базы данных сохранены в томе docker. 