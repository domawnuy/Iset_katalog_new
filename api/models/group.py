"""
Group models for API
"""
from pydantic import BaseModel, Field


class Group(BaseModel):
    """
    Модель группы изделий
    Представляет собой электрический низкочастотный цилиндрический соединитель
    """
    group_id: int = Field(..., description="Уникальный идентификатор группы")
    group_name: str = Field(..., description="Наименование группы изделий (РМТ, РМДТ и др.)") 