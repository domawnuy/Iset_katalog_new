"""
Router for products
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List

from api.models.product import ProductPreview, ProductPage, ProductDetail

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
    # Заглушка для функциональности
    items = [
        {
            "product_id": 1,
            "product_name": "2РМТ14Б4Ш1В1В",
            "product_image_path": "/images/2rmt14b4sh1v1v.jpg"
        },
        {
            "product_id": 2,
            "product_name": "2РМТ14Б4Ш2В1В",
            "product_image_path": "/images/2rmt14b4sh2v1v.jpg"
        }
    ]
    return {
        "items": items,
        "total_count": 2,
        "page": page,
        "page_size": page_size
    }


@router.get("/GetById", response_model=ProductDetail)
async def get_product_by_id(product_id: int):
    """
    Получение детальной информации о продукте по его идентификатору
    """
    # Заглушка для функциональности
    return {
        "connector_id": product_id,
        "full_code": "2РМТ14Б4Ш1В1В",
        "gost": "ГОСТ 23325-78",
        "connector_type": "2РМТ",
        "body_size": "14",
        "body_type": "Блочный",
        "nozzle_type": "Прямой",
        "nut_type": "С гайкой",
        "contacts_quantity": 4,
        "connector_part": "Вилка",
        "contact_combination": "Ш",
        "contact_coating": "Золото",
        "heat_resistance": 250,
        "special_design": None,
        "climate_design": "Обычное",
        "connection_type": "Резьбовое",
        "contacts_info": [
            {
                "diameter": 1.5,
                "max_resistance": 4.0,
                "max_current": 10.0
            }
        ],
        "documentation": [
            {
                "doc_name": "Техническая спецификация",
                "doc_path": "/docs/spec_2rmt14b4sh1v1v.pdf",
                "description": "Подробная техническая спецификация",
                "upload_date": "2023-01-01T00:00:00"
            }
        ],
        "created_at": "2023-01-01T00:00:00",
        "updated_at": "2023-01-01T00:00:00"
    } 