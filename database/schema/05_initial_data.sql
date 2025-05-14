-- Заполнение таблицы типов соединителей
INSERT INTO connector_types (type_id, type_name, code, description) 
VALUES 
    (1, '2РМТ', '2РМТ', 'Соединители электрические цилиндрические типа 2РМТ'),
    (2, '2РМДТ', '2РМДТ', 'Соединители электрические цилиндрические типа 2РМДТ')
ON CONFLICT (type_id) DO NOTHING;

-- Заполнение таблицы размеров соединителей
INSERT INTO connector_sizes (size_id, size_code, description) 
VALUES 
    (7, 14, 'Размер 14'),
    (8, 18, 'Размер 18'),
    (9, 22, 'Размер 22')
ON CONFLICT (size_id) DO NOTHING;

-- Заполнение таблицы серий соединителей
INSERT INTO connector_series (series_id, series_name, description, type_id) 
VALUES 
    (5, '2РМТ', 'Соединители электрические цилиндрические низкочастотные типа 2РМТ', 1),
    (6, '2РМДТ', 'Соединители электрические цилиндрические низкочастотные типа 2РМДТ', 2)
ON CONFLICT (series_id) DO NOTHING;

-- Заполнение таблицы связи серий с размерами
INSERT INTO series_sizes (id, series_id, size_id) 
VALUES 
    (1, 5, 7),
    (2, 5, 8),
    (3, 5, 9),
    (4, 6, 7),
    (5, 6, 8),
    (6, 6, 9)
ON CONFLICT (id) DO NOTHING;

-- Заполнение таблицы электромеханических параметров
INSERT INTO electromechanical_parameters (param_id, series_name, size_code, contact_diameter, contact_quantity, contact_combination_code, max_current, max_voltage, max_working_voltage) 
VALUES 
    (1, '2РМТ', 14, 1.0, 4, 1, 27.0, 560, 560),
    (2, '2РМДТ', 18, 1.5, 4, 5, 50.0, 560, 560),
    (3, '2РМТ', 18, 1.0, 7, 1, 40.0, 560, 560),
    (4, '2РМТ', 22, 2.0, 2, 3, 80.0, 560, 560),
    (5, '2РМТ', 22, 1.0, 10, 1, 58.0, 560, 560)
ON CONFLICT (param_id) DO NOTHING; 