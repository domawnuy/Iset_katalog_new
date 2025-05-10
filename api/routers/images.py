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
async def get_product_image(product_id: int):
    """
    Получение основного изображения продукта по его идентификатору
    
    Parameters:
    - **product_id**: Идентификатор продукта
    
    Returns:
    - Файл изображения (PNG, JPG)
    """
    try:
        # Здесь должна быть логика получения пути к изображению из БД по product_id
        # Пока просто заглушка
        image_path = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG" / f"product_{product_id}.png"
        
        # Для тестирования - предоставляем первое доступное изображение
        # В реальной системе будет логика выбора из БД
        if not image_path.exists():
            # Если нет конкретного изображения, вернем заглушку или первое доступное
            png_dir = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG"
            if png_dir.exists():
                for file in png_dir.glob("*.png"):
                    image_path = file
                    break
            
        if image_path.exists():
            return FileResponse(str(image_path), media_type="image/png")
        
        # Если изображение не найдено, вернем 404
        raise HTTPException(status_code=404, detail="Изображение не найдено")
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
        # Заглушка для демонстрации
        # В реальной системе будет логика получения списка из БД
        # Возвращаем пути к изображениям относительно API
        return [
            f"/api/Images/GetProductImage/{product_id}",
            f"/api/Images/GetProductImage/{product_id}?view=front",
            f"/api/Images/GetProductImage/{product_id}?view=back"
        ]
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
        # Здесь должна быть логика получения пути к чертежу из БД по product_id
        # Пока просто заглушка
        pdf_path = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF" / f"drawing_{product_id}.pdf"
        
        # Для тестирования - ищем первый доступный PDF
        if not pdf_path.exists():
            pdf_dir = IMAGES_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF"
            if pdf_dir.exists():
                for file in pdf_dir.glob("*.pdf"):
                    pdf_path = file
                    break
                    
        if pdf_path.exists():
            return FileResponse(str(pdf_path), media_type="application/pdf")
            
        # Если PDF не найден, вернем 404
        raise HTTPException(status_code=404, detail="Технический чертеж не найден")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении чертежа: {str(e)}") 