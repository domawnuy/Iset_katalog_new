-- Скрипт для обновления объектов условий эксплуатации с проверками существования

-- Обновление таблиц не требуется, они уже существуют
-- Добавим новые данные, если они еще не добавлены

-- Проверка и добавление новых данных в таблицу механических факторов
DO $$
BEGIN
    -- Проверяем, есть ли уже записи с указанными значениями
    IF NOT EXISTS (SELECT 1 FROM mechanical_factors 
                  WHERE factor_name = 'Синусоидальная вибрация' AND parameter_name = 'диапазон частот') THEN
        INSERT INTO mechanical_factors (factor_name, parameter_name, parameter_value) 
        VALUES ('Синусоидальная вибрация', 'диапазон частот', '1 – 5 000 Гц');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM mechanical_factors 
                  WHERE factor_name = 'Синусоидальная вибрация' AND parameter_name = 'амплитуда ускорения') THEN
        INSERT INTO mechanical_factors (factor_name, parameter_name, parameter_value) 
        VALUES ('Синусоидальная вибрация', 'амплитуда ускорения', '490 м/с² (50 g)');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM mechanical_factors 
                  WHERE factor_name = 'Механический удар одиночного действия') THEN
        INSERT INTO mechanical_factors (factor_name, parameter_name, parameter_value) 
        VALUES ('Механический удар одиночного действия', 'пиковое ударное ускорение', '5 000 м/с² (500 g)');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM mechanical_factors 
                  WHERE factor_name = 'Механический удар многократного действия') THEN
        INSERT INTO mechanical_factors (factor_name, parameter_name, parameter_value) 
        VALUES ('Механический удар многократного действия', 'пиковое ударное ускорение', '1 000 м/с² (100 g)');
    END IF;
END $$;

-- Проверка и добавление новых данных в таблицу климатических факторов
DO $$
BEGIN
    -- Проверяем, есть ли уже записи с указанными значениями
    IF NOT EXISTS (SELECT 1 FROM climate_factors 
                  WHERE factor_name = 'Повышенная рабочая температура среды') THEN
        INSERT INTO climate_factors (factor_name, parameter_value) 
        VALUES ('Повышенная рабочая температура среды', '100 °C');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM climate_factors 
                  WHERE factor_name = 'Пониженная предельная температура среды') THEN
        INSERT INTO climate_factors (factor_name, parameter_value) 
        VALUES ('Пониженная предельная температура среды', 'минус 60 °C');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM climate_factors 
                  WHERE factor_name = 'Атмосферное пониженное рабочее давление') THEN
        INSERT INTO climate_factors (factor_name, parameter_value) 
        VALUES ('Атмосферное пониженное рабочее давление', '1,33×10⁻⁴ мм рт. ст.');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM climate_factors 
                  WHERE factor_name LIKE 'Повышенная относительная влажность воздуха%') THEN
        INSERT INTO climate_factors (factor_name, parameter_value) 
        VALUES ('Повышенная относительная влажность воздуха при температуре +40 °C (без конденсации влаги)', '98 %');
    END IF;
END $$;

-- Обновление представления
CREATE OR REPLACE VIEW v_operating_conditions AS
SELECT 
    'Механический' AS factor_type,
    factor_name, 
    parameter_name, 
    parameter_value
FROM 
    mechanical_factors
UNION ALL
SELECT 
    'Климатический' AS factor_type,
    factor_name,
    NULL AS parameter_name,
    parameter_value
FROM 
    climate_factors
ORDER BY
    factor_type, factor_name;

-- Удаление существующей функции перед созданием новой
DROP FUNCTION IF EXISTS get_operating_conditions();

-- Создание новой функции с правильными типами данных
CREATE OR REPLACE FUNCTION get_operating_conditions() 
RETURNS TABLE (
    factor_type VARCHAR(20),
    factor_name VARCHAR(100),
    parameter_name VARCHAR(100),
    parameter_value VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        oc.factor_type::VARCHAR(20),
        oc.factor_name::VARCHAR(100),
        oc.parameter_name::VARCHAR(100),
        oc.parameter_value::VARCHAR(100)
    FROM 
        v_operating_conditions oc;
END;
$$ LANGUAGE plpgsql; 