-- Скрипт для обновления объектов схемы соединителей с проверками существования

-- Создание таблиц, если они не существуют
CREATE TABLE IF NOT EXISTS connector_sizes (
    size_id SERIAL PRIMARY KEY,
    size_code INTEGER NOT NULL,
    description VARCHAR(100)
);

-- Добавление ограничения уникальности для size_code
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'connector_sizes_size_code_unique' AND conrelid = 'connector_sizes'::regclass
    ) THEN
        ALTER TABLE connector_sizes ADD CONSTRAINT connector_sizes_size_code_unique UNIQUE (size_code);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS connector_series (
    series_id SERIAL PRIMARY KEY,
    series_name VARCHAR(10) NOT NULL UNIQUE,
    description VARCHAR(200)
);

-- Добавление комментариев к таблицам connector_sizes и connector_series
COMMENT ON TABLE connector_sizes IS 'Условные размеры вилки (розетки)';
COMMENT ON COLUMN connector_sizes.size_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN connector_sizes.size_code IS 'Код размера (14, 18, 22)';
COMMENT ON COLUMN connector_sizes.description IS 'Описание размера';

COMMENT ON TABLE connector_series IS 'Типы соединителей (2РМТ, 2РМДТ)';
COMMENT ON COLUMN connector_series.series_id IS 'Уникальный идентификатор серии';
COMMENT ON COLUMN connector_series.series_name IS 'Наименование серии (2РМТ, 2РМДТ)';
COMMENT ON COLUMN connector_series.description IS 'Описание серии';

-- Добавление данных в таблицы, если они еще не существуют
-- Размеры соединителей
DO $$
BEGIN
    -- Проверяем и добавляем размеры
    IF NOT EXISTS (SELECT 1 FROM connector_sizes WHERE size_code = 14) THEN
        INSERT INTO connector_sizes (size_code, description) VALUES (14, 'Размер 14');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM connector_sizes WHERE size_code = 18) THEN
        INSERT INTO connector_sizes (size_code, description) VALUES (18, 'Размер 18');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM connector_sizes WHERE size_code = 22) THEN
        INSERT INTO connector_sizes (size_code, description) VALUES (22, 'Размер 22');
    END IF;
END $$;

-- Серии соединителей
DO $$
BEGIN
    -- Проверяем и добавляем серии
    IF NOT EXISTS (SELECT 1 FROM connector_series WHERE series_name = '2РМТ') THEN
        INSERT INTO connector_series (series_name, description) VALUES ('2РМТ', 'Соединитель типа 2РМТ');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM connector_series WHERE series_name = '2РМДТ') THEN
        INSERT INTO connector_series (series_name, description) VALUES ('2РМДТ', 'Соединитель типа 2РМДТ');
    END IF;
END $$;

-- Создаем таблицу electromechanical_parameters только после того, как базовые таблицы созданы и заполнены
CREATE TABLE IF NOT EXISTS electromechanical_parameters (
    param_id SERIAL PRIMARY KEY,
    size_code INTEGER NOT NULL,
    series_name VARCHAR(10) NOT NULL,
    contact_diameter DECIMAL(3,1),
    contact_quantity INTEGER NOT NULL,
    contact_combination_code INTEGER NOT NULL,
    max_current DECIMAL(5,1),
    max_voltage DECIMAL(5,1),
    max_working_voltage DECIMAL(5,1),
    FOREIGN KEY (size_code) REFERENCES connector_sizes(size_code),
    FOREIGN KEY (series_name) REFERENCES connector_series(series_name)
);

