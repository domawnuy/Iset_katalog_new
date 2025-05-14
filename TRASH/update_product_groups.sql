-- Обновление групп продуктов с корректной кодировкой
-- Устанавливаем кодировку клиента UTF-8
SET client_encoding TO 'UTF8';

UPDATE product_groups SET 
    name = E'2РМТ, 2РМДТ',
    description = E'Соединители типа 2РМТ и 2РМДТ'
WHERE id = 1;

UPDATE product_groups SET 
    name = E'СНЦ23',
    description = E'Соединители типа СНЦ23'
WHERE id = 2; 