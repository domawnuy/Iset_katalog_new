"""
Product models for API
"""
from pydantic import BaseModel
from typing import List, Optional


class ProductPreview(BaseModel):
    """
    Модель предварительного просмотра продукта
    """
    product_id: int
    product_name: str
    product_image_path: Optional[str] = None


class ProductPage(BaseModel):
    """
    Модель страницы с продуктами
    """
    items: List[ProductPreview]
    total_count: int
    page: int
    page_size: int


class ContactInfo(BaseModel):
    """
    Информация о контактах
    """
    diameter: float
    max_resistance: Optional[float] = None
    max_current: Optional[float] = None


class Documentation(BaseModel):
    """
    Документация по продукту
    """
    doc_name: str
    doc_path: Optional[str] = None
    description: Optional[str] = None
    upload_date: str


class ProductDetail(BaseModel):
    """
    Детальная информация о продукте
    """
    connector_id: int
    full_code: str
    gost: str
    connector_type: str
    body_size: str
    body_type: str
    nozzle_type: Optional[str] = None
    nut_type: Optional[str] = None
    contacts_quantity: int
    connector_part: str
    contact_combination: str
    contact_coating: str
    heat_resistance: int
    special_design: Optional[str] = None
    climate_design: str
    connection_type: str
    contacts_info: List[ContactInfo] = []
    documentation: List[Documentation] = []
    created_at: str
    updated_at: str 