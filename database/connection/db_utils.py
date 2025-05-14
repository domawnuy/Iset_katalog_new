"""
Утилитарные функции для работы с базой данных.
Предоставляет упрощенный интерфейс для выполнения запросов.
"""
from database.connection.connection_pool import get_connection_from_pool, release_connection_to_pool

def execute_query(query, params=None):
    """
    Выполняет SQL запрос и возвращает результат.
    
    Args:
        query (str): SQL запрос для выполнения
        params (tuple, dict, optional): Параметры для SQL запроса
    
    Returns:
        list: Результат запроса, если запрос возвращает данные
    """
    conn = None
    try:
        conn = get_connection_from_pool()
        with conn.cursor() as cursor:
            cursor.execute(query, params)
            # Проверяем, возвращает ли запрос данные
            if cursor.description:
                return cursor.fetchall()
            return None
    finally:
        if conn:
            release_connection_to_pool(conn)

def execute_query_single_result(query, params=None):
    """
    Выполняет SQL запрос и возвращает первую строку результата.
    
    Args:
        query (str): SQL запрос для выполнения
        params (tuple, dict, optional): Параметры для SQL запроса
    
    Returns:
        tuple: Первая строка результата или None, если результат пуст
    """
    conn = None
    try:
        conn = get_connection_from_pool()
        with conn.cursor() as cursor:
            cursor.execute(query, params)
            # Проверяем, возвращает ли запрос данные
            if cursor.description:
                return cursor.fetchone()
            return None
    finally:
        if conn:
            release_connection_to_pool(conn)

def execute_transaction(queries_and_params):
    """
    Выполняет несколько запросов как одну транзакцию.
    
    Args:
        queries_and_params (list): Список кортежей (query, params)
    
    Returns:
        bool: True если транзакция выполнена успешно, иначе False
    """
    conn = None
    try:
        conn = get_connection_from_pool()
        conn.autocommit = False
        with conn.cursor() as cursor:
            for query, params in queries_and_params:
                cursor.execute(query, params)
        conn.commit()
        return True
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Ошибка выполнения транзакции: {e}")
        return False
    finally:
        if conn:
            release_connection_to_pool(conn)

def execute_script_file(file_path):
    """
    Выполняет SQL скрипт из файла.
    
    Args:
        file_path (str): Путь к SQL файлу
    
    Returns:
        bool: True если скрипт выполнен успешно, иначе False
    """
    conn = None
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        conn = get_connection_from_pool()
        conn.autocommit = False
        with conn.cursor() as cursor:
            cursor.execute(sql_script)
        conn.commit()
        return True
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Ошибка выполнения SQL скрипта из файла {file_path}: {e}")
        return False
    finally:
        if conn:
            release_connection_to_pool(conn) 