"""
Router for product documentation
"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
import os
from pathlib import Path
from typing import List

from api.models.product import Documentation
from api.database import get_db_cursor

router = APIRouter(
    prefix="/Documents",
    tags=["documents"],
    responses={
        404: {"description": "Документ не найден"},
        400: {"description": "Неверный запрос"}
    },
)

# Корневая папка для хранения документов
DOCUMENTS_ROOT = Path("database/Zapchasti")

@router.get("/GetDocumentById/{doc_id}")
async def get_document_by_id(doc_id: int):
    """
    Получение документа по его идентификатору
    
    Parameters:
    - **doc_id**: Идентификатор документа
    
    Returns:
    - Файл документа (PDF, DOCX и т.д.)
    """
    try:
        # Здесь должна быть логика получения пути к документу из БД по doc_id
        # Пока просто заглушка
        with get_db_cursor() as cursor:
            cursor.execute(
                """
                SELECT * FROM connector_documentation
                WHERE doc_id = %s
                """,
                (doc_id,)
            )
            
            doc = cursor.fetchone()
            if not doc:
                raise HTTPException(status_code=404, detail="Документ не найден")
            
            # В реальной системе здесь будет doc_path из БД
            # Для демонстрации проверим несколько путей
            doc_path = None
            
            # Проверяем физические пути
            test_paths = [
                DOCUMENTS_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF" / f"doc_{doc_id}.pdf",
                DOCUMENTS_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF/WORD" / f"doc_{doc_id}.docx"
            ]
            
            for path in test_paths:
                if path.exists():
                    doc_path = path
                    break
            
            # Если документ не найден в проверяемых путях, ищем любой доступный PDF для демонстрации
            if not doc_path:
                pdf_dir = DOCUMENTS_ROOT / "2РМТ, 2РМДТ/ishodniki/PNG/PDF"
                if pdf_dir.exists():
                    for file in pdf_dir.glob("*.pdf"):
                        doc_path = file
                        break
            
            if doc_path and doc_path.exists():
                # Определяем тип контента на основе расширения
                extension = doc_path.suffix.lower()
                media_type = "application/pdf" if extension == ".pdf" else "application/octet-stream"
                
                if extension == ".docx":
                    media_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    
                return FileResponse(str(doc_path), media_type=media_type)
            
            # Если документ не найден, вернем 404
            raise HTTPException(status_code=404, detail="Файл документа не найден")
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении документа: {str(e)}")


@router.get("/GetDocumentsByProductId/{product_id}", response_model=List[Documentation])
async def get_documents_by_product_id(product_id: int):
    """
    Получение списка документов для продукта
    
    Parameters:
    - **product_id**: Идентификатор продукта
    
    Returns:
    - Список документов с метаданными
    """
    try:
        with get_db_cursor() as cursor:
            # Получаем инфо о соединителе
            cursor.execute(
                """
                SELECT cs.series_name, ct.type_id 
                FROM connector_series cs
                JOIN connector_types ct ON substring(cs.series_name, 1, position(' ' in cs.series_name || ' ')-1) = ct.code
                WHERE cs.series_id = %s
                """,
                (product_id,)
            )
            
            product = cursor.fetchone()
            if not product:
                raise HTTPException(status_code=404, detail="Продукт не найден")
            
            # Получаем документы по соединителю или по его типу
            cursor.execute(
                """
                SELECT 
                    doc_id,
                    doc_name,
                    doc_path,
                    description,
                    upload_date
                FROM 
                    connector_documentation
                WHERE 
                    connector_id = %s OR type_id = %s
                ORDER BY
                    doc_name
                """,
                (product_id, product["type_id"])
            )
            
            documents = cursor.fetchall()
            
            # Если документов нет в БД, вернем хотя бы заглушку
            if not documents:
                return [
                    {
                        "doc_name": "Техническая спецификация",
                        "doc_path": f"/api/Documents/GetDocumentById/1?product_id={product_id}",
                        "description": f"Спецификация для {product['series_name']}",
                        "upload_date": "2024-01-01"
                    },
                    {
                        "doc_name": "ГОСТ В 23476.8-86",
                        "doc_path": f"/api/Documents/GetDocumentById/2?product_id={product_id}",
                        "description": "Государственный стандарт",
                        "upload_date": "2024-01-01"
                    }
                ]
                
            # Преобразуем пути к API
            result = []
            for doc in documents:
                # Заменяем или добавляем doc_path на URL API
                api_path = f"/api/Documents/GetDocumentById/{doc['doc_id']}"
                result.append({
                    "doc_name": doc["doc_name"],
                    "doc_path": api_path,
                    "description": doc["description"],
                    "upload_date": doc["upload_date"].strftime("%Y-%m-%d") if hasattr(doc["upload_date"], "strftime") else str(doc["upload_date"])
                })
                
            return result
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении списка документов: {str(e)}")


@router.get("/GetAllTechnicalDocuments", response_model=List[Documentation])
async def get_all_technical_documents():
    """
    Получение списка всех технических документов
    
    Returns:
    - Список всех доступных технических документов
    """
    try:
        with get_db_cursor() as cursor:
            cursor.execute(
                """
                SELECT 
                    doc_id,
                    doc_name,
                    doc_path,
                    description,
                    upload_date
                FROM 
                    connector_documentation
                WHERE 
                    connector_id IS NULL
                ORDER BY
                    doc_name
                """
            )
            
            documents = cursor.fetchall()
            
            # Если документов нет в БД, вернем хотя бы заглушку
            if not documents:
                return [
                    {
                        "doc_name": "ГОСТ В 23476.8-86",
                        "doc_path": "/api/Documents/GetDocumentById/1",
                        "description": "Соединители электрические низкочастотные",
                        "upload_date": "2024-01-01"
                    },
                    {
                        "doc_name": "Каталог соединителей 2РМТ, 2РМДТ",
                        "doc_path": "/api/Documents/GetDocumentById/2",
                        "description": "Полный каталог соединителей",
                        "upload_date": "2024-01-01"
                    }
                ]
                
            # Преобразуем пути к API
            result = []
            for doc in documents:
                # Заменяем или добавляем doc_path на URL API
                api_path = f"/api/Documents/GetDocumentById/{doc['doc_id']}"
                result.append({
                    "doc_name": doc["doc_name"],
                    "doc_path": api_path,
                    "description": doc["description"],
                    "upload_date": doc["upload_date"].strftime("%Y-%m-%d") if hasattr(doc["upload_date"], "strftime") else str(doc["upload_date"])
                })
                
            return result
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при получении списка документов: {str(e)}") 