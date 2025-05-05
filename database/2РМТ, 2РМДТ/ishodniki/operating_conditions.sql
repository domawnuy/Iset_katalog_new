-- Создание таблиц для условий эксплуатации соединителей 2РМТ, 2РМДТ
-- На основе данных из документации

-- Таблица механических факторов
CREATE TABLE mechanical_factors (
    factor_id SERIAL PRIMARY KEY,
    factor_name VARCHAR(100) NOT NULL,
    parameter_name VARCHAR(100),
    parameter_value VARCHAR(100)
);
COMMENT ON TABLE mechanical_factors IS 'Механические факторы условий эксплуатации';
COMMENT ON COLUMN mechanical_factors.factor_id IS 'Уникальный идентификатор фактора';
COMMENT ON COLUMN mechanical_factors.factor_name IS 'Наименование механического фактора';
COMMENT ON COLUMN mechanical_factors.parameter_name IS 'Наименование параметра фактора';
COMMENT ON COLUMN mechanical_factors.parameter_value IS 'Значение параметра фактора';

-- Таблица климатических факторов
CREATE TABLE climate_factors (
    factor_id SERIAL PRIMARY KEY,
    factor_name VARCHAR(100) NOT NULL,
    parameter_value VARCHAR(100)
);
COMMENT ON TABLE climate_factors IS 'Климатические факторы условий эксплуатации';
COMMENT ON COLUMN climate_factors.factor_id IS 'Уникальный идентификатор фактора';
COMMENT ON COLUMN climate_factors.factor_name IS 'Наименование климатического фактора';
COMMENT ON COLUMN climate_factors.parameter_value IS 'Значение параметра фактора';

-- Заполнение таблицы механических факторов
INSERT INTO mechanical_factors (factor_name, parameter_name, parameter_value) VALUES
('Синусоидальная вибрация', 'диапазон частот', '1 – 5 000 Гц'),
('Синусоидальная вибрация', 'амплитуда ускорения', '490 м/с² (50 g)'),
('Механический удар одиночного действия', 'пиковое ударное ускорение', '5 000 м/с² (500 g)'),
('Механический удар многократного действия', 'пиковое ударное ускорение', '1 000 м/с² (100 g)');

-- Заполнение таблицы климатических факторов
INSERT INTO climate_factors (factor_name, parameter_value) VALUES
('Повышенная рабочая температура среды', '100 °C'),
('Пониженная предельная температура среды', 'минус 60 °C'),
('Атмосферное пониженное рабочее давление', '1,33×10⁻¹⁰ Па (1×10⁻¹² мм рт. ст.)'),
('Повышенная относительная влажность воздуха при температуре +40 °C (без конденсации влаги)', '98 %');

-- Создание представления для удобного просмотра условий эксплуатации
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

-- Функция для получения полного списка условий эксплуатации
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