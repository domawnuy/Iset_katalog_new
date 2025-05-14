-- Скрипт инициализации базы данных соединителей 2РМТ, 2РМДТ (Unified version)
-- Разработчик: Claude
-- Версия: 1.2
-- Дата: 2025-05-12

-- Убедимся, что скрипт выполняется в транзакции
BEGIN;

-- Установка пути поиска для схемы
SET search_path TO public;

-- Установка кодировки и локали
SET client_encoding TO 'UTF8';
SET standard_conforming_strings TO on;

-- Включаем логи для отслеживания выполнения
SELECT 'Инициализация базы данных соединителей 2РМТ, 2РМДТ...' as log;


-- ======================================
-- Инициализация таблицы миграций
-- ======================================
SELECT 'Инициализация таблицы миграций...' as log;

-- Миграция 000: Инициализация таблицы миграций для уже существующей БД
-- Версия: 1.0
-- Дата: 2025-05-12

-- Начало транзакции

-- Создание таблицы миграций
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Добавление записей о уже примененных миграциях
INSERT INTO migrations (migration_name, version, applied_at)
VALUES 
('001_initial_schema', '1.0', NOW() - INTERVAL '1 day'),
('002_initial_data', '1.0', NOW() - INTERVAL '1 day'),
('003_views_functions', '1.0', NOW() - INTERVAL '1 day');

-- Завершение транзакции

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
-- Заполнение базовых справочников
-- ======================================
SELECT 'Заполнение базовых справочников...' as log;

-- Данные уже существуют в базе данных
-- Этот файл сохранен для сохранения структуры проекта и для возможности восстановления базы данных с нуля
-- Реальные данные можно получить, выполнив экспорт из существующей БД

-- ======================================
-- Заполнение справочников технических характеристик
-- ======================================
SELECT 'Заполнение справочников технических характеристик...' as log;

-- Данные уже существуют в базе данных
-- Этот файл сохранен для сохранения структуры проекта и для возможности восстановления базы данных с нуля
-- Реальные данные можно получить, выполнив экспорт из существующей БД

-- ======================================
-- Заполнение таблиц зависимостей
-- ======================================
SELECT 'Заполнение таблиц зависимостей...' as log;

-- Данные уже существуют в базе данных
-- Этот файл сохранен для сохранения структуры проекта и для возможности восстановления базы данных с нуля
-- Реальные данные можно получить, выполнив экспорт из существующей БД

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
-- Удаление ненужных таблиц
-- ======================================
SELECT 'Удаление ненужных таблиц...' as log;

-- Миграция 005: Удаление таблиц
-- Версия: 1.0
-- Дата: 2025-05-12

-- Начало транзакции

-- Установка кодировки клиента UTF-8
SET client_encoding TO 'UTF8';

-- Проверка, что миграция еще не применялась
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM migrations WHERE migration_name = '005_remove_tables') THEN
        RAISE EXCEPTION 'Миграция 005_remove_tables уже применена';
    END IF;
END $$;

-- Сначала удаляем зависимые представления
DROP VIEW IF EXISTS v_connectors_full CASCADE;
DROP VIEW IF EXISTS v_connectors_search CASCADE;

-- Удаляем зависимые таблицы
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS connector_documentation CASCADE;
DROP TABLE IF EXISTS compatible_connectors CASCADE;
DROP TABLE IF EXISTS connector_design_options CASCADE;

-- Теперь удаляем основные таблицы
DROP TABLE IF EXISTS product_groups CASCADE;
DROP TABLE IF EXISTS connectors CASCADE;

-- Удаляем связанные функции и триггеры
DROP FUNCTION IF EXISTS update_product_timestamp() CASCADE;
DROP FUNCTION IF EXISTS update_product_group_timestamp() CASCADE;
DROP FUNCTION IF EXISTS update_connector_timestamp() CASCADE;

-- Удаляем запись миграции 004, так как эти таблицы больше не нужны
DELETE FROM migrations WHERE migration_name = '004_product_groups';

-- Запись информации о текущей миграции
INSERT INTO migrations (migration_name, version)
VALUES ('005_remove_tables', '1.0');

-- Завершение транзакции

SELECT 'Инициализация базы данных успешно завершена!' as log;

-- Завершаем транзакцию
COMMIT;
