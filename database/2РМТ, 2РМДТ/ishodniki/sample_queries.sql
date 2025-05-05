-- Примеры типовых SQL запросов для работы с базой данных соединителей

-- 1. Получение полной информации о конкретном соединителе по его коду
SELECT c.full_code, ct.type_name, bs.size_value, bt.name AS body_type, 
       nt.name AS nozzle_type, cq.quantity, cp.name AS connector_part,
       cc.description AS contact_combination, cco.material AS contact_coating,
       hr.temperature, cd.description AS climate_design, con.name AS connection_type
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN body_types bt ON c.body_type_id = bt.body_type_id
LEFT JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
JOIN contact_combinations cc ON c.combination_id = cc.combination_id
JOIN contact_coatings cco ON c.coating_id = cco.coating_id
JOIN heat_resistance hr ON c.resistance_id = hr.resistance_id
JOIN climate_designs cd ON c.climate_id = cd.climate_id
JOIN connection_types con ON c.connection_type_id = con.connection_type_id
WHERE c.full_code = '2РМТ18Б4Г1В1В';

-- 2. Поиск всех соединителей определенного типа
SELECT c.full_code, bs.size_value, bt.name AS body_type, 
       cq.quantity, cp.name AS connector_part
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN body_types bt ON c.body_type_id = bt.body_type_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
WHERE ct.type_name = '2РМТ'
ORDER BY bs.size_value, cq.quantity;

-- 3. Поиск соединителей с определенным количеством контактов и размером корпуса
SELECT c.full_code, ct.type_name, bt.name AS body_type, 
       cp.name AS connector_part, cc.description AS contact_combination, 
       cco.material AS contact_coating
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN body_types bt ON c.body_type_id = bt.body_type_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
JOIN contact_combinations cc ON c.combination_id = cc.combination_id
JOIN contact_coatings cco ON c.coating_id = cco.coating_id
WHERE cq.quantity = 4 AND bs.size_value = '18'
ORDER BY ct.type_name, bt.name;

-- 4. Получение соединителей определенного типа с определенным покрытием контактов
SELECT c.full_code, bs.size_value, bt.name AS body_type, 
       cq.quantity, cp.name AS connector_part, cc.description AS contact_combination
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN body_types bt ON c.body_type_id = bt.body_type_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
JOIN contact_combinations cc ON c.combination_id = cc.combination_id
JOIN contact_coatings cco ON c.coating_id = cco.coating_id
WHERE ct.type_name = '2РМДТ' AND cco.material = 'золото'
ORDER BY bs.size_value, cq.quantity;

-- 5. Поиск кабельных соединителей с угловым патрубком
SELECT c.full_code, ct.type_name, bs.size_value, 
       cq.quantity, cp.name AS connector_part, cc.description AS contact_combination,
       nut.description AS nut_type
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN body_types bt ON c.body_type_id = bt.body_type_id
JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id
LEFT JOIN nut_types nut ON c.nut_type_id = nut.nut_type_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
JOIN contact_combinations cc ON c.combination_id = cc.combination_id
WHERE bt.name = 'кабельный' AND nt.name = 'угловой'
ORDER BY ct.type_name, bs.size_value, cq.quantity;

-- 6. Получение статистики по количеству соединителей каждого типа
SELECT ct.type_name, COUNT(*) AS connector_count
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
GROUP BY ct.type_name
ORDER BY connector_count DESC;

-- 7. Получение статистики по количеству соединителей с разными видами покрытия контактов
SELECT cco.material, COUNT(*) AS connector_count
FROM connectors c
JOIN contact_coatings cco ON c.coating_id = cco.coating_id
GROUP BY cco.material
ORDER BY connector_count DESC;

-- 8. Вставка нового соединителя
INSERT INTO connectors (
    gost, type_id, size_id, body_type_id, nozzle_type_id, nut_type_id,
    quantity_id, part_id, combination_id, coating_id, resistance_id,
    special_design_id, climate_id, connection_type_id, full_code
)
VALUES (
    'ГЕ0.364.126ТУ', 
    (SELECT type_id FROM connector_types WHERE type_name = '2РМТ'),
    (SELECT size_id FROM body_sizes WHERE size_value = '18'),
    (SELECT body_type_id FROM body_types WHERE code = 'Б'),
    NULL,
    NULL,
    (SELECT quantity_id FROM contact_quantities WHERE quantity = 4),
    (SELECT part_id FROM connector_parts WHERE code = 'Г'),
    (SELECT combination_id FROM contact_combinations WHERE code = '1'),
    (SELECT coating_id FROM contact_coatings WHERE code = 'В'),
    (SELECT resistance_id FROM heat_resistance WHERE code = '1'),
    NULL,
    (SELECT climate_id FROM climate_designs WHERE code = 'В'),
    (SELECT connection_type_id FROM connection_types WHERE name = 'резьбовое'),
    '2РМТ18Б4Г1В1В'
);

-- 9. Обновление информации о соединителе
UPDATE connectors
SET coating_id = (SELECT coating_id FROM contact_coatings WHERE code = 'А')
WHERE full_code = '2РМТ18Б4Г1В1В';

-- 10. Поиск соединителей с возможностью установки проходного кожуха определенного размера
SELECT c.full_code, ct.type_name, bs.size_value, cq.quantity, 
       cp.name AS connector_part, ss.diameter AS shell_diameter
