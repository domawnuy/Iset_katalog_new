"""
Утилита командной строки для выполнения операций с базой данных.
Позволяет инициализировать базу данных, выполнять миграции и запросы.
"""
import argparse
import os
import sys
from database.connection import execute_script_file

def init_db():
    """Инициализирует базу данных, выполняя unified скрипт"""
    script_path = os.path.join('database', 'init_db_unified.sql')
    success = execute_script_file(script_path)
    if success:
        print("База данных успешно инициализирована!")
    else:
        print("Ошибка при инициализации базы данных.")
        sys.exit(1)

def init_db_sequential():
    """Инициализирует базу данных последовательно выполняя отдельные скрипты"""
    schema_files = [
        os.path.join('database', 'schema', '01_base_tables.sql'),
        os.path.join('database', 'schema', '02_dictionary_tables.sql'),
        os.path.join('database', 'schema', '03_technical_tables.sql'),
        os.path.join('database', 'schema', '04_relation_tables.sql')
    ]
    
    data_files = [
        os.path.join('database', 'data', '01_base_dictionary_data.sql'),
        os.path.join('database', 'data', '02_technical_data.sql'),
        os.path.join('database', 'data', '03_relation_data.sql'),
        os.path.join('database', 'data', '04_connectors_data.sql')
    ]
    
    object_files = [
        os.path.join('database', 'views', '01_connector_views.sql'),
        os.path.join('database', 'functions', '01_connector_functions.sql'),
        os.path.join('database', 'indexes', '01_connector_indexes.sql')
    ]
    
    test_files = [
        os.path.join('database', 'tests', '01_integrity_tests.sql'),
        os.path.join('database', 'examples', '01_example_queries.sql')
    ]
    
    # Создание схемы
    print("Создание таблиц...")
    for file in schema_files:
        if os.path.exists(file):
            print(f"Выполнение скрипта: {file}")
            if not execute_script_file(file):
                print(f"Ошибка при выполнении скрипта: {file}")
                sys.exit(1)
    
    # Заполнение данными
    print("Заполнение данными...")
    for file in data_files:
        if os.path.exists(file):
            print(f"Выполнение скрипта: {file}")
            if not execute_script_file(file):
                print(f"Ошибка при выполнении скрипта: {file}")
                sys.exit(1)
    
    # Создание объектов БД
    print("Создание объектов базы данных...")
    for file in object_files:
        if os.path.exists(file):
            print(f"Выполнение скрипта: {file}")
            if not execute_script_file(file):
                print(f"Ошибка при выполнении скрипта: {file}")
                sys.exit(1)
    
    # Тесты и примеры
    print("Выполнение тестов и примеров...")
    for file in test_files:
        if os.path.exists(file):
            print(f"Выполнение скрипта: {file}")
            if not execute_script_file(file):
                print(f"Ошибка при выполнении скрипта: {file}")
                sys.exit(1)
    
    print("База данных успешно инициализирована!")

def execute_query_file(file_path):
    """Выполняет SQL запрос из файла"""
    if not os.path.exists(file_path):
        print(f"Файл не найден: {file_path}")
        sys.exit(1)
    
    success = execute_script_file(file_path)
    if success:
        print(f"Запрос из файла {file_path} успешно выполнен!")
    else:
        print(f"Ошибка при выполнении запроса из файла: {file_path}")
        sys.exit(1)

def main():
    """Основная функция командной строки"""
    parser = argparse.ArgumentParser(description='Утилита для работы с базой данных соединителей')
    subparsers = parser.add_subparsers(dest='command', help='Команды')
    
    # Команда init-db
    init_parser = subparsers.add_parser('init-db', help='Инициализация базы данных')
    init_parser.add_argument('--sequential', action='store_true', 
                            help='Использовать последовательное выполнение скриптов')
    
    # Команда execute
    exec_parser = subparsers.add_parser('execute', help='Выполнить SQL запрос из файла')
    exec_parser.add_argument('file', help='Путь к SQL файлу для выполнения')
    
    args = parser.parse_args()
    
    if args.command == 'init-db':
        if args.sequential:
            init_db_sequential()
        else:
            init_db()
    elif args.command == 'execute':
        execute_query_file(args.file)
    else:
        parser.print_help()

if __name__ == '__main__':
    main() 