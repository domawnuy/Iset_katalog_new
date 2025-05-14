"""
Product models for API
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Union, Any


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
    upload_date: str = Field(..., description="Дата документа")


class ContactRow(BaseModel):
    """
    Строка из таблицы схемы расположения контактов
    """
    size_code: int = Field(..., description="Условный размер вилки/розетки")
    connector_type: str = Field(..., description="Тип соединителя (2РМТ, 2РМДТ)")
    contact_diameter: float = Field(..., description="Диаметр контактов в мм")
    contacts_quantity: int = Field(..., description="Количество контактов")
    combination_code: str = Field(..., description="Номер сочетания контактов")
    max_current_summary: float = Field(..., description="Максимальная суммарная токовая нагрузка, А")
    max_current_contact: float = Field(..., description="Максимальная токовая нагрузка, А")
    max_working_voltage: int = Field(..., description="Максимальное рабочее напряжение, В")


class TechnicalSpecification(BaseModel):
    """
    Техническая характеристика
    """
    param_name: str = Field(..., description="Наименование параметра")
    param_value: Union[str, Dict[str, str]] = Field(..., description="Значение параметра")


class LifetimeByTemperature(BaseModel):
    """
    Минимальная наработка в зависимости от температуры
    """
    lifetime_hours: int = Field(..., description="Минимальная наработка соединителя, ч.")
    max_temperature: int = Field(..., description="Максимальная температура соединителя, °C")


class OverheatByLoad(BaseModel):
    """
    Температура перегрева контактов в зависимости от нагрузки
    """
    load_percent: int = Field(..., description="Токовая нагрузка от максимально допустимой по ТУ, %")
    overheat_temperature: int = Field(..., description="Температура перегрева контактов, Δt факт., °C")


class MechanicalFactor(BaseModel):
    """
    Механический фактор условий эксплуатации
    """
    name: str = Field(..., description="Наименование фактора")
    parameters: Dict[str, str] = Field(..., description="Параметры фактора")


class ClimaticFactor(BaseModel):
    """
    Климатический фактор условий эксплуатации
    """
    name: str = Field(..., description="Наименование фактора")
    value: str = Field(..., description="Значение")


class DimensionTable(BaseModel):
    """
    Таблица размеров для определенного типа соединителя
    """
    title: str = Field(..., description="Название таблицы")
    headers: List[str] = Field(..., description="Заголовки столбцов")
    rows: List[Dict[str, Any]] = Field(..., description="Строки таблицы")


class ConnectorOrderInfo(BaseModel):
    """
    Информация для заказа соединителя
    """
    connector_type: str = Field(..., description="Тип соединителя (2РМТ, 2РМДТ)")
    size_codes: List[str] = Field(..., description="Условные размеры корпуса")
    body_types: Dict[str, str] = Field(..., description="Типы корпуса")
    nozzle_types: Dict[str, str] = Field(..., description="Типы патрубка")
    nut_types: Dict[str, str] = Field(..., description="Типы гайки патрубка")
    contacts_quantity: List[str] = Field(..., description="Количество контактов")
    connector_parts: Dict[str, str] = Field(..., description="Части соединителя")
    contact_combinations: Dict[str, str] = Field(..., description="Обозначение сочетаний контактов")
    contact_coatings: Dict[str, str] = Field(..., description="Виды покрытия контактов")
    heat_resistance: Dict[str, str] = Field(..., description="Теплостойкость")
    special_designs: Dict[str, str] = Field(..., description="Специальное исполнение")
    climate_designs: str = Field(..., description="Всеклиматическое исполнение")
    example_connector: List[str] = Field(..., description="Пример обозначения соединителей при заказе")


class ProductDetail(BaseModel):
    """
    Детальная информация о продукте
    """
    # Основная информация
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
    
    # Детальная информация
    description: str = Field("", description="Описание соединителя")
    purpose: str = Field("", description="Назначение соединителя")
    parts_info: str = Field("", description="Информация о составе соединителя")
    design_features: str = Field("", description="Конструктивные особенности")
    interchangeability: str = Field("", description="Взаимозаменяемость")
    
    # Технические параметры
    contacts_info: List[ContactInfo] = Field([], description="Информация о контактах")
    technical_specs: List[TechnicalSpecification] = Field([], description="Технические характеристики")
    lifetime_table: List[LifetimeByTemperature] = Field([], description="Таблица минимальной наработки")
    overheat_table: List[OverheatByLoad] = Field([], description="Таблица температуры перегрева")
    
    # Условия эксплуатации
    mechanical_factors: List[MechanicalFactor] = Field([], description="Механические факторы")
    climatic_factors: List[ClimaticFactor] = Field([], description="Климатические факторы")
    
    # Схемы и размеры
    contact_layout: List[ContactRow] = Field([], description="Схемы расположения контактов")
    dimension_tables: List[DimensionTable] = Field([], description="Габаритные и установочные размеры")
    
    # Информация для заказа
    order_info: Optional[ConnectorOrderInfo] = Field(None, description="Информация для заказа")
    
    # Документация и изображения
    documentation: List[Documentation] = Field([], description="Технические спецификации")
    images: List[str] = Field([], description="Пути к изображениям соединителя")
    
    # Метаданные
    created_at: str = Field(..., description="Дата создания записи")
    updated_at: str = Field(..., description="Дата последнего обновления") 