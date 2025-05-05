-- Наполнение таблицы соединителей
-- Соединители 2РМТ, 2РМДТ

-- Создание нескольких тестовых соединителей разных типов
INSERT INTO connectors (
    gost, type_id, size_id, body_type_id, nozzle_type_id, nut_type_id,
    quantity_id, part_id, combination_id, coating_id, resistance_id,
    special_design_id, climate_id, connection_type_id, full_code
) VALUES
-- Соединитель 2РМТ, блочный, с 4 контактами, вилка
(
    'ГЕ0.364.126ТУ', 
    (SELECT type_id FROM connector_types WHERE type_name = '2РМТ'),
    (SELECT size_id FROM body_sizes WHERE size_value = '18'),
    (SELECT body_type_id FROM body_types WHERE code = 'Б'),
    NULL,
    NULL,
    (SELECT quantity_id FROM contact_quantities WHERE quantity = 4),
    (SELECT part_id FROM connector_parts WHERE code = 'Ш'),
    (SELECT combination_id FROM contact_combinations WHERE code = '1'),
    (SELECT coating_id FROM contact_coatings WHERE code = 'В'),
    (SELECT resistance_id FROM heat_resistance WHERE code = '1'),
    NULL,
    (SELECT climate_id FROM climate_designs WHERE code = 'В'),
    (SELECT connection_type_id FROM connection_types WHERE name = 'резьбовое'),
    '2РМТ18Б4Ш1В1В'
),
-- Соединитель 2РМТ, блочный, с 4 контактами, розетка
(
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
),
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

-- Добавление опций дизайна для соединителей
INSERT INTO connector_design_options (connector_id, shell_size_id, option_name, option_value, description)
VALUES
(
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Ш1В1В'),
    (SELECT shell_size_id FROM shell_sizes WHERE diameter = 20.0),
    'Проходной кожух',
    'Совместим',
    'Соединитель совместим с проходным кожухом 20.0 мм'
),
(
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Г1В1В'),
    (SELECT shell_size_id FROM shell_sizes WHERE diameter = 20.0),
    'Проходной кожух',
    'Совместим',
    'Соединитель совместим с проходным кожухом 20.0 мм'
),
(
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б7Ш1В1В'),
    (SELECT shell_size_id FROM shell_sizes WHERE diameter = 24.0),
    'Проходной кожух',
    'Совместим',
    'Соединитель совместим с проходным кожухом 24.0 мм'
);

-- Добавление совместимых соединителей
INSERT INTO compatible_connectors (connector_id, compatible_connector_id, description)
VALUES
(
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Ш1В1В'),
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Г1В1В'),
    'Вилка и розетка совместимы'
),
(
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Г1В1В'),
    (SELECT connector_id FROM connectors WHERE full_code = '2РМТ18Б4Ш1В1В'),
    'Розетка и вилка совместимы'
);

-- Добавление записей о документации
INSERT INTO connector_documentation (type_id, doc_name, doc_path, description)
VALUES
(
    (SELECT type_id FROM connector_types WHERE type_name = '2РМТ'),
    'Техническая документация 2РМТ',
    '/pdf/2РМТ_ТУ.pdf',
    'Техническая документация на соединители 2РМТ'
),
(
    (SELECT type_id FROM connector_types WHERE type_name = '2РМДТ'),
    'Техническая документация 2РМДТ',
    '/pdf/2РМДТ_ТУ.pdf',
    'Техническая документация на соединители 2РМДТ'
); 