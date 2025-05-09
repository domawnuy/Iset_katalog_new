-- Скрипт инициализации базы данных соединителей 2РМТ, 2РМДТ (Unified version)
-- Версия: 1.2
-- Дата: 2025-05-09

-- Убедимся, что скрипт выполняется в транзакции
BEGIN;

-- Создание схемы
CREATE SCHEMA IF NOT EXISTS connector_schema;
SET search_path TO connector_schema, public;

-- Установка кодировки и локали
SET client_encoding TO 'UTF8';

-- Включаем логи для отслеживания выполнения
SELECT 'Инициализация базы данных соединителей 2РМТ, 2РМДТ...' as log;


-- ======================================
-- Создание базовых таблиц
-- ======================================
SELECT 'Создание базовых таблиц...' as log;

-- Базовые таблицы для хранения основных справочников
-- Соединители 2РМТ, 2РМДТ

-- Таблица типов соединителей (2РМТ, 2РМДТ)
CREATE TABLE connector_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    code VARCHAR(10) NOT NULL UNIQUE
);
COMMENT ON TABLE connector_types IS 'Типы соединителей (2РМТ, 2РМДТ и др.)';

-- Таблица размеров корпуса
CREATE TABLE body_sizes (
    size_id SERIAL PRIMARY KEY,
    size_value VARCHAR(10) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE body_sizes IS 'Размеры корпуса соединителей';

-- Таблица типов корпуса (блочный, кабельный)
CREATE TABLE body_types (
    body_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE body_types IS 'Типы корпуса (блочный, кабельный и др.)';

-- Таблица типов патрубка (прямой, угловой)
CREATE TABLE nozzle_types (
    nozzle_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE nozzle_types IS 'Типы патрубка (прямой, угловой и др.)';

-- Таблица типов гайки (без гайки, с гайкой)
CREATE TABLE nut_types (
    nut_type_id SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE
);
COMMENT ON TABLE nut_types IS 'Типы гайки';

-- Таблица количества контактов
CREATE TABLE contact_quantities (
    quantity_id SERIAL PRIMARY KEY,
    quantity INTEGER NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE contact_quantities IS 'Количество контактов';

-- Таблица частей соединителя (вилка, розетка)
CREATE TABLE connector_parts (
    part_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE connector_parts IS 'Части соединителя (вилка, розетка)';

-- Таблица диаметров контактов
CREATE TABLE contact_diameters (
    diameter_id SERIAL PRIMARY KEY,
    diameter NUMERIC(3,1) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE contact_diameters IS 'Диаметры контактов (1.0, 1.5, 2.0, 3.0 мм)';

-- Таблица сочетаний контактов
CREATE TABLE contact_combinations (
    combination_id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE contact_combinations IS 'Сочетания контактов';

-- Таблица связи сочетаний контактов с диаметрами
CREATE TABLE combination_diameter_map (
    map_id SERIAL PRIMARY KEY,
    combination_id INTEGER REFERENCES contact_combinations(combination_id),
    diameter_id INTEGER REFERENCES contact_diameters(diameter_id),
    position INTEGER NOT NULL,
    UNIQUE(combination_id, diameter_id, position)
);
COMMENT ON TABLE combination_diameter_map IS 'Связь между сочетаниями и диаметрами контактов';

-- Таблица покрытий контактов (золото, серебро)
CREATE TABLE contact_coatings (
    coating_id SERIAL PRIMARY KEY,
    material VARCHAR(50) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE contact_coatings IS 'Материалы покрытия контактов';

-- Таблица теплостойкости
CREATE TABLE heat_resistance (
    resistance_id SERIAL PRIMARY KEY,
    temperature INTEGER NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE heat_resistance IS 'Теплостойкость в градусах Цельсия';

-- Таблица специального исполнения
CREATE TABLE special_designs (
    special_design_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE special_designs IS 'Специальные исполнения соединителей';

-- Таблица климатического исполнения
CREATE TABLE climate_designs (
    climate_id SERIAL PRIMARY KEY,
    code VARCHAR(2) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE climate_designs IS 'Климатическое исполнение';

-- Таблица типов соединения (резьбовое, байонетное)
CREATE TABLE connection_types (
    connection_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);
COMMENT ON TABLE connection_types IS 'Типы соединения (резьбовое, байонетное)'; 

-- ======================================
-- Создание таблиц справочников
-- ======================================
SELECT 'Создание таблиц справочников...' as log;

-- Файл для справочных таблиц
-- Все справочные таблицы уже созданы в 01_base_tables.sql, этот файл оставлен для будущих расширений 

-- ======================================
-- Создание таблиц технических характеристик
-- ======================================
SELECT 'Создание таблиц технических характеристик...' as log;

-- Таблицы технических характеристик соединителей 2РМТ, 2РМДТ

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

-- Таблица размеров проходных кожухов
CREATE TABLE shell_sizes (
    shell_size_id SERIAL PRIMARY KEY,
    diameter NUMERIC(5,1) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE shell_sizes IS 'Размеры проходных кожухов';
COMMENT ON COLUMN shell_sizes.shell_size_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN shell_sizes.diameter IS 'Диаметр проходного кожуха в мм';
COMMENT ON COLUMN shell_sizes.description IS 'Описание размера'; 

-- ======================================
-- Создание таблиц связей и зависимостей
-- ======================================
SELECT 'Создание таблиц связей и зависимостей...' as log;

-- Таблицы связей и таблица соединителей

-- Главная таблица соединителей
CREATE TABLE connectors (
    connector_id SERIAL PRIMARY KEY,
    gost VARCHAR(50) NOT NULL, -- ГОСТ или ТУ соединителя
    type_id INTEGER NOT NULL REFERENCES connector_types(type_id),
    size_id INTEGER NOT NULL REFERENCES body_sizes(size_id),
    body_type_id INTEGER NOT NULL REFERENCES body_types(body_type_id),
    nozzle_type_id INTEGER REFERENCES nozzle_types(nozzle_type_id),
    nut_type_id INTEGER REFERENCES nut_types(nut_type_id),
    quantity_id INTEGER NOT NULL REFERENCES contact_quantities(quantity_id),
    part_id INTEGER NOT NULL REFERENCES connector_parts(part_id),
    combination_id INTEGER NOT NULL REFERENCES contact_combinations(combination_id),
    coating_id INTEGER NOT NULL REFERENCES contact_coatings(coating_id),
    resistance_id INTEGER NOT NULL REFERENCES heat_resistance(resistance_id),
    special_design_id INTEGER REFERENCES special_designs(special_design_id),
    climate_id INTEGER NOT NULL REFERENCES climate_designs(climate_id),
    connection_type_id INTEGER NOT NULL REFERENCES connection_types(connection_type_id),
    full_code VARCHAR(50) NOT NULL UNIQUE, -- Полный код соединителя, например 2РМТ18Б4Г1В1В
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE connectors IS 'Основная таблица соединителей';

-- Таблица для хранения опций дизайна соединителя (например, возможность установки проходного кожуха)
CREATE TABLE connector_design_options (
    option_id SERIAL PRIMARY KEY,
    connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    shell_size_id INTEGER REFERENCES shell_sizes(shell_size_id),
    option_name VARCHAR(100) NOT NULL,
    option_value TEXT,
    description TEXT
);
COMMENT ON TABLE connector_design_options IS 'Опции дизайна соединителя';

-- Таблица для хранения совместимых соединителей
CREATE TABLE compatible_connectors (
    compatibility_id SERIAL PRIMARY KEY,
    connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    compatible_connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    description TEXT,
    UNIQUE (connector_id, compatible_connector_id)
);
COMMENT ON TABLE compatible_connectors IS 'Совместимые соединители';

-- Таблица для хранения документации по соединителям
CREATE TABLE connector_documentation (
    doc_id SERIAL PRIMARY KEY,
    connector_id INTEGER REFERENCES connectors(connector_id),
    type_id INTEGER REFERENCES connector_types(type_id),
    doc_name VARCHAR(100) NOT NULL,
    doc_path VARCHAR(255),
    description TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE connector_documentation IS 'Документация по соединителям';

-- Триггер для автоматического обновления updated_at при изменении записи соединителя
CREATE OR REPLACE FUNCTION update_connector_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_connector_timestamp
BEFORE UPDATE ON connectors
FOR EACH ROW
EXECUTE FUNCTION update_connector_timestamp(); 

-- ======================================
-- Заполнение базовых справочников
-- ======================================
SELECT 'Заполнение базовых справочников...' as log;

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

-- ======================================
-- Заполнение справочников технических характеристик
-- ======================================
SELECT 'Заполнение справочников технических характеристик...' as log;

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

-- ======================================
-- Заполнение таблиц зависимостей
-- ======================================
SELECT 'Заполнение таблиц зависимостей...' as log;

-- Наполнение таблиц зависимостей и связей
-- Вся информация по связям добавляется в других скриптах (01_base_dictionary_data.sql и 04_connectors_data.sql) 

-- ======================================
-- Заполнение таблицы соединителей
-- ======================================
SELECT 'Заполнение таблицы соединителей...' as log;

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

-- ======================================
-- Создание представлений
-- ======================================
SELECT 'Создание представлений...' as log;

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

-- ======================================
-- Создание функций и триггеров
-- ======================================
SELECT 'Создание функций и триггеров...' as log;

-- Функции для работы с базой данных соединителей 2РМТ, 2РМДТ

-- Функция для получения полной информации о соединителе по коду
CREATE OR REPLACE FUNCTION get_connector_by_code(p_code VARCHAR)
RETURNS TABLE (
    full_code VARCHAR,
    type_name VARCHAR,
    size_value VARCHAR,
    body_type VARCHAR,
    nozzle_type VARCHAR,
    nut_type VARCHAR,
    contact_quantity INTEGER,
    connector_part VARCHAR,
    contact_combination TEXT,
    contact_coating VARCHAR,
    heat_resistance INTEGER,
    climate_design TEXT,
    connection_type VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.full_code,
        ct.type_name,
        bs.size_value,
        bt.name,
        nt.name,
        nut.description,
        cq.quantity,
        cp.name,
        cc.description,
        cco.material,
        hr.temperature,
        cd.description,
        con.name
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
        JOIN connection_types con ON c.connection_type_id = con.connection_type_id
    WHERE 
        c.full_code = p_code;
END;
$$ LANGUAGE plpgsql;

-- Функция для поиска совместимых соединителей
CREATE OR REPLACE FUNCTION find_compatible_connectors(p_code VARCHAR)
RETURNS TABLE (
    connector_code VARCHAR,
    connector_type VARCHAR,
    size_value VARCHAR,
    body_type VARCHAR,
    connector_part VARCHAR,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c2.full_code,
        ct.type_name,
        bs.size_value,
        bt.name,
        cp.name,
        cc.description
    FROM 
        connectors c1
        JOIN compatible_connectors cc ON c1.connector_id = cc.connector_id
        JOIN connectors c2 ON cc.compatible_connector_id = c2.connector_id
        JOIN connector_types ct ON c2.type_id = ct.type_id
        JOIN body_sizes bs ON c2.size_id = bs.size_id
        JOIN body_types bt ON c2.body_type_id = bt.body_type_id
        JOIN connector_parts cp ON c2.part_id = cp.part_id
    WHERE 
        c1.full_code = p_code;
END;
$$ LANGUAGE plpgsql;

-- Функция для получения технических характеристик соединителя
CREATE OR REPLACE FUNCTION get_connector_technical_specs(p_code VARCHAR)
RETURNS TABLE (
    full_code VARCHAR,
    diameter NUMERIC,
    max_resistance DECIMAL,
    max_current DECIMAL,
    temperature INTEGER,
    spec_name VARCHAR,
    spec_value VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    WITH connector_info AS (
        SELECT 
            c.connector_id,
            c.full_code,
            c.combination_id,
            hr.temperature
        FROM 
            connectors c
            JOIN heat_resistance hr ON c.resistance_id = hr.resistance_id
        WHERE 
            c.full_code = p_code
    )
    SELECT 
        ci.full_code,
        cd.diameter,
        cr.max_resistance,
        cmc.max_current,
        ci.temperature,
        cts.spec_name,
        cts.spec_value
    FROM 
        connector_info ci
        JOIN contact_combinations cc ON ci.combination_id = cc.combination_id
        JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
        JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
        JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
        JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
        CROSS JOIN connector_technical_specs cts;
END;
$$ LANGUAGE plpgsql;

-- Функция для расчета срока службы соединителя при заданной температуре
CREATE OR REPLACE FUNCTION calculate_lifetime_at_temperature(p_temperature INTEGER)
RETURNS TABLE (
    max_lifetime_hours INTEGER,
    temperature INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH temperature_ranges AS (
        SELECT 
            lifetime_hours,
            max_temperature,
            LEAD(lifetime_hours) OVER (ORDER BY max_temperature DESC) AS next_lifetime,
            LEAD(max_temperature) OVER (ORDER BY max_temperature DESC) AS next_temperature
        FROM 
            connector_lifetime_by_temperature
        ORDER BY 
            max_temperature DESC
    )
    SELECT 
        CASE 
            WHEN p_temperature >= max_temperature THEN lifetime_hours
            WHEN p_temperature < max_temperature AND p_temperature >= next_temperature 
                THEN lifetime_hours - 
                    (lifetime_hours - next_lifetime) * 
                    (max_temperature - p_temperature) / 
                    (max_temperature - next_temperature)
            ELSE NULL
        END AS calculated_lifetime,
        p_temperature
    FROM 
        temperature_ranges
    WHERE 
        (p_temperature >= max_temperature OR 
        (p_temperature < max_temperature AND p_temperature >= next_temperature))
    ORDER BY 
        calculated_lifetime DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Функция для генерации полного кода соединителя на основе параметров
CREATE OR REPLACE FUNCTION generate_connector_code(
    p_type_name VARCHAR,
    p_size_value VARCHAR,
    p_body_type_code VARCHAR,
    p_nozzle_type_code VARCHAR,
    p_quantity INTEGER,
    p_part_code VARCHAR,
    p_combination_code VARCHAR,
    p_coating_code VARCHAR,
    p_resistance_code VARCHAR,
    p_climate_code VARCHAR
)
RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    -- Базовая часть кода: тип, размер, тип корпуса
    result := p_type_name || p_size_value || p_body_type_code;
    
    -- Добавляем тип патрубка если указан
    IF p_nozzle_type_code IS NOT NULL THEN
        result := result || p_nozzle_type_code;
    END IF;
    
    -- Добавляем количество контактов
    result := result || p_quantity::VARCHAR;
    
    -- Добавляем код части (вилка/розетка)
    result := result || p_part_code;
    
    -- Добавляем код сочетания контактов
    result := result || p_combination_code;
    
    -- Добавляем код покрытия
    result := result || p_coating_code;
    
    -- Добавляем код теплостойкости
    result := result || p_resistance_code;
    
    -- Добавляем код климатического исполнения
    result := result || p_climate_code;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Функция для парсинга кода соединителя и извлечения его компонентов
CREATE OR REPLACE FUNCTION parse_connector_code(p_code VARCHAR)
RETURNS TABLE (
    component_name VARCHAR,
    component_value VARCHAR,
    component_description TEXT
) AS $$
DECLARE
    type_part VARCHAR;
    size_part VARCHAR;
    body_type_part VARCHAR;
    nozzle_part VARCHAR;
    quantity_part VARCHAR;
    conn_part_part VARCHAR;
    combination_part VARCHAR;
    coating_part VARCHAR;
    resistance_part VARCHAR;
    climate_part VARCHAR;
    
    current_pos INTEGER := 1;
    temp_pos INTEGER;
    
    is_numeric BOOLEAN;
BEGIN
    -- Извлекаем тип (2РМТ или 2РМДТ)
    IF substring(p_code from 1 for 5) = '2РМДТ' THEN
        type_part := '2РМДТ';
        current_pos := 6;
    ELSIF substring(p_code from 1 for 4) = '2РМТ' THEN
        type_part := '2РМТ';
        current_pos := 5;
    ELSE
        RAISE EXCEPTION 'Неизвестный тип соединителя в коде %', p_code;
    END IF;
    
    -- Извлекаем размер (до первой буквы после начала)
    temp_pos := current_pos;
    WHILE temp_pos <= length(p_code) AND substring(p_code from temp_pos for 1) ~ '^[0-9]$' LOOP
        temp_pos := temp_pos + 1;
    END LOOP;
    
    size_part := substring(p_code from current_pos for temp_pos - current_pos);
    current_pos := temp_pos;
    
    -- Извлекаем тип корпуса (Б или К)
    body_type_part := substring(p_code from current_pos for 1);
    current_pos := current_pos + 1;
    
    -- Проверяем, есть ли патрубок (только для кабельных соединителей)
    IF body_type_part = 'К' AND (substring(p_code from current_pos for 1) = 'П' OR 
                              substring(p_code from current_pos for 1) = 'У' OR
                              substring(p_code from current_pos for 2) = 'Пс') THEN
        IF substring(p_code from current_pos for 2) = 'Пс' THEN
            nozzle_part := 'Пс';
            current_pos := current_pos + 2;
        ELSE
            nozzle_part := substring(p_code from current_pos for 1);
            current_pos := current_pos + 1;
        END IF;
    ELSE
        nozzle_part := NULL;
    END IF;
    
    -- Извлекаем количество контактов (до следующей буквы)
    temp_pos := current_pos;
    WHILE temp_pos <= length(p_code) AND substring(p_code from temp_pos for 1) ~ '^[0-9]$' LOOP
        temp_pos := temp_pos + 1;
    END LOOP;
    
    quantity_part := substring(p_code from current_pos for temp_pos - current_pos);
    current_pos := temp_pos;
    
    -- Извлекаем часть соединителя (Ш или Г)
    conn_part_part := substring(p_code from current_pos for 1);
    current_pos := current_pos + 1;
    
    -- Извлекаем код сочетания контактов
    is_numeric := substring(p_code from current_pos for 1) ~ '^[0-9]$';
    IF is_numeric THEN
        combination_part := substring(p_code from current_pos for 1);
        current_pos := current_pos + 1;
    ELSE
        combination_part := NULL;
    END IF;
    
    -- Извлекаем код покрытия контактов
    coating_part := substring(p_code from current_pos for 1);
    current_pos := current_pos + 1;
    
    -- Извлекаем код теплостойкости
    resistance_part := substring(p_code from current_pos for 1);
    current_pos := current_pos + 1;
    
    -- Извлекаем код климатического исполнения
    IF current_pos <= length(p_code) THEN
        climate_part := substring(p_code from current_pos for 1);
    ELSE
        climate_part := NULL;
    END IF;
    
    -- Возвращаем результаты
    component_name := 'Тип соединителя';
    component_value := type_part;
    component_description := (SELECT description FROM connector_types WHERE type_name = type_part);
    RETURN NEXT;
    
    component_name := 'Размер корпуса';
    component_value := size_part;
    component_description := (SELECT description FROM body_sizes WHERE size_value = size_part);
    RETURN NEXT;
    
    component_name := 'Тип корпуса';
    component_value := body_type_part;
    component_description := (SELECT description FROM body_types WHERE code = body_type_part);
    RETURN NEXT;
    
    IF nozzle_part IS NOT NULL THEN
        component_name := 'Тип патрубка';
        component_value := nozzle_part;
        component_description := (SELECT description FROM nozzle_types WHERE code = nozzle_part);
        RETURN NEXT;
    END IF;
    
    component_name := 'Количество контактов';
    component_value := quantity_part;
    component_description := (SELECT description FROM contact_quantities WHERE quantity = quantity_part::INTEGER);
    RETURN NEXT;
    
    component_name := 'Часть соединителя';
    component_value := conn_part_part;
    component_description := (SELECT description FROM connector_parts WHERE code = conn_part_part);
    RETURN NEXT;
    
    IF combination_part IS NOT NULL THEN
        component_name := 'Сочетание контактов';
        component_value := combination_part;
        component_description := (SELECT description FROM contact_combinations WHERE code = combination_part);
        RETURN NEXT;
    END IF;
    
    component_name := 'Покрытие контактов';
    component_value := coating_part;
    component_description := (SELECT description FROM contact_coatings WHERE code = coating_part);
    RETURN NEXT;
    
    component_name := 'Теплостойкость';
    component_value := resistance_part;
    component_description := (SELECT description FROM heat_resistance WHERE code = resistance_part);
    RETURN NEXT;
    
    IF climate_part IS NOT NULL THEN
        component_name := 'Климатическое исполнение';
        component_value := climate_part;
        component_description := (SELECT description FROM climate_designs WHERE code = climate_part);
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql; 

-- ======================================
-- Создание индексов
-- ======================================
SELECT 'Создание индексов...' as log;

-- Индексы для оптимизации запросов к базе данных соединителей 2РМТ, 2РМДТ

-- Индекс для поиска по полному коду соединителя (часто используемый критерий)
CREATE INDEX idx_connectors_full_code ON connectors(full_code);

-- Индекс для поиска по типу соединителя
CREATE INDEX idx_connectors_type_id ON connectors(type_id);

-- Композитный индекс для часто используемого сочетания параметров
CREATE INDEX idx_connectors_size_quantity ON connectors(size_id, quantity_id);

-- Индекс для поиска по виду корпуса
CREATE INDEX idx_connectors_body_type ON connectors(body_type_id);

-- Индекс для поиска по сочетанию контактов
CREATE INDEX idx_connectors_combination ON connectors(combination_id);

-- Индекс для поиска по покрытию контактов
CREATE INDEX idx_connectors_coating ON connectors(coating_id);

-- Индекс для поиска соединителей по части (вилка/розетка)
CREATE INDEX idx_connectors_part ON connectors(part_id);

-- Индекс для поиска диаметров в сочетаниях
CREATE INDEX idx_combination_diameter ON combination_diameter_map(combination_id, diameter_id);

-- Индекс для поиска совместимых соединителей
CREATE INDEX idx_compatible_connectors ON compatible_connectors(connector_id, compatible_connector_id);

-- Индекс для поиска по температуре в таблице наработки
CREATE INDEX idx_lifetime_temperature ON connector_lifetime_by_temperature(max_temperature); 

-- ======================================
-- Проверка целостности базы данных
-- ======================================
SELECT 'Проверка целостности базы данных...' as log;

-- Тесты целостности базы данных соединителей 2РМТ, 2РМДТ

-- Проверка на отсутствие соединителей с несуществующими внешними ключами
DO $$
BEGIN
    -- Проверка наличия всех типов соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connector_types ct ON c.type_id = ct.type_id 
        WHERE ct.type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами';
    
    -- Проверка наличия всех размеров корпуса
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN body_sizes bs ON c.size_id = bs.size_id 
        WHERE bs.size_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими размерами корпуса';
    
    -- Проверка наличия всех типов корпуса
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN body_types bt ON c.body_type_id = bt.body_type_id 
        WHERE bt.body_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами корпуса';
    
    -- Проверка наличия всех типов патрубка (только для кабельных соединителей)
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id 
        WHERE c.nozzle_type_id IS NOT NULL AND nt.nozzle_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами патрубка';
    
    -- Проверка наличия всех типов гайки
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN nut_types nut ON c.nut_type_id = nut.nut_type_id 
        WHERE c.nut_type_id IS NOT NULL AND nut.nut_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами гайки';
    
    -- Проверка наличия всех количеств контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id 
        WHERE cq.quantity_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими количествами контактов';
    
    -- Проверка наличия всех частей соединителя
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connector_parts cp ON c.part_id = cp.part_id 
        WHERE cp.part_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими частями';
    
    -- Проверка наличия всех сочетаний контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_combinations cc ON c.combination_id = cc.combination_id 
        WHERE cc.combination_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими сочетаниями контактов';
    
    -- Проверка наличия всех покрытий контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_coatings cco ON c.coating_id = cco.coating_id 
        WHERE cco.coating_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими покрытиями контактов';
    
    -- Проверка наличия всех значений теплостойкости
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN heat_resistance hr ON c.resistance_id = hr.resistance_id 
        WHERE hr.resistance_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими значениями теплостойкости';
    
    -- Проверка наличия всех климатических исполнений
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN climate_designs cd ON c.climate_id = cd.climate_id 
        WHERE cd.climate_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими климатическими исполнениями';
    
    -- Проверка наличия всех типов соединения
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connection_types con ON c.connection_type_id = con.connection_type_id 
        WHERE con.connection_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами соединения';
    
    -- Проверка на дубликаты полных кодов соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM (
            SELECT full_code, COUNT(*) as cnt
            FROM connectors
            GROUP BY full_code
            HAVING COUNT(*) > 1
        ) AS dupes
    ) = 0, 'Найдены дубликаты полных кодов соединителей';
    
    -- Проверка наличия всех размеров проходных кожухов
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_design_options cdo 
        LEFT JOIN shell_sizes ss ON cdo.shell_size_id = ss.shell_size_id 
        WHERE cdo.shell_size_id IS NOT NULL AND ss.shell_size_id IS NULL
    ) = 0, 'Найдены опции дизайна с несуществующими размерами проходных кожухов';
    
    -- Проверка наличия всех соединителей в таблице опций дизайна
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_design_options cdo 
        LEFT JOIN connectors c ON cdo.connector_id = c.connector_id 
        WHERE c.connector_id IS NULL
    ) = 0, 'Найдены опции дизайна для несуществующих соединителей';
    
    -- Проверка наличия всех соединителей в таблице совместимых соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM compatible_connectors cc 
        LEFT JOIN connectors c1 ON cc.connector_id = c1.connector_id 
        LEFT JOIN connectors c2 ON cc.compatible_connector_id = c2.connector_id 
        WHERE c1.connector_id IS NULL OR c2.connector_id IS NULL
    ) = 0, 'Найдены записи о совместимости для несуществующих соединителей';

    -- Проверка наличия всех диаметров контактов в таблице связей сочетаний
    ASSERT (
        SELECT COUNT(*) 
        FROM combination_diameter_map cdm 
        LEFT JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id 
        WHERE cd.diameter_id IS NULL
    ) = 0, 'Найдены записи о связях с несуществующими диаметрами';
    
    -- Проверка наличия всех сочетаний контактов в таблице связей
    ASSERT (
        SELECT COUNT(*) 
        FROM combination_diameter_map cdm 
        LEFT JOIN contact_combinations cc ON cdm.combination_id = cc.combination_id 
        WHERE cc.combination_id IS NULL
    ) = 0, 'Найдены записи о связях с несуществующими сочетаниями';
    
    -- Проверка наличия всех типов соединителей в таблице документации
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_documentation cd 
        LEFT JOIN connector_types ct ON cd.type_id = ct.type_id 
        WHERE cd.type_id IS NOT NULL AND ct.type_id IS NULL
    ) = 0, 'Найдены записи о документации для несуществующих типов соединителей';
    
    RAISE NOTICE 'Все проверки целостности базы данных выполнены успешно';
EXCEPTION
    WHEN ASSERT_FAILURE THEN
        RAISE EXCEPTION 'Ошибка целостности базы данных: %', SQLERRM;
END$$;

-- Проверка корректности характеристик
SELECT
    'Количество соединителей' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    connectors
UNION ALL
SELECT
    'Количество сочетаний диаметров' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    combination_diameter_map
UNION ALL
SELECT
    'Количество совместимых соединителей' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    compatible_connectors
UNION ALL
SELECT
    'Количество опций дизайна' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    connector_design_options;

-- Проверка наличия всех технических характеристик для контактов
SELECT
    cd.diameter AS "Диаметр контакта",
    CASE WHEN cr.max_resistance IS NULL THEN 'ОШИБКА' ELSE 'OK' END AS "Сопротивление",
    CASE WHEN cmc.max_current IS NULL THEN 'ОШИБКА' ELSE 'OK' END AS "Макс. ток"
FROM
    contact_diameters cd
    LEFT JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    LEFT JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
ORDER BY
    cd.diameter; 

-- ======================================
-- Выполнение примеров запросов
-- ======================================
SELECT 'Выполнение примеров запросов...' as log;

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

SELECT 'Инициализация базы данных успешно завершена!' as log;

-- Завершаем транзакцию
COMMIT;
