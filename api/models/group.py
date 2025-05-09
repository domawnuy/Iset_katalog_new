"""
Group models for API
"""
from pydantic import BaseModel, Field


class Group(BaseModel):
    """
    Модель группы изделий
    """
    group_id: int = Field(..., description="Уникальный идентификатор группы")
    group_name: str = Field(..., description="Наименование группы изделий") 