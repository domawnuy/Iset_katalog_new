"""
Модуль для установления соединения с базой данных PostgreSQL.
Предоставляет функции для создания и управления соединениями.
"""
import psycopg2
import psycopg2.extras
from database.connection.db_config import CONNECTION_STRING, DB_SCHEMA

def get_connection():
    """
    Создает и возвращает новое соединение с базой данных.
    
    Returns:
        psycopg2.connection: Объект соединения с базой данных
    """
    try:
        conn = psycopg2.connect(CONNECTION_STRING)
        conn.autocommit = False
        
        # Устанавливаем схему поиска
        with conn.cursor() as cursor:
            cursor.execute(f"SET search_path TO public;")
        
        return conn
    except Exception as e:
        print(f"Ошибка подключения к базе данных: {e}")
        raise

def get_db_connection():
    """
    Создает и возвращает новое соединение с базой данных с явной установкой кодировки UTF-8.
    
    Returns:
        psycopg2.connection: Объект соединения с базой данных с установленной кодировкой UTF-8
    """
    try:
        conn = psycopg2.connect(CONNECTION_STRING, client_encoding='UTF8')
        conn.autocommit = True
        
        # Устанавливаем схему поиска
        with conn.cursor() as cursor:
            cursor.execute(f"SET search_path TO public;")
            # Явно устанавливаем кодировку для сессии
            cursor.execute("SET client_encoding TO 'UTF8';")
        
        return conn
    except Exception as e:
        print(f"Ошибка подключения к базе данных с UTF-8 кодировкой: {e}")
        raise

def close_connection(conn):
    """
    Закрывает соединение с базой данных.
    
    Args:
        conn (psycopg2.connection): Соединение для закрытия
    """
    if conn:
        conn.close() 