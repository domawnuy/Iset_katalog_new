"""
Модуль для управления пулом соединений с базой данных.
Позволяет повторно использовать соединения для большей эффективности.
"""
import queue
import threading
from database.connection.db_connector import get_connection, close_connection

class ConnectionPool:
    """
    Класс для управления пулом соединений с базой данных.
    Обеспечивает эффективное повторное использование соединений.
    """
    _instance = None
    _lock = threading.Lock()
    
    def __new__(cls, max_connections=5):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(ConnectionPool, cls).__new__(cls)
                cls._instance._initialized = False
            return cls._instance
    
    def __init__(self, max_connections=5):
        if self._initialized:
            return
            
        self.max_connections = max_connections
        self.pool = queue.Queue(maxsize=max_connections)
        self.used_connections = 0
        self._lock = threading.Lock()
        self._initialized = True
        
        # Предварительное заполнение пула соединениями
        for _ in range(max_connections // 2):
            self._add_connection()
    
    def _add_connection(self):
        """Добавляет новое соединение в пул"""
        if self.used_connections < self.max_connections:
            conn = get_connection()
            self.pool.put(conn)
            self.used_connections += 1
    
    def get_connection(self):
        """
        Получает соединение из пула или создает новое, если пул пуст.
        
        Returns:
            psycopg2.connection: Соединение с базой данных
        """
        with self._lock:
            try:
                # Пытаемся получить соединение из пула без ожидания
                conn = self.pool.get(block=False)
                return conn
            except queue.Empty:
                # Если пул пуст, создаем новое соединение
                if self.used_connections < self.max_connections:
                    conn = get_connection()
                    self.used_connections += 1
                    return conn
                else:
                    # Если достигнут максимум соединений, ждем освобождения
                    conn = self.pool.get(block=True, timeout=30)
                    return conn
    
    def release_connection(self, conn):
        """
        Возвращает соединение в пул.
        
        Args:
            conn (psycopg2.connection): Соединение для возврата в пул
        """
        if conn:
            # Проверка, что соединение активно
            try:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT 1")
                # Возвращаем соединение в пул
                self.pool.put(conn)
            except Exception:
                # Если соединение неактивно, закрываем его и создаем новое
                close_connection(conn)
                self.used_connections -= 1
                self._add_connection()
    
    def close_all(self):
        """Закрывает все соединения в пуле"""
        while not self.pool.empty():
            conn = self.pool.get()
            close_connection(conn)
            self.used_connections -= 1
        
# Создаем глобальный объект для доступа к пулу соединений
connection_pool = ConnectionPool()

def get_connection_from_pool():
    """
    Получает соединение из пула.
    
    Returns:
        psycopg2.connection: Соединение с базой данных
    """
    return connection_pool.get_connection()

def release_connection_to_pool(conn):
    """
    Возвращает соединение в пул.
    
    Args:
        conn (psycopg2.connection): Соединение для возврата
    """
    connection_pool.release_connection(conn) 