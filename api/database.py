"""
Database connection module
"""
import os
from contextlib import contextmanager
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Загрузка переменных окружения
load_dotenv()

# Параметры подключения к БД
DB_PARAMS = {
    "dbname": os.getenv("DB_NAME", "iset_katalog"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", ""),
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432")
}


@contextmanager
def get_db_connection():
    """
    Контекстный менеджер для работы с подключением к базе данных
    """
    conn = None
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        yield conn
    except psycopg2.DatabaseError as error:
        if conn is not None:
            conn.rollback()
        raise Exception(f"Ошибка базы данных: {error}")
    finally:
        if conn is not None:
            conn.close()


@contextmanager
def get_db_cursor(commit=False):
    """
    Контекстный менеджер для работы с курсором базы данных
    """
    with get_db_connection() as conn:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        try:
            yield cursor
            if commit:
                conn.commit()
        finally:
            cursor.close() 