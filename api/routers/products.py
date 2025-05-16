"""
Router for products
"""
from fastapi import APIRouter, HTTPException, Query, Path
from typing import List, Dict, Any, Optional
import logging

from api.models.product import (
    ProductPreview, ProductPage, ProductDetail, ContactInfo, 
    TechnicalSpecification, LifetimeByTemperature, OverheatByLoad,
    MechanicalFactor, ClimaticFactor, DimensionTable, ConnectorOrderInfo,
    ContactRow, Documentation
)
from api.database import get_db_cursor

router = APIRouter(
    prefix="/Products",
    tags=["products"],
    responses={404: {"description": "Продукт не найден"}},
)


@router.get("/GetProductsByGroupId", response_model=ProductPage)
async def get_products_by_group_id(
    group_id: int,
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100)
):
    """
    Получение списка изделий по идентификатору группы с пагинацией
    
    Parameters:
    - **group_id**: Идентификатор группы изделий
    - **page**: Номер страницы (начиная с 1)
    - **page_size**: Количество элементов на странице (от 1 до 100)
    """
    try:
        with get_db_cursor() as cursor:
            # Получаем общее количество соединителей заданного типа
            cursor.execute(
                """
                SELECT COUNT(*) AS total_count 
                FROM connector_series cs
                WHERE cs.type_id = %s
                """, 
                (group_id,)
            )
            total_count = cursor.fetchone()["total_count"]
            
            # Вычисляем смещение для пагинации
            offset = (page - 1) * page_size
            
            # Получаем список изделий с пагинацией
            cursor.execute(
                """
                SELECT 
                    cs.series_id AS product_id,
                    cs.series_name AS product_name
                FROM 
                    connector_series cs
                WHERE 
                    cs.type_id = %s
                ORDER BY 
                    cs.series_name
                LIMIT %s OFFSET %s
                """, 
                (group_id, page_size, offset)
            )
            products = cursor.fetchall()
            
            # Обновляем пути к изображениям
            for product in products:
                product["product_image_path"] = f"/api/Images/GetProductImage/{product['product_id']}"
            
            return {
                "items": products,
                "total_count": total_count,
                "page": page,
                "page_size": page_size
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка базы данных: {str(e)}")


@router.get("/GetById", response_model=ProductDetail)
async def get_product_by_id(product_id: int):
    """
    Получение детальной информации о продукте по его идентификатору
    
    Parameters:
    - **product_id**: Идентификатор продукта
    """
    try:
        with get_db_cursor() as cursor:
            # Проверка наличия продукта в базе данных
            cursor.execute(
                """
                SELECT COUNT(*) as count
                FROM connector_series
                WHERE series_id = %s
                """,
                (product_id,)
            )
            
            count = cursor.fetchone()["count"]
            if count == 0:
                raise HTTPException(status_code=404, detail="Продукт не найден")
            
            # Получаем основную информацию о продукте
            cursor.execute(
                """
                SELECT series_id, series_name, description 
                FROM connector_series 
                WHERE series_id = %s
                """, 
                (product_id,)
            )
            
            base_product = cursor.fetchone()
            
            # Получаем тип соединителя из имени серии
            connector_code = base_product["series_name"].split()[0] if ' ' in base_product["series_name"] else base_product["series_name"]
            
            cursor.execute(
                """
                SELECT type_id, type_name
                FROM connector_types
                WHERE code = %s
                """,
                (connector_code,)
            )
            
            connector_type = cursor.fetchone()
            connector_type_name = connector_type["type_name"] if connector_type else "Неизвестный тип"
            
            # Получаем параметры из электромеханической таблицы (если доступно)
            cursor.execute(
                """
                SELECT *
                FROM electromechanical_parameters
                WHERE series_name = %s
                """, 
                (base_product["series_name"],)
            )
            
            em_params = cursor.fetchone()
            
            # Формируем базовый результат
            result = {
                "connector_id": base_product["series_id"],
                "full_code": base_product["series_name"],
                "gost": "ГОСТ В 23476.8-86" if not em_params else em_params.get("gost", "ГОСТ В 23476.8-86"),
                "connector_type": connector_type_name,
                "body_size": "стандартный" if not em_params else em_params.get("body_size", "стандартный"),
                "body_type": "стандартный" if not em_params else em_params.get("body_type", "стандартный"),
                "nozzle_type": None,
                "nut_type": None,
                "contacts_quantity": 0 if not em_params else em_params.get("contacts_quantity", 0),
                "connector_part": "розетка" if not em_params else em_params.get("connector_part", "розетка"),
                "contact_combination": "стандартное" if not em_params else em_params.get("contact_combination", "стандартное"),
                "contact_coating": "золото" if not em_params else em_params.get("contact_coating", "золото"),
                "heat_resistance": 100 if not em_params else em_params.get("heat_resistance", 100),
                "special_design": None, 
                "climate_design": "УХЛ" if not em_params else em_params.get("climate_design", "УХЛ"),
                "connection_type": "резьбовое" if not em_params else em_params.get("connection_type", "резьбовое"),
                "contacts_info": [],
                "documentation": [],
                "created_at": "2024-01-01",  # Заглушка
                "updated_at": "2024-01-01"   # Заглушка
            }
            
            # Получаем информацию о контактах напрямую из таблиц диаметров и характеристик
            try:
                cursor.execute(
                    """
                    SELECT 
                        cd.diameter,
                        cr.max_resistance,
                        cmc.max_current
                    FROM 
                        contact_diameters cd
                    LEFT JOIN
                        contact_resistance cr ON cd.diameter_id = cr.diameter_id
                    LEFT JOIN
                        contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
                    ORDER BY 
                        cd.diameter
                    """)
                
                contacts = cursor.fetchall()
                if contacts:
                    result["contacts_info"] = [
                        {
                            "diameter": float(c["diameter"]) if c["diameter"] else None,
                            "max_resistance": float(c["max_resistance"]) if c["max_resistance"] else None,
                            "max_current": float(c["max_current"]) if c["max_current"] else None
                        } 
                        for c in contacts
                    ]
            except Exception as e:
                # Если произошла ошибка, используем данные из представления
                try:
                    cursor.execute("SELECT * FROM v_contact_specs")
                    contacts = cursor.fetchall()
                    if contacts:
                        result["contacts_info"] = [
                            {
                                "diameter": float(c["diameter"]) if c["diameter"] else None,
                                "max_resistance": float(c["max_resistance"]) if c["max_resistance"] else None,
                                "max_current": float(c["max_current"]) if c["max_current"] else None
                            } 
                            for c in contacts
                        ]
                except Exception:
                    # В случае любых ошибок оставляем пустой список
                    pass
                
            # Добавляем документацию
            result["documentation"] = [
                {
                    "doc_name": "Техническая спецификация",
                    "doc_path": None,
                    "description": base_product["description"] or f"Спецификация для {base_product['series_name']}",
                    "upload_date": "2024-01-01"
                }
            ]
            
            return result
            
    except HTTPException:
        # Пробрасываем HTTPException дальше
        raise
    except Exception as e:
        # Для всех остальных ошибок возвращаем 500
        raise HTTPException(status_code=500, detail=f"Ошибка базы данных: {str(e)}")


@router.get("/GetDetailedById/{product_id}", response_model=ProductDetail)
async def get_detailed_product_by_id(
    product_id: int = Path(..., description="Идентификатор продукта")
):
    """
    Получение расширенной детальной информации о продукте по его идентификатору
    
    Parameters:
    - **product_id**: Идентификатор продукта
    
    Returns:
    - Подробная информация о продукте, включая технические характеристики, таблицы и схемы
    """
    try:
        with get_db_cursor() as cursor:
            # Проверяем наличие продукта
            cursor.execute(
                """
                SELECT COUNT(*) as count
                FROM connector_series
                WHERE series_id = %s
                """,
                (product_id,)
            )
            
            count = cursor.fetchone()["count"]
            if count == 0:
                raise HTTPException(status_code=404, detail="Продукт не найден")
            
            # Получаем базовую информацию о продукте методом GetById
            base_product = await get_product_by_id(product_id)
            
            # Расширяем базовый результат
            result = dict(base_product)
            
            # Добавляем описание на основе типа соединителя
            result["description"] = f"Соединители электрические цилиндрические низкочастотные {result['connector_type']}"
            result["description"] = f"""Предназначены для работы в электрических цепях постоянного и переменного (частотой до 3МГц) токов.
Соединители состоят из кабельной и приборной части.
Конструктивные особенности определяются исполнениями: так и кабельными, как и приборными частями.
Соединители {result['connector_type']} имеют различные схемы расположения контактов и взаимосочетания."""
            
            # Добавляем технические характеристики
            result["technical_specs"] = [
                {
                    "param_name": "Сопротивление контактов",
                    "param_value": {
                        "диаметр контакта, 1,0 мм": "не более 5,0 мОм",
                        "диаметр контакта, 1,5 мм": "не более 2,5 мОм",
                        "диаметр контакта, 2,0 мм": "не более 1,6 мОм",
                        "диаметр контакта, 3,0 мм": "не более 0,8 мОм"
                    }
                },
                {
                    "param_name": "Сопротивление изоляции",
                    "param_value": "не менее 5 000 МОм"
                },
                {
                    "param_name": "Максимальный ток на одиночный контакт",
                    "param_value": {
                        "диаметр контакта, 1,0 мм": "8,0 А",
                        "диаметр контакта, 1,5 мм": "15,0 А",
                        "диаметр контакта, 2,0 мм": "18,0 А",
                        "диаметр контакта, 3,0 мм": "32,0 А"
                    }
                },
                {
                    "param_name": "Максимальное рабочее напряжение",
                    "param_value": "560 В"
                },
                {
                    "param_name": "Количество сочленений - расчленений",
                    "param_value": "500"
                },
                {
                    "param_name": "Минимальный срок сохраняемости соединителей",
                    "param_value": "15 лет"
                }
            ]
            
            # Добавляем таблицу минимальной наработки
            result["lifetime_table"] = [
                {"lifetime_hours": 1000, "max_temperature": 150},
                {"lifetime_hours": 3000, "max_temperature": 125},
                {"lifetime_hours": 5000, "max_temperature": 120},
                {"lifetime_hours": 7500, "max_temperature": 113},
                {"lifetime_hours": 10000, "max_temperature": 105},
                {"lifetime_hours": 15000, "max_temperature": 100},
                {"lifetime_hours": 20000, "max_temperature": 96},
                {"lifetime_hours": 25000, "max_temperature": 94},
                {"lifetime_hours": 30000, "max_temperature": 92},
                {"lifetime_hours": 40000, "max_temperature": 88},
                {"lifetime_hours": 50000, "max_temperature": 84},
                {"lifetime_hours": 80000, "max_temperature": 79},
                {"lifetime_hours": 100000, "max_temperature": 75}
            ]
            
            # Добавляем таблицу перегрева
            result["overheat_table"] = [
                {"load_percent": 220, "overheat_temperature": 150},
                {"load_percent": 180, "overheat_temperature": 130},
                {"load_percent": 150, "overheat_temperature": 120},
                {"load_percent": 120, "overheat_temperature": 80},
                {"load_percent": 110, "overheat_temperature": 65},
                {"load_percent": 100, "overheat_temperature": 50},
                {"load_percent": 85, "overheat_temperature": 40},
                {"load_percent": 75, "overheat_temperature": 30},
                {"load_percent": 50, "overheat_temperature": 25},
                {"load_percent": 25, "overheat_temperature": 20}
            ]
            
            # Добавляем механические факторы
            result["mechanical_factors"] = [
                {
                    "name": "Синусоидальная вибрация",
                    "parameters": {
                        "диапазон частот": "1 – 5 000 Гц",
                        "амплитуда ускорения": "490 м/с² (50 g)"
                    }
                },
                {
                    "name": "Механический удар одиночного действия",
                    "parameters": {
                        "пиковое ударное ускорение": "5 000 м/с² (500 g)"
                    }
                },
                {
                    "name": "Механический удар многократного действия",
                    "parameters": {
                        "пиковое ударное ускорение": "1 000 м/с² (100 g)"
                    }
                }
            ]
            
            # Добавляем климатические факторы
            result["climatic_factors"] = [
                {
                    "name": "Повышенная рабочая температура среды",
                    "value": "100 °C"
                },
                {
                    "name": "Пониженная предельная температура среды",
                    "value": "минус 60 °C"
                },
                {
                    "name": "Атмосферное пониженное рабочее давление",
                    "value": "1,33х10⁻⁴ Па (1х10⁻⁶ мм рт. ст.)"
                },
                {
                    "name": "Повышенная относительная влажность воздуха при температуре +40 °C (без конденсации влаги)",
                    "value": "98 %"
                }
            ]
            
            # Добавляем схемы расположения контактов
            result["contact_layout"] = [
                {
                    "size_code": 14,
                    "connector_type": "2РМТ",
                    "contact_diameter": 1.0,
                    "contacts_quantity": 4,
                    "combination_code": "1",
                    "max_current_summary": 27.0,
                    "max_current_contact": 8.0,
                    "max_working_voltage": 560
                },
                {
                    "size_code": 18,
                    "connector_type": "2РМДТ",
                    "contact_diameter": 1.5,
                    "contacts_quantity": 4,
                    "combination_code": "5",
                    "max_current_summary": 50.0,
                    "max_current_contact": 15.0,
                    "max_working_voltage": 560
                },
                {
                    "size_code": 18,
                    "connector_type": "2РМТ",
                    "contact_diameter": 1.0,
                    "contacts_quantity": 7,
                    "combination_code": "1",
                    "max_current_summary": 40.0,
                    "max_current_contact": 7.0,
                    "max_working_voltage": 560
                },
                {
                    "size_code": 22,
                    "connector_type": "2РМТ",
                    "contact_diameter": 2.0,
                    "contacts_quantity": 2,
                    "combination_code": "3",
                    "max_current_summary": 80.0,
                    "max_current_contact": 18.0,
                    "max_working_voltage": 560
                },
                {
                    "size_code": 22,
                    "connector_type": "2РМТ",
                    "contact_diameter": 1.0,
                    "contacts_quantity": 10,
                    "combination_code": "1",
                    "max_current_summary": 58.0,
                    "max_current_contact": 7.0,
                    "max_working_voltage": 560
                }
            ]
            
            # Добавляем таблицы размеров
            result["dimension_tables"] = [
                {
                    "title": "Приборная часть без патрубка",
                    "headers": ["D*", "L max", "D гайки", "D1", "A", "B"],
                    "rows": [
                        {"D*": "14", "L max": "25", "D гайки": "M14x1", "D1": "M16x1", "A": "17±0.1", "B": "24"},
                        {"D*": "18", "L max": "25", "D гайки": "M18x1", "D1": "M20x1", "A": "20±0.1", "B": "27"},
                        {"D*": "22", "L max": "27", "D гайки": "M22x1", "D1": "M24x1", "A": "23±0.1", "B": "30"}
                    ]
                },
                {
                    "title": "Кабельная часть без патрубка",
                    "headers": ["D гайки", "D1", "L max"],
                    "rows": [
                        {"D гайки": "M14x1", "D1": "22", "L max": "25"},
                        {"D гайки": "M18x1", "D1": "25", "L max": "25"},
                        {"D гайки": "M22x1", "D1": "29", "L max": "27"}
                    ]
                },
                {
                    "title": "Патрубок прямой с экранированной гайкой (ПЭ)",
                    "headers": ["D гайки", "d1", "L max"],
                    "rows": [
                        {"D гайки": "M14x1", "d1": "6,5", "L max": "28,7"},
                        {"D гайки": "M18x1", "d1": "10,5", "L max": "28,7"},
                        {"D гайки": "M22x1", "d1": "14", "L max": "28,7"}
                    ]
                }
            ]
            
            # Добавляем информацию для заказа
            result["order_info"] = {
                "connector_type": "2РМТ, 2РМДТ",
                "size_codes": ["14", "18", "22"],
                "body_types": {
                    "Б": "блочный (приборный)",
                    "К": "кабельный"
                },
                "nozzle_types": {
                    "П": "прямой",
                    "У": "угловой"
                },
                "nut_types": {
                    "Э": "для экранированного кабеля",
                    "Н": "для неэкранированного кабеля"
                },
                "contacts_quantity": ["4", "7", "10"],
                "connector_parts": {
                    "Г": "розетка",
                    "Ш": "вилка"
                },
                "contact_combinations": {
                    "1": "все контакты Ø 1,0 мм",
                    "2": "все контакты Ø 1,5 мм",
                    "3": "все контакты Ø 2,0 мм или Ø 3,0 мм",
                    "5": "все контакты Ø 1,5 мм"
                },
                "contact_coatings": {
                    "А": "золото",
                    "В": "серебро"
                },
                "heat_resistance": {
                    "1": "100° C"
                },
                "special_designs": {
                    "Д": "левая розетка (только для проходных вилок)",
                    "В": "корпус блочный (приборный) без левой резьбы"
                },
                "climate_designs": "Всеклиматическое исполнение",
                "example_connector": [
                    "Вилка 2РМТ18БП1В1В  ГЕО.364.126ТУ.",
                    "Розетка 2РМТ18КП3Г1В1В  ГЕО.364.126ТУ"
                ]
            }
            
            # Добавляем пути к изображениям
            result["images"] = [
                f"/api/Images/GetProductImage/{product_id}",
                f"/api/Images/GetProductImage/{product_id}?view=front",
                f"/api/Images/GetProductImage/{product_id}?view=side",
                f"/api/Images/GetTechnicalDrawing/{product_id}"
            ]
            
            # Добавляем ссылки на документацию
            result["documentation"] = [
                {
                    "doc_name": "Техническая спецификация",
                    "doc_path": f"/api/Documents/GetDocumentById/1?product_id={product_id}",
                    "description": f"Спецификация для {result['connector_type']}",
                    "upload_date": "2024-01-01"
                },
                {
                    "doc_name": "ГОСТ В 23476.8-86",
                    "doc_path": f"/api/Documents/GetDocumentById/2",
                    "description": "Соединители электрические низкочастотные",
                    "upload_date": "2024-01-01"
                },
                {
                    "doc_name": "Каталог соединителей",
                    "doc_path": f"/api/Documents/GetDocumentById/3",
                    "description": "Полный каталог соединителей 2РМТ, 2РМДТ",
                    "upload_date": "2024-01-01"
                }
            ]
            
            return result
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении детальной информации: {str(e)}")


@router.get("/GetCatalogItems", response_model=List[ProductPreview])
async def get_catalog_items(
    type_filter: Optional[str] = Query(None, description="Фильтр по типу соединителя"),
    size_filter: Optional[str] = Query(None, description="Фильтр по размеру корпуса"),
    limit: int = Query(50, ge=1, le=100, description="Количество элементов")
):
    """
    Получение списка продуктов для каталога с возможностью фильтрации
    
    Parameters:
    - **type_filter**: Опциональный фильтр по типу соединителя
    - **size_filter**: Опциональный фильтр по размеру корпуса
    - **limit**: Максимальное количество элементов в результате
    
    Returns:
    - Список продуктов для отображения в каталоге
    """
    try:
        logging.info(f"GetCatalogItems вызван с параметрами: type_filter={type_filter}, size_filter={size_filter}, limit={limit}")
        
        # Пробуем использовать прямое подключение к БД с правильной кодировкой
        try:
            import psycopg2
            from database.connection.db_connector import get_db_connection
            
            # Получаем соединение с UTF-8 кодировкой
            conn = get_db_connection()
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
                # Базовый запрос без фильтров
                query = """
                SELECT 
                    cs.series_id AS product_id,
                    cs.series_name AS product_name,
                    '' AS product_image_path
                FROM 
                    connector_series cs
                """
                
                params = []
                where_clauses = []
                joins = []
                
                # Добавляем JOIN к типам соединителей всегда
                joins.append("JOIN connector_types ct ON cs.type_id = ct.type_id")
                
                # Фильтр по типу соединителя
                if type_filter:
                    logging.info(f"Применение фильтра по типу: {type_filter}")
                    if type_filter.isdigit():
                        # Числовой фильтр - ищем по ID типа
                        # Проверяем существование типа
                        cursor.execute("""
                            SELECT EXISTS(SELECT 1 FROM connector_types WHERE type_id = %s)
                        """, (int(type_filter),))
                        type_exists = cursor.fetchone()[0]
                        
                        if not type_exists:
                            logging.warning(f"Тип с ID {type_filter} не найден в базе данных")
                            raise HTTPException(status_code=400, detail=f"Тип соединителя с ID {type_filter} не найден в базе данных")
                            
                        where_clauses.append("cs.type_id = %s")
                        params.append(int(type_filter))
                    else:
                        # Текстовый фильтр - проверяем существование в базе
                        cursor.execute("""
                            SELECT EXISTS(SELECT 1 FROM connector_types 
                                         WHERE code = %s OR type_name = %s)
                        """, (type_filter, type_filter))
                        type_exists = cursor.fetchone()[0]
                        
                        if not type_exists:
                            logging.warning(f"Тип '{type_filter}' не найден в базе данных")
                            raise HTTPException(status_code=400, detail=f"Тип соединителя '{type_filter}' не найден в базе данных")
                            
                        # Текстовый фильтр - ищем по названию или коду типа
                        where_clauses.append("(ct.code = %s OR ct.type_name = %s)")
                        params.append(type_filter)
                        params.append(type_filter)
                
                # Фильтр по размеру корпуса
                if size_filter:
                    logging.info(f"Применение фильтра по размеру: {size_filter}")
                    try:
                        # Преобразуем в число для проверки, если возможно
                        size_code = int(size_filter)
                        
                        # Сначала проверяем, есть ли такой размер в базе
                        cursor.execute("""
                            SELECT size_id, size_code 
                            FROM connector_sizes 
                            WHERE size_code = %s
                        """, (size_code,))
                        
                        size_row = cursor.fetchone()
                        if size_row:
                            logging.info(f"Найден размер с id={size_row['size_id']} и кодом {size_row['size_code']}")
                            
                            # Добавляем JOIN к таблице series_sizes напрямую
                            joins.append("""
                                JOIN series_sizes ss ON cs.series_id = ss.series_id
                            """)
                            where_clauses.append("ss.size_id = %s")
                            params.append(size_row['size_id'])
                        else:
                            # Если размер не найден, возвращаем ошибку вместо всех продуктов
                            logging.warning(f"Размер с кодом {size_code} не найден в таблице connector_sizes")
                            raise HTTPException(
                                status_code=400, 
                                detail=f"Размер корпуса {size_code} не найден в базе данных. Доступные размеры: 14, 18, 22"
                            )
                    except ValueError:
                        # Если не число, возвращаем ошибку
                        logging.warning(f"Размер '{size_filter}' не является числом, некорректный формат")
                        raise HTTPException(
                            status_code=400, 
                            detail=f"Некорректный формат размера '{size_filter}'. Размер должен быть числом. Доступные размеры: 14, 18, 22"
                        )
                
                # Собираем полный запрос
                if joins:
                    query += " " + " ".join(joins)
                    
                if where_clauses:
                    query += " WHERE " + " AND ".join(where_clauses)
                
                # Добавляем сортировку и лимит
                query += " ORDER BY cs.series_name LIMIT %s"
                params.append(limit)
                
                # Логируем финальный запрос для отладки
                logging.info(f"SQL запрос: {query}")
                logging.info(f"Параметры: {params}")
                
                # Выполняем запрос
                cursor.execute(query, tuple(params))
                products = [dict(row) for row in cursor.fetchall()]
                logging.info(f"Найдено продуктов: {len(products)}")
                
                # Если ничего не найдено, возвращаем пустой список с информацией
                if not products:
                    logging.info("Не найдено продуктов по заданным критериям")
                
                # Добавляем пути к изображениям
                for product in products:
                    product["product_image_path"] = f"/api/Images/GetProductImage/{product['product_id']}"
                
                conn.close()
                return products
                
        except HTTPException:
            # Пробрасываем HTTP исключения дальше
            raise
        except Exception as e:
            # Если возникла ошибка, логируем её
            error_msg = str(e)
            logging.error(f"Ошибка при прямом подключении к БД: {error_msg}", exc_info=True)
            
            # Проверяем, не ошибка ли это с размером/типом, чтобы вернуть правильную ошибку
            if "не найден" in error_msg.lower() or "некорректный" in error_msg.lower():
                raise HTTPException(status_code=400, detail=error_msg)
            
            # Если другие ошибки, возвращаем общую ошибку сервера
            raise HTTPException(status_code=500, detail=f"Ошибка при получении элементов каталога: {error_msg}")
            
    except HTTPException:
        # Пробрасываем HTTP исключения дальше
        raise
    except Exception as e:
        error_detail = str(e)
        logging.error(f"Ошибка при получении элементов каталога: {error_detail}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Ошибка при получении элементов каталога: {error_detail}")


@router.get("/Search", response_model=List[ProductPreview])
async def search_products(
    query: str = Query(..., min_length=2, description="Поисковый запрос"),
    limit: int = Query(30, ge=1, le=100, description="Максимальное количество результатов")
):
    """
    Расширенный поиск продуктов по текстовому запросу
    
    Поиск выполняется по следующим полям:
    - Имя серии (точное и частичное совпадение)
    - Описание продукта
    - Название и код типа соединителя
    - Размер корпуса
    - Параметры в таблице electromechanical_parameters
    
    Parameters:
    - **query**: Текст для поиска
    - **limit**: Максимальное количество результатов
    
    Returns:
    - Список найденных продуктов
    """
    try:
        logging.info(f"[SEARCH] Начало поиска по запросу: '{query}', limit={limit}")
        
        # Проверяем, является ли запрос числом
        is_numeric = False
        numeric_value = None
        try:
            numeric_value = float(query)
            is_numeric = True
            logging.info(f"[SEARCH] Запрос интерпретирован как числовое значение: {numeric_value}")
        except ValueError:
            # Не число, продолжаем обработку как текста
            logging.info(f"[SEARCH] Запрос интерпретирован как текст")
            pass
        
        # Нормализуем строку запроса для улучшения поиска
        # Удаляем пробелы внутри строки соединителя (например, "2РМТ 14" -> "2РМТ14")
        normalized_query = query.replace(" ", "")
        logging.info(f"[SEARCH] Нормализованный запрос: '{normalized_query}'")
        
        with get_db_cursor() as cursor:
            # Проверяем существование данных в базе
            valid_query = False
            valid_reasons = []
            available_values = []
            
            # 1. Проверка на существование типа соединителя в БД
            cursor.execute(
                """
                SELECT code, type_name 
                FROM connector_types 
                WHERE code = %s OR type_name = %s OR code ILIKE %s OR type_name ILIKE %s
                """, 
                (query, query, f"%{query}%", f"%{query}%")
            )
            connector_types = cursor.fetchall()
            if connector_types:
                valid_query = True
                valid_reasons.append("тип соединителя")
                available_values.extend([t["code"] for t in connector_types])
                available_values.extend([t["type_name"] for t in connector_types])
            
            # 2. Проверка на существование серии соединителя в БД
            cursor.execute(
                """
                SELECT series_name 
                FROM connector_series 
                WHERE series_name = %s OR series_name ILIKE %s OR REPLACE(series_name, ' ', '') = %s
                """, 
                (query, f"%{query}%", normalized_query)
            )
            series = cursor.fetchall()
            if series:
                valid_query = True
                valid_reasons.append("серия соединителя")
                available_values.extend([s["series_name"] for s in series])
            
            # 3. Если запрос числовой, проверяем существование такого размера
            if is_numeric and numeric_value.is_integer():
                size_code = int(numeric_value)
                cursor.execute(
                    """
                    SELECT size_code 
                    FROM connector_sizes 
                    WHERE size_code = %s
                    """, 
                    (size_code,)
                )
                sizes = cursor.fetchall()
                if sizes:
                    valid_query = True
                    valid_reasons.append("размер корпуса")
                    available_values.extend([str(s["size_code"]) for s in sizes])
                else:
                    # Получаем доступные размеры для сообщения об ошибке
                    cursor.execute("SELECT size_code FROM connector_sizes ORDER BY size_code")
                    all_sizes = cursor.fetchall()
                    all_available_sizes = [str(s["size_code"]) for s in all_sizes]
                    
                    # Если запрос числовой, но размер не найден - сообщаем, что такой размер не существует
                    if not valid_query:
                        raise HTTPException(
                            status_code=400, 
                            detail=f"Размер корпуса {size_code} не найден в базе данных. Доступные размеры: {', '.join(all_available_sizes)}"
                        )
            
            # 4. Проверка на наличие в electromechanical_parameters
            # Проверяем существование таблицы
            cursor.execute("SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'electromechanical_parameters')")
            table_exists = cursor.fetchone()["exists"]
            
            if table_exists:
                search_term = f"%{query}%"
                cursor.execute(
                    """
                    SELECT DISTINCT series_name
                    FROM electromechanical_parameters
                    WHERE series_name ILIKE %s
                    LIMIT 5
                    """, 
                    (search_term,)
                )
                em_params = cursor.fetchall()
                if em_params:
                    valid_query = True
                    valid_reasons.append("электромеханические параметры")
                    available_values.extend([p["series_name"] for p in em_params])
            
            # Если запрос невалидный, возвращаем ошибку с доступными значениями
            if not valid_query:
                # Получаем примеры допустимых значений для справки
                cursor.execute("SELECT code FROM connector_types LIMIT 5")
                type_examples = [row["code"] for row in cursor.fetchall()]
                
                cursor.execute("SELECT series_name FROM connector_series LIMIT 5")
                series_examples = [row["series_name"] for row in cursor.fetchall()]
                
                cursor.execute("SELECT size_code FROM connector_sizes ORDER BY size_code LIMIT 5")
                size_examples = [str(row["size_code"]) for row in cursor.fetchall()]
                
                error_msg = (
                    f"Запрос '{query}' не найден в базе данных. Примеры допустимых значений: "
                    f"типы соединителей: {', '.join(type_examples)}, "
                    f"серии: {', '.join(series_examples)}, "
                    f"размеры: {', '.join(size_examples)}."
                )
                raise HTTPException(status_code=400, detail=error_msg)
            
            # Создаем словарь для отслеживания уникальных результатов
            results_dict = {}
            
            # 1. Ищем точное совпадение по имени серии
            logging.info(f"[SEARCH] Выполнение поиска по имени серии")
            cursor.execute(
                """
                SELECT 
                    cs.series_id, 
                    cs.series_name,
                    cs.description,
                    ct.type_name,
                    ct.code as type_code
                FROM 
                    connector_series cs
                JOIN 
                    connector_types ct ON cs.type_id = ct.type_id
                WHERE 
                    cs.series_name = %s OR
                    cs.series_name = %s OR
                    REPLACE(cs.series_name, ' ', '') = %s
                LIMIT %s
                """, 
                (query, query.upper(), normalized_query, limit)
            )
            exact_matches = cursor.fetchall()
            
            for match in exact_matches:
                results_dict[match["series_id"]] = {
                    "product_id": match["series_id"],
                    "product_name": match["series_name"],
                    "product_image_path": f"/api/Images/GetProductImage/{match['series_id']}",
                    "rank": 1,  # Наивысший ранг для точных совпадений
                    "match_type": "exact_name"
                }
                
            # 2. Ищем по подстроке в имени серии и описании
            logging.info(f"[SEARCH] Поиск по подстроке в имени серии и описании")
            search_term = f"%{query}%"
            normalized_search_term = f"%{normalized_query}%"
            
            cursor.execute(
                """
                SELECT 
                    cs.series_id, 
                    cs.series_name,
                    cs.description,
                    ct.type_name,
                    ct.code as type_code
                FROM 
                    connector_series cs
                JOIN 
                    connector_types ct ON cs.type_id = ct.type_id
                WHERE 
                    cs.series_name ILIKE %s OR
                    cs.description ILIKE %s OR
                    REPLACE(cs.series_name, ' ', '') ILIKE %s OR
                    ct.type_name ILIKE %s OR
                    ct.code ILIKE %s
                LIMIT %s
                """, 
                (search_term, search_term, normalized_search_term, search_term, search_term, limit)
            )
            
            partial_matches = cursor.fetchall()
            
            for match in partial_matches:
                if match["series_id"] not in results_dict:
                    results_dict[match["series_id"]] = {
                        "product_id": match["series_id"],
                        "product_name": match["series_name"],
                        "product_image_path": f"/api/Images/GetProductImage/{match['series_id']}",
                        "rank": 2,  # Средний ранг для частичных совпадений
                        "match_type": "partial_match"
                    }
            
            # 3. Если запрос числовой, ищем по размеру корпуса
            if is_numeric and numeric_value.is_integer():
                size_code = int(numeric_value)
                logging.info(f"[SEARCH] Поиск по размеру корпуса: {size_code}")
                
                # Так как мы уже проверили существование размера выше,
                # здесь не требуется дополнительная проверка
                cursor.execute(
                    """
                    SELECT 
                        cs.series_id, 
                        cs.series_name,
                        cs.description,
                        ct.type_name,
                        ct.code as type_code,
                        csz.size_code
                    FROM 
                        connector_series cs
                    JOIN 
                        connector_types ct ON cs.type_id = ct.type_id
                    JOIN 
                        series_sizes ss ON cs.series_id = ss.series_id
                    JOIN 
                        connector_sizes csz ON ss.size_id = csz.size_id
                    WHERE 
                        csz.size_code = %s
                    LIMIT %s
                    """, 
                    (size_code, limit)
                )
                
                size_matches = cursor.fetchall()
                
                for match in size_matches:
                    if match["series_id"] not in results_dict:
                        results_dict[match["series_id"]] = {
                            "product_id": match["series_id"],
                            "product_name": match["series_name"],
                            "product_image_path": f"/api/Images/GetProductImage/{match['series_id']}",
                            "rank": 3,  # Низкий ранг для совпадений по размеру
                            "match_type": "size_match"
                        }
            
            # 4. Ищем в таблице electromechanical_parameters, если таблица существует
            if table_exists:
                try:
                    logging.info(f"[SEARCH] Поиск в таблице электромеханических параметров")
                    
                    params = []
                    conditions = []
                    
                    # Добавляем условие поиска по имени серии
                    conditions.append("ep.series_name ILIKE %s")
                    params.append(search_term)
                    
                    # Если запрос числовой, ищем также по числовым параметрам
                    if is_numeric:
                        conditions.append("CAST(ep.contact_quantity AS TEXT) = %s")
                        params.append(query)
                        
                        conditions.append("(ep.contact_diameter IS NOT NULL AND ABS(ep.contact_diameter - %s) < 0.01)")
                        params.append(numeric_value)
                        
                        conditions.append("(ep.max_current IS NOT NULL AND ABS(ep.max_current - %s) < 0.01)")
                        params.append(numeric_value)
                    
                    sql_query = f"""
                    SELECT DISTINCT
                        cs.series_id, 
                        cs.series_name,
                        cs.description,
                        ep.contact_quantity,
                        ep.contact_diameter,
                        ep.max_current
                    FROM 
                        connector_series cs
                    JOIN 
                        electromechanical_parameters ep ON cs.series_name = ep.series_name
                    WHERE 
                        {" OR ".join(conditions)}
                    LIMIT %s
                    """
                    
                    params.append(limit)
                    
                    cursor.execute(sql_query, tuple(params))
                    
                    param_matches = cursor.fetchall()
                    
                    for match in param_matches:
                        if match["series_id"] not in results_dict:
                            results_dict[match["series_id"]] = {
                                "product_id": match["series_id"],
                                "product_name": match["series_name"],
                                "product_image_path": f"/api/Images/GetProductImage/{match['series_id']}",
                                "rank": 4,  # Самый низкий ранг для совпадений по параметрам
                                "match_type": "param_match"
                            }
                except Exception as e:
                    logging.error(f"[SEARCH] Ошибка при поиске в таблице electromechanical_parameters: {e}")
            
            # Преобразуем результаты в список и сортируем по рангу (сначала самые релевантные)
            results = list(results_dict.values())
            results.sort(key=lambda x: x["rank"])
            
            # Удаляем поля ранга и типа совпадения из конечного результата
            for result in results:
                if "rank" in result:
                    del result["rank"]
                if "match_type" in result:
                    del result["match_type"]
            
            # Ограничиваем количество результатов
            results = results[:limit]
            
            # Если после всех проверок результаты отсутствуют, возвращаем ошибку
            if not results:
                found_in = ", ".join(valid_reasons)
                raise HTTPException(
                    status_code=400, 
                    detail=f"По запросу '{query}' не найдено конкретных продуктов, хотя запрос был распознан как {found_in}."
                )
            
            logging.info(f"[SEARCH] Найдено {len(results)} результатов для запроса '{query}'")
            
            return results
            
    except HTTPException:
        # Пробрасываем HTTP исключения дальше
        raise
    except Exception as e:
        error_message = str(e)
        logging.error(f"[SEARCH] Ошибка при поиске продуктов: {error_message}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Ошибка при поиске продуктов: {error_message}") 