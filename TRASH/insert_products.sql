-- Вставка соединителей в таблицу продуктов
-- Установка кодировки клиента UTF-8
SET client_encoding TO 'UTF8';

INSERT INTO products (name, description, group_id, connector_id)
SELECT 
    c.full_code, 
    COALESCE(ct.description, E'Соединитель') || ' ' || c.full_code,
    1, -- ID первой группы (2РМТ, 2РМДТ)
    c.connector_id
FROM 
    connectors c
    JOIN connector_types ct ON c.type_id = ct.type_id
WHERE 
    ct.type_name IN ('2РМТ', '2РМДТ'); 