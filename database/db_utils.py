"""
Утилиты для работы с базой данных
"""
import psycopg2
import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

# Параметры подключения
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'connector_catalog')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'aboba1337')

# Строка подключения
CONNECTION_STRING = f"host={DB_HOST} port={DB_PORT} dbname={DB_NAME} user={DB_USER} password={DB_PASSWORD}"


def execute_query(query, params=None):
    """
    Выполняет SQL запрос и возвращает результат.
    
    Args:
        query (str): SQL запрос
        params (tuple, optional): Параметры запроса
        
    Returns:
        list: Результат запроса или None в случае ошибки
    """
    conn = None
    try:
        conn = psycopg2.connect(CONNECTION_STRING)
        with conn.cursor() as cursor:
            # Устанавливаем схему поиска
            cursor.execute("SET search_path TO public;")
            cursor.execute(query, params)
            if cursor.description:
                return cursor.fetchall()
            conn.commit()
            return None
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Ошибка выполнения запроса: {e}")
        return None
    finally:
        if conn:
            conn.close()


def execute_query_single_result(query, params=None):
    """
    Выполняет SQL запрос и возвращает первую строку результата.
    
    Args:
        query (str): SQL запрос
        params (tuple, optional): Параметры запроса
        
    Returns:
        tuple: Первая строка результата или None
    """
    conn = None
    try:
        conn = psycopg2.connect(CONNECTION_STRING)
        with conn.cursor() as cursor:
            # Устанавливаем схему поиска
            cursor.execute("SET search_path TO public;")
            cursor.execute(query, params)
            if cursor.description:
                return cursor.fetchone()
            conn.commit()
            return None
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Ошибка выполнения запроса: {e}")
        return None
    finally:
        if conn:
            conn.close()


def execute_dml_query(query, params=None):
    """
    Выполняет DML запрос (INSERT, UPDATE, DELETE) и возвращает количество затронутых строк.
    
    Args:
        query (str): SQL запрос
        params (tuple, optional): Параметры запроса
        
    Returns:
        int: Количество затронутых строк или -1 в случае ошибки
    """
    conn = None
    try:
        conn = psycopg2.connect(CONNECTION_STRING)
        with conn.cursor() as cursor:
            cursor.execute(query, params)
            rowcount = cursor.rowcount
            conn.commit()
            return rowcount
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Ошибка выполнения DML запроса: {e}")
        return -1
    finally:
        if conn:
            conn.close() 