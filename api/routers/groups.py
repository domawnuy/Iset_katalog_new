"""
Router for product groups
"""
from fastapi import APIRouter, Depends, HTTPException
from typing import List

from api.models.group import Group

router = APIRouter(
    prefix="/api/Groups",
    tags=["groups"],
    responses={404: {"description": "Группа не найдена"}},
)


@router.get("/GetGroups", response_model=List[Group])
async def get_groups():
    """
    Получение списка групп изделий
    """
    # Заглушка для функциональности
    return [
        {"group_id": 1, "group_name": "2РМТ"},
        {"group_id": 2, "group_name": "2РМДТ"},
    ] 