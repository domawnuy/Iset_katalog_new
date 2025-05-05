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