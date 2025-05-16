"""
Router for product groups
"""
from fastapi import APIRouter, HTTPException
from typing import List

from api.models.group import Group
from api.database import get_db_cursor

router = APIRouter(
    prefix="/Groups",
    tags=["groups"],
    responses={404: {"description": "Группа не найдена"}},
)


@router.get("/GetGroups", response_model=List[Group])
async def get_groups():
    """
    Получение списка групп изделий (Электрические низкочастотные цилиндрические соединители)
    """
    try:
        with get_db_cursor() as cursor:
            cursor.execute(
                """
                SELECT type_id AS group_id, type_name AS group_name 
                FROM connector_types 
                ORDER BY type_name
                """
            )
            groups = cursor.fetchall()
            return groups
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка базы данных: {str(e)}") 