-- Добавление комментариев к таблице electromechanical_parameters
COMMENT ON TABLE electromechanical_parameters IS 'Электромеханические параметры соединителей';
COMMENT ON COLUMN electromechanical_parameters.param_id IS 'Уникальный идентификатор параметров';
COMMENT ON COLUMN electromechanical_parameters.size_code IS 'Код размера';
COMMENT ON COLUMN electromechanical_parameters.series_name IS 'Наименование серии';
COMMENT ON COLUMN electromechanical_parameters.contact_diameter IS 'Диаметр контакта, мм';
COMMENT ON COLUMN electromechanical_parameters.contact_quantity IS 'Количество контактов';
COMMENT ON COLUMN electromechanical_parameters.contact_combination_code IS 'Номер сочетания контактов';
COMMENT ON COLUMN electromechanical_parameters.max_current IS 'Максимальная суммарная токовая нагрузка, А';
COMMENT ON COLUMN electromechanical_parameters.max_voltage IS 'Максимальное напряжение, В';
COMMENT ON COLUMN electromechanical_parameters.max_working_voltage IS 'Максимальное рабочее напряжение, В';

-- Электромеханические параметры
DO $$
BEGIN
    -- Проверяем и добавляем параметры
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 14 AND series_name = '2РМТ' AND contact_quantity = 4) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (14, '2РМТ', 1.0, 4, 1, 27.0, 8.0, 560);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 18 AND series_name = '2РМДТ' AND contact_quantity = 4) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (18, '2РМДТ', 1.5, 4, 5, 50.0, 15.0, 560);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 18 AND series_name = '2РМТ' AND contact_quantity = 7) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (18, '2РМТ', 1.0, 7, 1, 40.0, 7.0, 560);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 22 AND series_name = '2РМТ' AND contact_diameter = 2.0) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (22, '2РМТ', 2.0, 2, 3, 80.0, 18.0, 560);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 22 AND series_name = '2РМТ' AND contact_diameter = 3.0) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (22, '2РМТ', 3.0, 2, 3, 80.0, 32.0, 560);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM electromechanical_parameters 
                   WHERE size_code = 22 AND series_name = '2РМТ' AND contact_quantity = 10) THEN
        INSERT INTO electromechanical_parameters 
            (size_code, series_name, contact_diameter, contact_quantity, 
             contact_combination_code, max_current, max_voltage, max_working_voltage)
        VALUES 
            (22, '2РМТ', 1.0, 10, 1, 58.0, 7.0, 560);
    END IF;
END $$;

-- Обновление представления
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_views WHERE viewname = 'v_connector_parameters') THEN
        DROP VIEW v_connector_parameters;
    END IF;
END $$;

CREATE OR REPLACE VIEW v_connector_parameters AS
SELECT 
    cs.size_code AS "Условный размер вилки",
    cr.series_name AS "Тип соединителя",
    ep.contact_diameter AS "Диаметр контакта, мм",
    ep.contact_quantity AS "Количество контактов",
    ep.contact_combination_code AS "Номер сочетания контактов",
    ep.max_current AS "Максимальная суммарная токовая нагрузка, А",
    ep.max_voltage AS "Максимальное напряжение, В",
    ep.max_working_voltage AS "Максимальное рабочее напряжение, В"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
ORDER BY
    cs.size_code, cr.series_name, ep.contact_quantity;

-- Удаление существующей функции перед созданием новой
DROP FUNCTION IF EXISTS get_connector_parameters(VARCHAR);

-- Функция для получения электромеханических параметров по типу соединителя
CREATE OR REPLACE FUNCTION get_connector_parameters(p_series VARCHAR(10))
RETURNS TABLE (
    size_code INTEGER,
    contact_diameter DECIMAL(3,1),
    contact_quantity INTEGER,
    contact_combination INTEGER,
    max_current DECIMAL(5,1),
    max_voltage DECIMAL(5,1),
    max_working_voltage DECIMAL(5,1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ep.size_code,
        ep.contact_diameter,
        ep.contact_quantity,
        ep.contact_combination_code,
        ep.max_current,
        ep.max_voltage,
        ep.max_working_voltage
    FROM 
        electromechanical_parameters ep
    WHERE 
        ep.series_name = p_series
    ORDER BY
        ep.size_code, ep.contact_quantity;
END;
$$ LANGUAGE plpgsql; 