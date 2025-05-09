"""
Router for products
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List

from api.models.product import ProductPreview, ProductPage, ProductDetail
from api.database import get_db_cursor

router = APIRouter(
    prefix="/api/Products",
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
    """
    try:
        with get_db_cursor() as cursor:
            # Получаем общее количество
            cursor.execute(
                """
                SELECT COUNT(*) AS total_count 
                FROM connectors 
                WHERE type_id = %s
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
                    c.connector_id AS product_id,
                    c.full_code AS product_name,
                    cd.doc_path AS product_image_path
                FROM 
                    connectors c
                LEFT JOIN 
                    connector_documentation cd ON c.connector_id = cd.connector_id 
                    AND cd.doc_name LIKE '%image%'
                WHERE 
                    c.type_id = %s
                ORDER BY 
                    c.full_code
                LIMIT %s OFFSET %s
                """, 
                (group_id, page_size, offset)
            )
            products = cursor.fetchall()
            
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
    """
    try:
        with get_db_cursor() as cursor:
            # Получаем основную информацию о продукте
            cursor.execute(
                """
                SELECT 
                    c.connector_id,
                    c.full_code,
                    c.gost,
                    ct.type_name AS connector_type,
                    bs.size_value AS body_size,
                    bt.name AS body_type,
                    nt.name AS nozzle_type,
                    nut.description AS nut_type,
                    cq.quantity AS contacts_quantity,
                    cp.name AS connector_part,
                    cc.code AS contact_combination,
                    coat.material AS contact_coating,
                    hr.temperature AS heat_resistance,
                    sd.name AS special_design,
                    cd.description AS climate_design,
                    cont.name AS connection_type,
                    c.created_at,
                    c.updated_at
                FROM 
                    connectors c
                JOIN 
                    connector_types ct ON c.type_id = ct.type_id
                JOIN 
                    body_sizes bs ON c.size_id = bs.size_id
                JOIN 
                    body_types bt ON c.body_type_id = bt.body_type_id
                LEFT JOIN 
                    nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id
                LEFT JOIN 
                    nut_types nut ON c.nut_type_id = nut.nut_type_id
                JOIN 
                    contact_quantities cq ON c.quantity_id = cq.quantity_id
                JOIN 
                    connector_parts cp ON c.part_id = cp.part_id
                JOIN 
                    contact_combinations cc ON c.combination_id = cc.combination_id
                JOIN 
                    contact_coatings coat ON c.coating_id = coat.coating_id
                JOIN 
                    heat_resistance hr ON c.resistance_id = hr.resistance_id
                LEFT JOIN 
                    special_designs sd ON c.special_design_id = sd.special_design_id
                JOIN 
                    climate_designs cd ON c.climate_id = cd.climate_id
                JOIN 
                    connection_types cont ON c.connection_type_id = cont.connection_type_id
                WHERE 
                    c.connector_id = %s
                """, 
                (product_id,)
            )
            product = cursor.fetchone()
            
            if not product:
                raise HTTPException(status_code=404, detail="Продукт не найден")
            
            # Получаем информацию о контактах (сопротивление + токи)
            cursor.execute(
                """
                SELECT 
                    cd.diameter,
                    cr.max_resistance,
                    cmc.max_current
                FROM 
                    connectors c
                JOIN 
                    contact_combinations cc ON c.combination_id = cc.combination_id
                JOIN 
                    combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
                JOIN 
                    contact_diameters cd ON cdm.diameter_id = cd.diameter_id
                LEFT JOIN 
                    contact_resistance cr ON cd.diameter_id = cr.diameter_id
                LEFT JOIN 
                    contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
                WHERE 
                    c.connector_id = %s
                """, 
                (product_id,)
            )
            contacts_info = cursor.fetchall()
            
            # Получаем документацию
            cursor.execute(
                """
                SELECT 
                    doc_name,
                    doc_path,
                    description,
                    upload_date
                FROM 
                    connector_documentation
                WHERE 
                    connector_id = %s
                """, 
                (product_id,)
            )
            documentation = cursor.fetchall()
            
            # Объединяем всю информацию
            product["contacts_info"] = contacts_info
            product["documentation"] = documentation
            
            return product
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка базы данных: {str(e)}") 