-- Создание таблиц для технических характеристик соединителей 2РМТ, 2РМДТ
-- На основе данных из документации

-- Таблица сопротивления контактов в зависимости от диаметра
CREATE TABLE contact_resistance (
    resistance_id SERIAL PRIMARY KEY,
    diameter_id INTEGER NOT NULL REFERENCES contact_diameters(diameter_id),
    max_resistance DECIMAL(5,2) NOT NULL -- мОм
);
COMMENT ON TABLE contact_resistance IS 'Сопротивление контактов в зависимости от диаметра';
COMMENT ON COLUMN contact_resistance.resistance_id IS 'Уникальный идентификатор';
COMMENT ON COLUMN contact_resistance.diameter_id IS 'Ссылка на диаметр контакта';
COMMENT ON COLUMN contact_resistance.max_resistance IS 'Максимальное сопротивление контакта в мОм';

-- Таблица максимальных токов по диаметрам контактов
CREATE TABLE contact_max_current (
    current_id SERIAL PRIMARY KEY,
    diameter_id INTEGER NOT NULL REFERENCES contact_diameters(diameter_id),
    max_current DECIMAL(5,1) NOT NULL -- А
);
COMMENT ON TABLE contact_max_current IS 'Максимальный ток на одиночный контакт';
COMMENT ON COLUMN contact_max_current.current_id IS 'Уникальный идентификатор';
COMMENT ON COLUMN contact_max_current.diameter_id IS 'Ссылка на диаметр контакта';
COMMENT ON COLUMN contact_max_current.max_current IS 'Максимальный ток в амперах';

-- Таблица минимальной наработки соединителя в зависимости от температуры
CREATE TABLE connector_lifetime_by_temperature (
    lifetime_id SERIAL PRIMARY KEY,
    lifetime_hours INTEGER NOT NULL, -- часы
    max_temperature INTEGER NOT NULL -- °C
);
COMMENT ON TABLE connector_lifetime_by_temperature IS 'Минимальная наработка соединителя в зависимости от максимальной температуры';
COMMENT ON COLUMN connector_lifetime_by_temperature.lifetime_id IS 'Уникальный идентификатор записи';
COMMENT ON COLUMN connector_lifetime_by_temperature.lifetime_hours IS 'Минимальная наработка соединителя в часах';
COMMENT ON COLUMN connector_lifetime_by_temperature.max_temperature IS 'Максимальная температура соединителя в °C';

-- Таблица температуры перегрева контактов в зависимости от токовой нагрузки
CREATE TABLE contact_overheat_by_load (
    overheat_id SERIAL PRIMARY KEY,
    load_percent INTEGER NOT NULL, -- % от максимально допустимой по ТУ
    overheat_temperature INTEGER NOT NULL -- °C
);
COMMENT ON TABLE contact_overheat_by_load IS 'Температура перегрева контактов в зависимости от токовой нагрузки';
COMMENT ON COLUMN contact_overheat_by_load.overheat_id IS 'Уникальный идентификатор записи';
COMMENT ON COLUMN contact_overheat_by_load.load_percent IS 'Токовая нагрузка в процентах от максимально допустимой по ТУ';
COMMENT ON COLUMN contact_overheat_by_load.overheat_temperature IS 'Температура перегрева контактов в °C';

-- Таблица общих технических характеристик соединителей
CREATE TABLE connector_technical_specs (
    spec_id SERIAL PRIMARY KEY,
    spec_name VARCHAR(100) NOT NULL,
    spec_value VARCHAR(100) NOT NULL,
    description TEXT
);
COMMENT ON TABLE connector_technical_specs IS 'Общие технические характеристики соединителей';
COMMENT ON COLUMN connector_technical_specs.spec_id IS 'Уникальный идентификатор характеристики';
COMMENT ON COLUMN connector_technical_specs.spec_name IS 'Наименование характеристики';
COMMENT ON COLUMN connector_technical_specs.spec_value IS 'Значение характеристики';
COMMENT ON COLUMN connector_technical_specs.description IS 'Дополнительное описание';

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
('Максимальное рабочее напряжение постоянного тока или амплитудное значение напряжения переменного тока', '560 В', 'Максимальное рабочее напряжение постоянного тока или амплитудное значение напряжения переменного тока'),
('Количество сочленений-расчленений', '500', 'Количество сочленений-расчленений'),
('Минимальный срок сохраняемости соединителей', '15 лет', 'Минимальный срок сохраняемости соединителей'),
('Соединители устойчивы к воздействию специальных факторов', '', 'Устойчивость к воздействию специальных факторов');

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

-- Создание представления для удобного доступа к техническим характеристикам по диаметрам контактов
CREATE OR REPLACE VIEW v_contact_technical_specs AS
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

-- Создание представления для общей информации о наработке и тепловых режимах
CREATE OR REPLACE VIEW v_thermal_lifetime_specs AS
SELECT 
    clt.lifetime_hours,
    clt.max_temperature,
    'Наработка' AS spec_type
FROM 
    connector_lifetime_by_temperature clt
UNION ALL
SELECT 
    col.load_percent AS lifetime_hours,
    col.overheat_temperature AS max_temperature,
    'Перегрев' AS spec_type
FROM 
    contact_overheat_by_load col
ORDER BY
    spec_type, max_temperature DESC; 