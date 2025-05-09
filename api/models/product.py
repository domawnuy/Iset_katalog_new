"""
Product models for API
"""
from pydantic import BaseModel, Field
from typing import List, Optional


class ProductPreview(BaseModel):
    """
    Модель предварительного просмотра продукта
    """
    product_id: int = Field(..., description="Уникальный идентификатор продукта")
    product_name: str = Field(..., description="Наименование продукта (полный код)")
    product_image_path: Optional[str] = Field(None, description="Путь к изображению продукта")


class ProductPage(BaseModel):
    """
    Модель страницы с продуктами
    """
    items: List[ProductPreview] = Field(..., description="Список продуктов на странице")
    total_count: int = Field(..., description="Общее количество продуктов")
    page: int = Field(..., description="Текущая страница")
    page_size: int = Field(..., description="Размер страницы")


class ContactInfo(BaseModel):
    """
    Информация о контактах
    """
    diameter: float = Field(..., description="Диаметр контакта в мм")
    max_resistance: Optional[float] = Field(None, description="Максимальное сопротивление контакта в мОм")
    max_current: Optional[float] = Field(None, description="Максимальный ток в амперах")


class Documentation(BaseModel):
    """
    Документация по продукту
    """
    doc_name: str = Field(..., description="Наименование документа")
    doc_path: Optional[str] = Field(None, description="Путь к файлу документа")
    description: Optional[str] = Field(None, description="Описание документа")
    upload_date: str = Field(..., description="Дата загрузки документа")


class ProductDetail(BaseModel):
    """
    Детальная информация о продукте
    """
    connector_id: int = Field(..., description="Уникальный идентификатор соединителя")
    full_code: str = Field(..., description="Полный код соединителя")
    gost: str = Field(..., description="ГОСТ или ТУ соединителя")
    connector_type: str = Field(..., description="Тип соединителя (2РМТ, 2РМДТ и др.)")
    body_size: str = Field(..., description="Размер корпуса")
    body_type: str = Field(..., description="Тип корпуса (блочный, кабельный)")
    nozzle_type: Optional[str] = Field(None, description="Тип патрубка (прямой, угловой)")
    nut_type: Optional[str] = Field(None, description="Тип гайки")
    contacts_quantity: int = Field(..., description="Количество контактов")
    connector_part: str = Field(..., description="Часть соединителя (вилка, розетка)")
    contact_combination: str = Field(..., description="Сочетание контактов")
    contact_coating: str = Field(..., description="Покрытие контактов")
    heat_resistance: int = Field(..., description="Теплостойкость в градусах Цельсия")
    special_design: Optional[str] = Field(None, description="Специальное исполнение")
    climate_design: str = Field(..., description="Климатическое исполнение")
    connection_type: str = Field(..., description="Тип соединения (резьбовое, байонетное)")
    contacts_info: List[ContactInfo] = Field([], description="Информация о контактах")
    documentation: List[Documentation] = Field([], description="Документация по соединителю")
    created_at: str = Field(..., description="Дата создания записи")
    updated_at: str = Field(..., description="Дата последнего обновления") 