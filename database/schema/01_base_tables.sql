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