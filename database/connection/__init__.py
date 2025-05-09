"""
Модуль подключения к базе данных.
Предоставляет интерфейс для работы с PostgreSQL.
"""
from database.connection.db_config import (
    DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, DB_SCHEMA
)
from database.connection.db_connector import get_connection, close_connection
from database.connection.connection_pool import (
    get_connection_from_pool, release_connection_to_pool
)
from database.connection.db_utils import (
    execute_query, execute_query_single_result, 
    execute_transaction, execute_script_file
)

__all__ = [
    'DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'DB_SCHEMA',
    'get_connection', 'close_connection',
    'get_connection_from_pool', 'release_connection_to_pool',
    'execute_query', 'execute_query_single_result', 
    'execute_transaction', 'execute_script_file'
] 