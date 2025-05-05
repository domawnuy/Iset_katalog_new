-- Примеры запросов для работы с базой данных соединителей 2РМТ, 2РМДТ

-- 1. Получение полной информации о конкретном соединителе по его коду
SELECT * FROM v_connectors_full WHERE full_code = '2РМТ18Б4Г1В1В';

-- 2. Поиск всех соединителей определенного типа
SELECT full_code, size_value, body_type, contact_quantity, connector_part 
FROM v_connectors_search 
WHERE type_name = '2РМТ'
ORDER BY size_value, contact_quantity;

-- 3. Поиск соединителей с определенным количеством контактов и размером корпуса
SELECT full_code, type_name, body_type, connector_part, contact_coating
FROM v_connectors_search
WHERE contact_quantity = 4 AND size_value = '18'
ORDER BY type_name, body_type;

-- 4. Получение соединителей определенного типа с определенным покрытием контактов
SELECT full_code, size_value, body_type, contact_quantity, connector_part
FROM v_connectors_search
WHERE type_name = '2РМДТ' AND contact_coating = 'золото'
ORDER BY size_value, contact_quantity;

-- 5. Поиск кабельных соединителей с угловым патрубком
SELECT full_code, type_name, size_value, contact_quantity, connector_part
FROM v_connectors_search
WHERE body_type = 'кабельный' AND nozzle_type = 'угловой'
ORDER BY type_name, size_value, contact_quantity;

-- 6. Получение статистики по количеству соединителей каждого типа
SELECT type_name, COUNT(*) AS connector_count
FROM v_connectors_search
GROUP BY type_name
ORDER BY connector_count DESC;

-- 7. Получение статистики по количеству соединителей с разными видами покрытия контактов
SELECT contact_coating, COUNT(*) AS connector_count
FROM v_connectors_search
GROUP BY contact_coating
ORDER BY connector_count DESC;

-- 8. Получение данных о максимальном сопротивлении и токе контактов по диаметрам
SELECT * FROM v_contact_specs;

-- 9. Получение данных о наработке соединителей при разных температурах
SELECT * FROM v_thermal_specs WHERE spec_type = 'Наработка' ORDER BY max_temperature;

-- 10. Получение данных о температуре перегрева контактов при разных нагрузках
SELECT * FROM v_thermal_specs WHERE spec_type = 'Перегрев' ORDER BY hours DESC;

-- 11. Получение общих технических характеристик соединителей
SELECT * FROM v_connector_specifications;

-- 12. Использование функции для получения информации о соединителе по коду
SELECT * FROM get_connector_by_code('2РМТ18Б7Ш1В1В');

-- 13. Использование функции для поиска совместимых соединителей
SELECT * FROM find_compatible_connectors('2РМТ18Б4Ш1В1В');

-- 14. Использование функции для расчета срока службы при определенной температуре
SELECT * FROM calculate_lifetime_at_temperature(100);

-- 15. Получение информации о сочетаниях контактов
SELECT * FROM v_contact_combinations ORDER BY code, position;

-- 16. Пример комплексного запроса: получение полных данных о контактах соединителя
WITH connector_contacts AS (
    SELECT c.full_code, c.combination_id
    FROM connectors c
    WHERE c.full_code = '2РМТ18Б7Ш1В1В'
)
SELECT 
    cc.full_code AS "Код соединителя",
    cd.diameter AS "Диаметр контакта (мм)",
    cr.max_resistance AS "Сопротивление (мОм)",
    cmc.max_current AS "Максимальный ток (А)",
    ROUND(cmc.max_current * 0.7, 1) AS "Рекомендуемый ток (А)"
FROM 
    connector_contacts cc
    JOIN contact_combinations comb ON cc.combination_id = comb.combination_id
    JOIN combination_diameter_map cdm ON comb.combination_id = cdm.combination_id
    JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
    JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
ORDER BY 
    cd.diameter;

-- 17. Пример использования функции для разбора кода соединителя
SELECT * FROM parse_connector_code('2РМТ18Б7Ш1В1В');

-- 18. Пример генерации кода соединителя
SELECT generate_connector_code('2РМТ', '18', 'Б', NULL, 7, 'Ш', '1', 'В', '1', 'В');

-- 19. Поиск соединителей с возможностью установки проходного кожуха определенного размера
SELECT 
    c.full_code, 
    ct.type_name, 
    bs.size_value, 
    cq.quantity, 
    cp.name AS connector_part, 
    ss.diameter AS shell_diameter
FROM 
    connectors c
    JOIN connector_types ct ON c.type_id = ct.type_id
    JOIN body_sizes bs ON c.size_id = bs.size_id
    JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
    JOIN connector_parts cp ON c.part_id = cp.part_id
    JOIN connector_design_options cdo ON c.connector_id = cdo.connector_id
    JOIN shell_sizes ss ON cdo.shell_size_id = ss.shell_size_id
WHERE 
    ss.diameter = 20.0
ORDER BY 
    ct.type_name, bs.size_value;

-- 20. Расчет максимальной температуры контактов при разных токовых нагрузках для соединителя
WITH connector_contacts AS (
    SELECT 
        c.full_code,
        cd.diameter,
        cmc.max_current
    FROM 
        connectors c
        JOIN contact_combinations cc ON c.combination_id = cc.combination_id
        JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
        JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
        JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
    WHERE 
        c.full_code = '2РМТ18Б7Ш1В1В'
)
SELECT 
    cc.full_code AS "Код соединителя",
    cc.diameter AS "Диаметр контакта, мм",
    cc.max_current AS "Максимальный ток, А",
    col.load_percent AS "Токовая нагрузка, %",
    ROUND(cc.max_current * col.load_percent / 100, 1) AS "Расчетный ток, А",
    col.overheat_temperature AS "Температура перегрева, °C"
FROM 
    connector_contacts cc
    CROSS JOIN contact_overheat_by_load col
WHERE 
    col.load_percent IN (50, 75, 100, 110, 120)
ORDER BY 
    cc.diameter, col.load_percent; 