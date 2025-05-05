-- Наполнение таблиц технических характеристик
-- Соединители 2РМТ, 2РМДТ

-- Наполнение таблицы сопротивления контактов данными из документации
INSERT INTO contact_resistance (diameter_id, max_resistance) VALUES
((SELECT diameter_id FROM contact_diameters WHERE diameter = 1.0), 5.0),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 1.5), 2.5),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 2.0), 1.6),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 3.0), 0.8);

-- Наполнение таблицы максимальных токов данными из документации
INSERT INTO contact_max_current (diameter_id, max_current) VALUES
((SELECT diameter_id FROM contact_diameters WHERE diameter = 1.0), 8.0),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 1.5), 15.0),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 2.0), 18.0),
((SELECT diameter_id FROM contact_diameters WHERE diameter = 3.0), 32.0);

-- Наполнение таблицы сопротивления изоляции и максимального напряжения
INSERT INTO connector_technical_specs (spec_name, spec_value, description) VALUES
('Сопротивление изоляции', 'не менее 5 000 МОм', 'Сопротивление изоляции'),
('Макс. рабочее напряжение DC/AC', '560 В', 'Максимальное рабочее напряжение постоянного тока или амплитудное значение напряжения переменного тока'),
('Количество сочленений-расчленений', '500', 'Количество сочленений-расчленений'),
('Минимальный срок сохраняемости соединителей', '15 лет', 'Минимальный срок сохраняемости соединителей'),
('Устойчивость к спец. факторам', '', 'Устойчивость к воздействию специальных факторов');

-- Наполнение таблицы минимальной наработки в зависимости от температуры
INSERT INTO connector_lifetime_by_temperature (lifetime_hours, max_temperature) VALUES
(1000, 150),
(3000, 129),
(5000, 120),
(7500, 113),
(10000, 109),
(15000, 102),
(20000, 98),
(25000, 94),
(30000, 92),
(40000, 88),
(50000, 84),
(80000, 78),
(100000, 75),
(130000, 71);

-- Наполнение таблицы температуры перегрева контактов в зависимости от токовой нагрузки
INSERT INTO contact_overheat_by_load (load_percent, overheat_temperature) VALUES
(220, 150),
(200, 130),
(180, 120),
(120, 80),
(110, 65),
(100, 50),
(85, 40),
(75, 30),
(60, 25),
(50, 20); 