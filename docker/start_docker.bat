@echo off
echo Запуск контейнеров Docker для Iset Katalog...
docker-compose up -d
echo.
echo Контейнеры запущены:
echo - API: http://localhost:8000
echo - Документация API: http://localhost:8000/docs
echo - База данных PostgreSQL на порту 5432
echo.
echo Для остановки выполните: stop_docker.bat
echo. 