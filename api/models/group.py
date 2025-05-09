"""
Group models for API
"""
from pydantic import BaseModel


class Group(BaseModel):
    """
    Модель группы изделий
    """
    group_id: int
    group_name: str 