FROM connectors c
JOIN connector_types ct ON c.type_id = ct.type_id
JOIN body_sizes bs ON c.size_id = bs.size_id
JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
JOIN connector_parts cp ON c.part_id = cp.part_id
JOIN connector_design_options cdo ON c.connector_id = cdo.connector_id
JOIN shell_sizes ss ON cdo.shell_size_id = ss.shell_size_id
WHERE ss.diameter = 20.0
ORDER BY ct.type_name, bs.size_value;

-- 11. Создание индексов для оптимизации запросов
-- Создаем индекс для поиска по полному коду соединителя (часто используемый критерий)
CREATE INDEX idx_connectors_full_code ON connectors(full_code);

-- Создаем индекс для поиска по типу соединителя
CREATE INDEX idx_connectors_type_id ON connectors(type_id);

-- Создаем композитный индекс для часто используемого сочетания параметров
CREATE INDEX idx_connectors_size_quantity ON connectors(size_id, quantity_id);

-- Создаем индекс для поиска по виду корпуса
CREATE INDEX idx_connectors_body_type ON connectors(body_type_id);

-- 12. Создание нескольких тестовых соединителей разных типов
INSERT INTO connectors (
    gost, type_id, size_id, body_type_id, nozzle_type_id, nut_type_id,
    quantity_id, part_id, combination_id, coating_id, resistance_id,
    special_design_id, climate_id, connection_type_id, full_code
) VALUES
-- Соединитель 2РМТ, блочный, с 7 контактами, вилка
(
    'ГЕ0.364.126ТУ', 
    (SELECT type_id FROM connector_types WHERE type_name = '2РМТ'),
    (SELECT size_id FROM body_sizes WHERE size_value = '18'),
    (SELECT body_type_id FROM body_types WHERE code = 'Б'),
    NULL,
    NULL,
    (SELECT quantity_id FROM contact_quantities WHERE quantity = 7),
    (SELECT part_id FROM connector_parts WHERE code = 'Ш'),
    (SELECT combination_id FROM contact_combinations WHERE code = '1'),
    (SELECT coating_id FROM contact_coatings WHERE code = 'В'),
    (SELECT resistance_id FROM heat_resistance WHERE code = '1'),
    NULL,
    (SELECT climate_id FROM climate_designs WHERE code = 'В'),
    (SELECT connection_type_id FROM connection_types WHERE name = 'резьбовое'),
    '2РМТ18Б7Ш1В1В'
),
-- Соединитель 2РМДТ, кабельный с прямым патрубком, с 10 контактами, розетка
(
    'ГЕ0.364.126ТУ', 
    (SELECT type_id FROM connector_types WHERE type_name = '2РМДТ'),
    (SELECT size_id FROM body_sizes WHERE size_value = '22'),
    (SELECT body_type_id FROM body_types WHERE code = 'К'),
    (SELECT nozzle_type_id FROM nozzle_types WHERE code = 'П'),
    (SELECT nut_type_id FROM nut_types WHERE code = 'Э'),
    (SELECT quantity_id FROM contact_quantities WHERE quantity = 10),
    (SELECT part_id FROM connector_parts WHERE code = 'Г'),
    (SELECT combination_id FROM contact_combinations WHERE code = '5'),
    (SELECT coating_id FROM contact_coatings WHERE code = 'А'),
    (SELECT resistance_id FROM heat_resistance WHERE code = '1'),
    NULL,
    (SELECT climate_id FROM climate_designs WHERE code = 'В'),
    (SELECT connection_type_id FROM connection_types WHERE name = 'резьбовое'),
    '2РМДТ22КП10Г5А1В'
),
-- Соединитель 2РМТ, кабельный с угловым патрубком, с 4 контактами, вилка
(
    'ГЕ0.364.126ТУ', 
    (SELECT type_id FROM connector_types WHERE type_name = '2РМТ'),
    (SELECT size_id FROM body_sizes WHERE size_value = '14'),
    (SELECT body_type_id FROM body_types WHERE code = 'К'),
    (SELECT nozzle_type_id FROM nozzle_types WHERE code = 'У'),
    (SELECT nut_type_id FROM nut_types WHERE code = 'Н'),
    (SELECT quantity_id FROM contact_quantities WHERE quantity = 4),
    (SELECT part_id FROM connector_parts WHERE code = 'Ш'),
    (SELECT combination_id FROM contact_combinations WHERE code = '3'),
    (SELECT coating_id FROM contact_coatings WHERE code = 'А'),
    (SELECT resistance_id FROM heat_resistance WHERE code = '1'),
    NULL,
    (SELECT climate_id FROM climate_designs WHERE code = 'В'),
    (SELECT connection_type_id FROM connection_types WHERE name = 'резьбовое'),
    '2РМТ14КУ4Ш3А1В'
);

-- 13. Запрос для получения всех возможных сочетаний диаметров контактов для выбранного соединителя
SELECT c.full_code, cd.diameter, cd.description
FROM connectors c
JOIN contact_combinations cc ON c.combination_id = cc.combination_id
JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
WHERE c.full_code = '2РМТ18Б7Ш1В1В'
ORDER BY cd.diameter; 