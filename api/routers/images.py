"""
Router for product images
"""
from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import StreamingResponse, FileResponse
import os
from pathlib import Path
from typing import List

router = APIRouter(
    prefix="/Images",
    tags=["images"],
    responses={
        404: {"description": "Изображение не найдено"},
        400: {"description": "Неверный запрос"}
    },
)

# Корневая папка для хранения изображений
IMAGES_ROOT = Path("database/Zapchasti")

@router.get("/GetProductImage/{product_id}")
async def get_product_image(product_id: int, view: str = None):
    """
    Получение изображения продукта по его идентификатору
    
    Parameters:
    - **product_id**: Идентификатор продукта
    - **view**: Вид изображения (front, side и т.д.)
    
    Returns:
    - Файл изображения (PNG, JPG)
    """
    try:
        # Базовая директория с изображениями
        png_dir = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG"
        
        # Сначала проверяем наличие специфичного изображения для продукта
        product_specific_path = png_dir / f"product_{product_id}.png"
        
        # Если запрошен определенный вид и это число
        if view and view.isdigit():
            view_image_path = png_dir / f"{view}.png"
            if view_image_path.exists():
                return FileResponse(str(view_image_path), media_type="image/png")
        
        # Если запрошен определенный вид (front, side и т.д.)
        if view:
            # Для каталога с сериями 2РМТ/2РМДТ используем нумерованные изображения
            view_mapping = {
                "front": "1.png",  # Фронтальное изображение
                "side": "2.png",   # Боковое изображение
                "details": "3.png", # Детали
                "specs": "4.png",   # Спецификации
                "table": "5.png"    # Таблица размеров
            }
            
            if view in view_mapping:
                view_image_path = png_dir / view_mapping[view]
                if view_image_path.exists():
                    return FileResponse(str(view_image_path), media_type="image/png")
        
        # Если есть конкретное изображение для продукта
        if product_specific_path.exists():
            return FileResponse(str(product_specific_path), media_type="image/png")
        
        # Если нет конкретного изображения, проверяем по идентификатору продукта
        if product_id == 5:  # 2РМТ
            # Используем общее изображение 2РМТ
            general_image = png_dir / "1.png"
            if general_image.exists():
                return FileResponse(str(general_image), media_type="image/png")
        
        elif product_id == 6:  # 2РМДТ
            # Используем общее изображение 2РМДТ
            general_image = png_dir / "1.png"
            if general_image.exists():
                return FileResponse(str(general_image), media_type="image/png")
        
        # По умолчанию используем одно из доступных изображений в зависимости от product_id
        numbered_images = [f"{i}.png" for i in range(1, 6)]
        image_index = (product_id % 5)  # Используем остаток от деления для циклического выбора
        selected_image = numbered_images[image_index]
        
        selected_path = png_dir / selected_image
        if selected_path.exists():
            return FileResponse(str(selected_path), media_type="image/png")
        
        # Если ни одно из вышеуказанных изображений не найдено, 
        # используем любое доступное изображение
        for file in png_dir.glob("*.png"):
            return FileResponse(str(file), media_type="image/png")
        
        # Если изображение не найдено, вернем 404
        raise HTTPException(status_code=404, detail=f"Изображение для продукта {product_id} не найдено")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении изображения: {str(e)}")


@router.get("/GetProductImages/{product_id}", response_model=List[str])
async def get_product_images(product_id: int):
    """
    Получение списка URL всех изображений продукта
    
    Parameters:
    - **product_id**: Идентификатор продукта
    
    Returns:
    - Список URL изображений
    """
    try:
        # Формируем список URL доступных изображений для продукта
        base_url = f"/api/Images/GetProductImage/{product_id}"
        
        # Базовое изображение продукта
        image_urls = [base_url]
        
        # Стандартные виды для всех продуктов
        views = ["front", "side", "details", "specs", "table"]
        for view in views:
            image_urls.append(f"{base_url}?view={view}")
        
        # Добавляем URL для чертежа
        image_urls.append(f"/api/Images/GetTechnicalDrawing/{product_id}")
        
        # Дополнительно проверяем, существуют ли нумерованные изображения
        for i in range(1, 6):
            image_urls.append(f"{base_url}?view={i}")
            
        return image_urls
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении списка изображений: {str(e)}")


@router.get("/GetTechnicalDrawing/{product_id}")
async def get_technical_drawing(product_id: int):
    """
    Получение технического чертежа продукта
    
    Parameters:
    - **product_id**: Идентификатор продукта
    
    Returns:
    - Файл чертежа (PDF или изображение)
    """
    try:
        # Базовая директория для чертежей
        # Сначала проверяем в PDF директории
        pdf_dir = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF"
        
        # Проверяем наличие специфичного чертежа для продукта
        drawing_path = pdf_dir / f"drawing_{product_id}.pdf"
        
        # Если есть конкретный чертеж для продукта, возвращаем его
        if drawing_path.exists():
            return FileResponse(str(drawing_path), media_type="application/pdf")
        
        # Если нет чертежа в PDF, используем PNG изображения для чертежей
        png_dir = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG"
        
        # Проверяем наличие специфичного изображения чертежа для продукта
        drawing_png = png_dir / f"drawing_{product_id}.png"
        if drawing_png.exists():
            return FileResponse(str(drawing_png), media_type="image/png")
        
        # Если нет, используем изображения с техническими данными (предполагаем, что это 5.png)
        tech_drawing = png_dir / "5.png"
        if tech_drawing.exists():
            return FileResponse(str(tech_drawing), media_type="image/png")
        
        # Если нет, пробуем изображение с размерами (предполагаем, что это 4.png)
        dimensions = png_dir / "4.png"
        if dimensions.exists():
            return FileResponse(str(dimensions), media_type="image/png")
            
        # Если ни один из вышеуказанных файлов не найден, ищем любой PDF
        if pdf_dir.exists():
            pdfs = list(pdf_dir.glob("*.pdf"))
            if pdfs:
                return FileResponse(str(pdfs[0]), media_type="application/pdf")
        
        # Если PDF не найден, ищем любую картинку из нумерованных
        for i in range(1, 6):
            img_path = png_dir / f"{i}.png"
            if img_path.exists():
                return FileResponse(str(img_path), media_type="image/png")
                
        # Если ничего не найдено, вернем 404
        raise HTTPException(status_code=404, detail=f"Технический чертеж для продукта {product_id} не найден")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении чертежа: {str(e)}") 