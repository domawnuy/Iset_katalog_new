-- Представления для работы с базой данных соединителей 2РМТ, 2РМДТ

-- Представление для полной информации о соединителях
CREATE OR REPLACE VIEW v_connectors_full AS
SELECT 
    c.connector_id,
    c.full_code,
    c.gost,
    ct.type_name,
    bs.size_value,
    bt.name AS body_type,
    nt.name AS nozzle_type,
    nut.description AS nut_type,
    cq.quantity AS contact_quantity,
    cp.name AS connector_part,
    cc.description AS contact_combination,
    cco.material AS contact_coating,
    hr.temperature AS heat_resistance,
    cd.description AS climate_design,
    con.name AS connection_type,
    c.created_at,
    c.updated_at
FROM 
    connectors c
    JOIN connector_types ct ON c.type_id = ct.type_id
    JOIN body_sizes bs ON c.size_id = bs.size_id
    JOIN body_types bt ON c.body_type_id = bt.body_type_id
    LEFT JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id
    LEFT JOIN nut_types nut ON c.nut_type_id = nut.nut_type_id
    JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
    JOIN connector_parts cp ON c.part_id = cp.part_id
    JOIN contact_combinations cc ON c.combination_id = cc.combination_id
    JOIN contact_coatings cco ON c.coating_id = cco.coating_id
    JOIN heat_resistance hr ON c.resistance_id = hr.resistance_id
    JOIN climate_designs cd ON c.climate_id = cd.climate_id
    JOIN connection_types con ON c.connection_type_id = con.connection_type_id;
COMMENT ON VIEW v_connectors_full IS 'Полная информация о соединителях';

-- Представление для технических характеристик контактов
CREATE OR REPLACE VIEW v_contact_specs AS
SELECT 
    cd.diameter,
    cr.max_resistance,
    cmc.max_current
FROM 
    contact_diameters cd
    JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
ORDER BY
    cd.diameter;
COMMENT ON VIEW v_contact_specs IS 'Технические характеристики контактов';

-- Представление для информации о тепловых режимах и сроках службы
CREATE OR REPLACE VIEW v_thermal_specs AS
SELECT 
    lifetime_hours AS hours,
    max_temperature,
    'Наработка' AS spec_type
FROM 
    connector_lifetime_by_temperature
UNION ALL
SELECT 
    load_percent AS hours,
    overheat_temperature AS max_temperature,
    'Перегрев' AS spec_type
FROM 
    contact_overheat_by_load
ORDER BY
    spec_type, hours;
COMMENT ON VIEW v_thermal_specs IS 'Тепловые режимы и сроки службы';

-- Представление для общих технических характеристик
CREATE OR REPLACE VIEW v_connector_specifications AS
SELECT 
    spec_id AS id,
    spec_name AS name,
    spec_value AS value,
    description
FROM 
    connector_technical_specs
ORDER BY 
    spec_id;
COMMENT ON VIEW v_connector_specifications IS 'Общие технические характеристики';

-- Представление для информации о сочетаниях контактов
CREATE OR REPLACE VIEW v_contact_combinations AS
SELECT 
    cc.combination_id,
    cc.code,
    cc.description,
    cd.diameter,
    cdm.position
FROM 
    contact_combinations cc
    JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
    JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
ORDER BY 
    cc.code, cdm.position;
COMMENT ON VIEW v_contact_combinations IS 'Информация о сочетаниях контактов';

-- Представление для поиска соединителей с заданными параметрами
CREATE OR REPLACE VIEW v_connectors_search AS
SELECT 
    c.connector_id,
    c.full_code,
    ct.type_name,
    bs.size_value,
    bt.name AS body_type,
    nt.name AS nozzle_type,
    cq.quantity AS contact_quantity,
    cp.name AS connector_part,
    cco.material AS contact_coating
FROM 
    connectors c
    JOIN connector_types ct ON c.type_id = ct.type_id
    JOIN body_sizes bs ON c.size_id = bs.size_id
    JOIN body_types bt ON c.body_type_id = bt.body_type_id
    LEFT JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id
    JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
    JOIN connector_parts cp ON c.part_id = cp.part_id
    JOIN contact_coatings cco ON c.coating_id = cco.coating_id;
COMMENT ON VIEW v_connectors_search IS 'Представление для поиска соединителей'; 