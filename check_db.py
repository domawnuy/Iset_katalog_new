"""
Скрипт для проверки структуры базы данных и запросов API
"""
import os
import psycopg2
import psycopg2.extras
from psycopg2 import sql
from dotenv import load_dotenv

# Загружаем переменные окружения из .env файла
load_dotenv()

# Получаем параметры подключения из переменных окружения
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "connector_catalog")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "aboba1337")
DB_SCHEMA = os.getenv("DB_SCHEMA", "public")

# Создаем строку подключения
def get_connection():
    """Создание соединения с базой данных"""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

def print_table_info(cursor, table_name):
    """Вывод информации о структуре таблицы и количестве записей"""
    # Получаем информацию о колонках
    cursor.execute("""
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
    """, (DB_SCHEMA, table_name))
    
    columns = cursor.fetchall()
    
    print(f"🔍 Таблица {table_name} ({len(columns)} колонок):")
    for col in columns:
        nullable = "NULL" if col["is_nullable"] == "YES" else "NOT NULL"
        default = f" DEFAULT {col['column_default']}" if col["column_default"] else ""
        print(f"  - {col['column_name']} ({col['data_type']}) {nullable}{default}")
    
    # Получаем количество записей
    cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
    count = cursor.fetchone()["count"]
    print(f"  Количество записей: {count}")

def check_database_structure():
    """Проверка структуры базы данных"""
    try:
        with get_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
                # Получаем список всех таблиц
                cursor.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = %s
                    AND table_type = 'BASE TABLE'
                    ORDER BY table_name
                """, (DB_SCHEMA,))
                
                tables = cursor.fetchall()
                print(f"=== СТРУКТУРА БАЗЫ ДАННЫХ ===")
                print(f"Найдено {len(tables)} таблиц.")
                
                # Проверяем ключевые таблицы для API
                print(f"\n=== ПРОВЕРКА КЛЮЧЕВЫХ ТАБЛИЦ, ИСПОЛЬЗУЕМЫХ В API ===\n")
                key_tables = [
                    "connector_types", "connector_series", "body_sizes", "body_types", 
                    "contact_combinations", "contact_diameters", "connector_parts", 
                    "contact_coatings", "heat_resistance", "climate_designs", 
                    "special_designs", "connection_types", "nozzle_types", "nut_types"
                ]
                
                for table in key_tables:
                    print_table_info(cursor, table)
                    print()
                    
    except Exception as e:
        print(f"❌ Ошибка при проверке структуры базы данных: {str(e)}")

def check_api_queries():
    """Проверка запросов API"""
    print("=== ПРОВЕРКА ЗАПРОСОВ API ===\n")
    try:
        with get_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
                # 1. Проверяем запрос для получения групп
                try:
                    cursor.execute("""
                        SELECT 
                            type_id AS id,
                            type_name AS name
                        FROM 
                            connector_types
                        ORDER BY 
                            type_name
                    """)
                    
                    results = cursor.fetchall()
                    print(f"1. Запрос для получения групп:")
                    print(f"  ✅ Запрос выполнен успешно. Получено записей: {len(results)}")
                    print(f"  Пример данных:")
                    for row in results[:3]:  # Показываем до 3 записей
                        print(f"    - ID: {row['id']}, Название: {row['name']}")
                    print()
                except Exception as e:
                    print(f"  ❌ Ошибка запроса: {str(e)}\n")
                
                # 2. Проверяем запрос для получения продуктов по группе
                try:
                    cursor.execute("""
                        SELECT 
                            cs.series_id AS product_id,
                            cs.series_name AS product_name
                        FROM 
                            connector_series cs
                        WHERE 
                            cs.type_id = 1
                        ORDER BY 
                            cs.series_name
                        LIMIT 10
                    """)
                    
                    results = cursor.fetchall()
                    print(f"2. Запрос для получения продуктов по группе:")
                    print(f"  ✅ Запрос выполнен успешно. Получено записей: {len(results)}")
                    print(f"  Пример данных:")
                    for row in results[:3]:  # Показываем до 3 записей
                        print(f"    - ID: {row['product_id']}, Название: {row['product_name']}")
                    print()
                except Exception as e:
                    print(f"  ❌ Ошибка запроса: {str(e)}\n")
                
                # 3. Проверяем запрос для получения детальной информации о продукте
                try:
                    cursor.execute("""
                        SELECT 
                            series_id,
                            series_name
                        FROM 
                            connector_series 
                        LIMIT 1
                    """)
                    
                    product = cursor.fetchone()
                    if product:
                        product_id = product["series_id"]
                        print(f"3. Запрос для получения детальной информации о продукте:")
                        print(f"  ✅ Проверка успешна для продукта ID: {product_id}, Название: {product['series_name']}")
                    else:
                        print(f"3. Запрос для получения детальной информации о продукте:")
                        print(f"  ⚠️ Не найдено ни одного продукта для проверки")
                except Exception as e:
                    print(f"  ❌ Ошибка при проверке детальной информации: {str(e)}\n")
    except Exception as e:
        print(f"❌ Ошибка при проверке запросов API: {str(e)}")

def check_referential_integrity():
    """Проверка ссылочной целостности"""
    print("\n=== ПРОВЕРКА ССЫЛОЧНОЙ ЦЕЛОСТНОСТИ ===")
    try:
        with get_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
                # Проверяем наличие внешних ключей
                cursor.execute("""
                    SELECT 
                        tc.constraint_name, 
                        tc.table_name, 
                        kcu.column_name, 
                        ccu.table_name AS foreign_table_name,
                        ccu.column_name AS foreign_column_name
                    FROM 
                        information_schema.table_constraints AS tc 
                    JOIN 
                        information_schema.key_column_usage AS kcu
                        ON tc.constraint_name = kcu.constraint_name
                        AND tc.table_schema = kcu.table_schema
                    JOIN 
                        information_schema.constraint_column_usage AS ccu
                        ON ccu.constraint_name = tc.constraint_name
                        AND ccu.table_schema = tc.table_schema
                    WHERE 
                        tc.constraint_type = 'FOREIGN KEY' 
                        AND tc.table_schema = %s
                    ORDER BY tc.table_name, kcu.column_name
                """, (DB_SCHEMA,))
                
                fks = cursor.fetchall()
                if fks:
                    print(f"  ✅ Найдено {len(fks)} внешних ключей:")
                    for fk in fks[:5]:  # Показываем только первые 5 для краткости
                        print(f"    - {fk['table_name']}.{fk['column_name']} -> {fk['foreign_table_name']}.{fk['foreign_column_name']}")
                    if len(fks) > 5:
                        print(f"    ... и ещё {len(fks) - 5} внешних ключей")
                else:
                    print(f"  ⚠️ Не найдено ни одного внешнего ключа")
    except Exception as e:
        print(f"  ❌ Ошибка при проверке внешних ключей: {str(e)}")

def main():
    """Основная функция"""
    # Проверка структуры базы данных
    check_database_structure()
    
    # Проверка запросов API
    check_api_queries()
    
    # Проверка ссылочной целостности
    check_referential_integrity()
    
    # Выводы и рекомендации
    print("\n=== ВЫВОДЫ И РЕКОМЕНДАЦИИ ===")
    print("1. Проверьте соответствие запросов структуре таблиц")
    print("2. Убедитесь, что все JOIN-соединения корректны и необходимые поля присутствуют")
    print("3. Проверьте наличие записей в таблицах для тестирования API")

if __name__ == "__main__":
    main() 