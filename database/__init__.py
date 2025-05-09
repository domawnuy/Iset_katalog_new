"""
Пакет для работы с базой данных соединителей 2РМТ, 2РМДТ.
Предоставляет интерфейсы для подключения, выполнения запросов 
и управления схемой базы данных.
"""
# Импортируем основные компоненты для удобного доступа
from database.connection import (
    execute_query, execute_query_single_result, 
    execute_transaction, execute_script_file
)

__all__ = [
    'execute_query', 'execute_query_single_result', 
    'execute_transaction', 'execute_script_file'
] 