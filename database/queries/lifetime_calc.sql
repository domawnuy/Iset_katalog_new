-- Запрос для расчета срока службы соединителей при заданной температуре
-- Использование: передать в параметре temperature значение температуры в градусах Цельсия

SELECT * 
FROM connector_schema.calculate_lifetime_at_temperature(:temperature); 