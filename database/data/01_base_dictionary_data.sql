-- Наполнение базовых справочников
-- Соединители 2РМТ, 2РМДТ

-- Типы соединителей
INSERT INTO connector_types (type_name, code, description) VALUES 
('2РМТ', '2РМТ', 'Соединитель типа 2РМТ'),
('2РМДТ', '2РМДТ', 'Соединитель типа 2РМДТ');

-- Размеры корпуса
INSERT INTO body_sizes (size_value, description) VALUES 
('14', 'Размер корпуса 14'),
('18', 'Размер корпуса 18'),
('22', 'Размер корпуса 22'),
('30', 'Размер корпуса 30'),
('32', 'Размер корпуса 32'),
('42', 'Размер корпуса 42');

-- Типы корпуса
INSERT INTO body_types (name, code, description) VALUES 
('блочный', 'Б', 'Блочный корпус (приборный) без левой резьбы'),
('кабельный', 'К', 'Кабельный корпус (на кабель)');

-- Типы патрубка
INSERT INTO nozzle_types (name, code, description) VALUES 
('прямой', 'П', 'Прямой патрубок'),
('угловой', 'У', 'Угловой патрубок'),
('пластмассовый', 'Пс', 'Пластмассовый патрубок');

-- Типы гайки
INSERT INTO nut_types (description, code) VALUES 
('без гайки', 'Н'),
('с гайкой', 'Э');

-- Количество контактов
INSERT INTO contact_quantities (quantity, description) VALUES 
(1, '1 контакт'),
(2, '2 контакта'),
(3, '3 контакта'),
(4, '4 контакта'),
(7, '7 контактов'),
(10, '10 контактов'),
(19, '19 контактов'),
(27, '27 контактов'),
(30, '30 контактов'),
(37, '37 контактов'),
(55, '55 контактов');

-- Части соединителя
INSERT INTO connector_parts (name, code, description) VALUES 
('вилка', 'Ш', 'Вилка (штепсель)'),
('розетка', 'Г', 'Розетка (гнездо)');

-- Диаметры контактов
INSERT INTO contact_diameters (diameter, description) VALUES 
(1.0, 'Диаметр контакта 1.0 мм'),
(1.5, 'Диаметр контакта 1.5 мм'),
(2.0, 'Диаметр контакта 2.0 мм'),
(3.0, 'Диаметр контакта 3.0 мм');

-- Сочетания контактов
INSERT INTO contact_combinations (code, description) VALUES 
('1', 'Стандартное сочетание 1'),
('2', 'Стандартное сочетание 2'),
('3', 'Стандартное сочетание 3'),
('4', 'Стандартное сочетание 4'),
('5', 'Стандартное сочетание 5');

-- Связь сочетаний с диаметрами
INSERT INTO combination_diameter_map (combination_id, diameter_id, position) VALUES 
((SELECT combination_id FROM contact_combinations WHERE code = '1'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 1.5), 1),
((SELECT combination_id FROM contact_combinations WHERE code = '2'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 2.0), 1),
((SELECT combination_id FROM contact_combinations WHERE code = '3'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 1.0), 1),
((SELECT combination_id FROM contact_combinations WHERE code = '3'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 1.5), 2),
((SELECT combination_id FROM contact_combinations WHERE code = '4'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 1.0), 1),
((SELECT combination_id FROM contact_combinations WHERE code = '4'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 3.0), 2),
((SELECT combination_id FROM contact_combinations WHERE code = '5'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 1.0), 1),
((SELECT combination_id FROM contact_combinations WHERE code = '5'), (SELECT diameter_id FROM contact_diameters WHERE diameter = 2.0), 2);

-- Покрытия контактов
INSERT INTO contact_coatings (material, code, description) VALUES 
('золото', 'А', 'Покрытие контактов золотом'),
('серебро', 'В', 'Покрытие контактов серебром');

-- Теплостойкость
INSERT INTO heat_resistance (temperature, code, description) VALUES 
(100, '1', 'Теплостойкость до 100°C');

-- Климатическое исполнение
INSERT INTO climate_designs (code, description) VALUES 
('В', 'Всеклиматическое исполнение');

-- Типы соединения
INSERT INTO connection_types (name, description) VALUES 
('резьбовое', 'Резьбовое соединение'),
('байонетное', 'Байонетное соединение');

-- Размеры проходных кожухов
INSERT INTO shell_sizes (diameter, description) VALUES 
(20.0, 'Проходной кожух 20 мм'),
(24.0, 'Проходной кожух 24 мм'),
(32.0, 'Проходной кожух 32 мм'); 