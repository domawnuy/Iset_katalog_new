-- Запрос для поиска соединителей по техническим характеристикам
-- Использование: передать соответствующие параметры для фильтрации

SELECT 
    full_code, 
    size_value, 
    body_type, 
    contact_quantity, 
    connector_part
FROM 
    connector_schema.v_connectors_search
WHERE 
    type_name = COALESCE(:type_name, type_name)
    AND contact_coating = COALESCE(:contact_coating, contact_coating)
    AND COALESCE(size_value >= :min_size, TRUE)
    AND COALESCE(size_value <= :max_size, TRUE)
    AND COALESCE(contact_quantity >= :min_contacts, TRUE)
    AND COALESCE(contact_quantity <= :max_contacts, TRUE)
ORDER BY 
    size_value, 
    contact_quantity; 