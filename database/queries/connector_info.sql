-- Запрос для получения полной информации о соединителе по его коду
-- Использование: передать в параметре connector_code код соединителя (например, '2РМТ18Б4Г1В1В')

SELECT * 
FROM connector_schema.v_connectors_full 
WHERE full_code = :connector_code; 