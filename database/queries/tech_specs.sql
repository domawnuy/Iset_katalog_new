-- Запрос для получения технических характеристик контактов

SELECT 
    c.contact_diameter,
    c.max_current_amp,
    c.contact_resistance_mohm,
    c.insulation_resistance_mohm,
    c.lifetime_cycles
FROM 
    connector_schema.v_contact_specs c
ORDER BY 
    c.contact_diameter; 