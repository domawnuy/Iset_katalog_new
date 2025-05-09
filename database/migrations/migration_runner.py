"""
Утилита для управления миграциями базы данных.
Позволяет применять, отменять и проверять статус миграций.
"""
import os
import sys
import argparse
from database.connection import execute_script_file, execute_query, execute_query_single_result

def get_migration_files():
    """Получает список файлов миграций в отсортированном порядке"""
    migration_dir = os.path.dirname(os.path.abspath(__file__))
    migration_files = [
        f for f in os.listdir(migration_dir) 
        if f.endswith(".sql") and f[0].isdigit()
    ]
    return sorted(migration_files)

def get_applied_migrations():
    """Получает список уже примененных миграций"""
    try:
        # Проверяем существование таблицы миграций
        check_table = """
        SELECT EXISTS (
            SELECT FROM pg_tables
            WHERE schemaname = 'connector_schema'
            AND tablename = 'migrations'
        );
        """
        table_exists = execute_query_single_result(check_table)
        
        if not table_exists or not table_exists[0]:
            return []
            
        # Получаем список примененных миграций
        query = """
        SELECT migration_name 
        FROM connector_schema.migrations 
        ORDER BY id;
        """
        migrations = execute_query(query)
        return [m[0] for m in migrations] if migrations else []
    except Exception as e:
        print(f"Ошибка при получении примененных миграций: {e}")
        return []

def apply_migration(migration_file):
    """Применяет указанную миграцию"""
    migration_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), migration_file)
    print(f"Применение миграции: {migration_file}")
    
    return execute_script_file(migration_path)

def apply_migrations(target=None):
    """Применяет все необходимые миграции до указанной цели"""
    migration_files = get_migration_files()
    applied_migrations = get_applied_migrations()
    
    # Если указана целевая миграция, ограничиваем список файлов
    if target:
        try:
            target_index = migration_files.index(target)
            migration_files = migration_files[:target_index + 1]
        except ValueError:
            print(f"Миграция {target} не найдена.")
            return False
    
    # Определяем, какие миграции нужно применить
    to_apply = []
    for migration in migration_files:
        migration_name = os.path.splitext(migration)[0]
        if migration_name not in applied_migrations:
            to_apply.append(migration)
    
    # Если нет миграций для применения
    if not to_apply:
        print("Нет миграций для применения.")
        return True
    
    # Применяем миграции
    for migration in to_apply:
        if not apply_migration(migration):
            print(f"Ошибка при применении миграции: {migration}")
            return False
    
    print("Миграции успешно применены.")
    return True

def show_status():
    """Показывает статус миграций"""
    migration_files = get_migration_files()
    applied_migrations = get_applied_migrations()
    
    print("\nСтатус миграций:")
    print("-" * 60)
    print(f"{'Миграция':<30} | {'Статус':<20}")
    print("-" * 60)
    
    for migration in migration_files:
        migration_name = os.path.splitext(migration)[0]
        status = "Применена" if migration_name in applied_migrations else "Не применена"
        print(f"{migration:<30} | {status:<20}")
    
    print("-" * 60)

def main():
    """Основная функция"""
    parser = argparse.ArgumentParser(description='Утилита для управления миграциями базы данных')
    subparsers = parser.add_subparsers(dest='command', help='Команды')
    
    # Команда apply
    apply_parser = subparsers.add_parser('apply', help='Применить миграции')
    apply_parser.add_argument('--target', help='Целевая миграция (применятся все до неё включительно)')
    
    # Команда status
    status_parser = subparsers.add_parser('status', help='Показать статус миграций')
    
    args = parser.parse_args()
    
    if args.command == 'apply':
        success = apply_migrations(args.target)
        if not success:
            sys.exit(1)
    elif args.command == 'status':
        show_status()
    else:
        parser.print_help()

if __name__ == '__main__':
    main() 