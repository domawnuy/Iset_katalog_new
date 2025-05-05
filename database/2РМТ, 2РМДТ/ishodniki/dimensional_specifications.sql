-- Создание таблиц для общего вида, габаритных, установочных и присоединительных размеров соединителей
-- На основе данных из документации

-- Таблица размеров приборной части без патрубка
CREATE TABLE device_part_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    size_value INTEGER NOT NULL,
    length_l DECIMAL(5,1) NOT NULL,
    thread_d VARCHAR(10) NOT NULL,
    thread_d1 VARCHAR(10) NOT NULL,
    length_a DECIMAL(5,1) NOT NULL,
    width_b DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE device_part_dimensions IS 'Размеры приборной части без патрубка';
COMMENT ON COLUMN device_part_dimensions.dimension_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN device_part_dimensions.size_value IS 'Значение размера (D*, 14, 18, 22)';
COMMENT ON COLUMN device_part_dimensions.length_l IS 'Размер L max, мм';
COMMENT ON COLUMN device_part_dimensions.thread_d IS 'Резьба D нав';
COMMENT ON COLUMN device_part_dimensions.thread_d1 IS 'Резьба D1';
COMMENT ON COLUMN device_part_dimensions.length_a IS 'Размер A, мм';
COMMENT ON COLUMN device_part_dimensions.width_b IS 'Размер B, мм';

-- Таблица размеров кабельной части без патрубка
CREATE TABLE cable_part_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    thread_d VARCHAR(10) NOT NULL,
    diameter_d1 DECIMAL(5,1) NOT NULL,
    length_l DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE cable_part_dimensions IS 'Размеры кабельной части без патрубка';
COMMENT ON COLUMN cable_part_dimensions.dimension_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN cable_part_dimensions.thread_d IS 'Резьба D';
COMMENT ON COLUMN cable_part_dimensions.diameter_d1 IS 'Диаметр D1, мм';
COMMENT ON COLUMN cable_part_dimensions.length_l IS 'Длина L, мм';

-- Таблица размеров патрубка прямого с экранированной гайкой (ПЭ)
CREATE TABLE straight_shielded_nozzle_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    thread_d VARCHAR(10) NOT NULL,
    diameter_d1 DECIMAL(5,1) NOT NULL,
    length_l DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE straight_shielded_nozzle_dimensions IS 'Размеры патрубка прямого с экранированной гайкой (ПЭ)';
COMMENT ON COLUMN straight_shielded_nozzle_dimensions.dimension_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN straight_shielded_nozzle_dimensions.thread_d IS 'Резьба D';
COMMENT ON COLUMN straight_shielded_nozzle_dimensions.diameter_d1 IS 'Диаметр d1, мм';
COMMENT ON COLUMN straight_shielded_nozzle_dimensions.length_l IS 'Длина L, мм';

-- Таблица размеров патрубка прямого с неэкранированной гайкой (ПН)
CREATE TABLE straight_unshielded_nozzle_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    thread_d VARCHAR(10) NOT NULL,
    diameter_d1 DECIMAL(5,1) NOT NULL,
    length_l DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE straight_unshielded_nozzle_dimensions IS 'Размеры патрубка прямого с неэкранированной гайкой (ПН)';

-- Таблица размеров патрубка углового с экранированной гайкой (УЭ)
CREATE TABLE angled_shielded_nozzle_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    thread_d VARCHAR(10) NOT NULL,
    diameter_d1 DECIMAL(5,1) NOT NULL,
    length_l DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE angled_shielded_nozzle_dimensions IS 'Размеры патрубка углового с экранированной гайкой (УЭ)';

-- Таблица размеров патрубка углового с неэкранированной гайкой (УН)
CREATE TABLE angled_unshielded_nozzle_dimensions (
    dimension_id SERIAL PRIMARY KEY,
    thread_d VARCHAR(10) NOT NULL,
    diameter_d1 DECIMAL(5,1) NOT NULL,
    length_l DECIMAL(5,1) NOT NULL
);
COMMENT ON TABLE angled_unshielded_nozzle_dimensions IS 'Размеры патрубка углового с неэкранированной гайкой (УН)';

-- Заполнение таблицы размеров приборной части
INSERT INTO device_part_dimensions (size_value, length_l, thread_d, thread_d1, length_a, width_b) VALUES
(14, 25, 'M14x1', 'M16x1', 17.0, 24),
(18, 25, 'M18x1', 'M20x1', 20.0, 27),
(22, 27, 'M22x1', 'M24x1', 23.0, 30);

-- Заполнение таблицы размеров кабельной части
INSERT INTO cable_part_dimensions (thread_d, diameter_d1, length_l) VALUES
('M14x1', 22, 25),
('M18x1', 25, 25),
('M22x1', 29, 27);

-- Заполнение таблицы размеров патрубка прямого с экранированной гайкой
INSERT INTO straight_shielded_nozzle_dimensions (thread_d, diameter_d1, length_l) VALUES
('M14x1', 6.5, 28.7),
('M18x1', 10.5, 28.7),
('M22x1', 14.0, 28.7);

-- Заполнение таблицы размеров патрубка прямого с неэкранированной гайкой
INSERT INTO straight_unshielded_nozzle_dimensions (thread_d, diameter_d1, length_l) VALUES
('M14x1', 6.5, 34),
('M18x1', 10.5, 34),
('M22x1', 14.5, 36.5);

-- Заполнение таблицы размеров патрубка углового с экранированной гайкой
INSERT INTO angled_shielded_nozzle_dimensions (thread_d, diameter_d1, length_l) VALUES
('M14x1', 6.5, 31),
('M18x1', 10.5, 34),
('M22x1', 14.0, 41);

-- Заполнение таблицы размеров патрубка углового с неэкранированной гайкой
INSERT INTO angled_unshielded_nozzle_dimensions (thread_d, diameter_d1, length_l) VALUES
('M14x1', 6.5, 35),
('M18x1', 10.5, 38),
('M22x1', 14.5, 42.5);

-- Создание представления для объединения всех размеров по типам резьбы
CREATE OR REPLACE VIEW v_connector_dimensions AS
SELECT
    dp.size_value,
    'Приборная часть' AS part_type,
    dp.thread_d,
    dp.thread_d1 AS additional_parameter,
    dp.length_l AS max_length,
    dp.length_a AS primary_dimension,
    dp.width_b AS secondary_dimension
FROM
    device_part_dimensions dp
UNION ALL
SELECT
    CAST(SUBSTRING(cp.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
    'Кабельная часть' AS part_type,
    cp.thread_d,
    cp.diameter_d1::TEXT AS additional_parameter,
    cp.length_l AS max_length,
    NULL AS primary_dimension,
    NULL AS secondary_dimension
FROM
    cable_part_dimensions cp
UNION ALL
SELECT
    CAST(SUBSTRING(ssn.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
    'Патрубок прямой с экранированной гайкой' AS part_type,
    ssn.thread_d,
    ssn.diameter_d1::TEXT AS additional_parameter,
    ssn.length_l AS max_length,
    NULL AS primary_dimension,
    NULL AS secondary_dimension
FROM
    straight_shielded_nozzle_dimensions ssn
UNION ALL
SELECT
    CAST(SUBSTRING(sun.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
    'Патрубок прямой с неэкранированной гайкой' AS part_type,
    sun.thread_d,
    sun.diameter_d1::TEXT AS additional_parameter,
    sun.length_l AS max_length,
    NULL AS primary_dimension,
    NULL AS secondary_dimension
FROM
    straight_unshielded_nozzle_dimensions sun
UNION ALL
SELECT
    CAST(SUBSTRING(asn.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
    'Патрубок угловой с экранированной гайкой' AS part_type,
    asn.thread_d,
    asn.diameter_d1::TEXT AS additional_parameter,
    asn.length_l AS max_length,
    NULL AS primary_dimension,
    NULL AS secondary_dimension
FROM
    angled_shielded_nozzle_dimensions asn
UNION ALL
SELECT
    CAST(SUBSTRING(aun.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
    'Патрубок угловой с неэкранированной гайкой' AS part_type,
    aun.thread_d,
    aun.diameter_d1::TEXT AS additional_parameter,
    aun.length_l AS max_length,
    NULL AS primary_dimension,
    NULL AS secondary_dimension
FROM
    angled_unshielded_nozzle_dimensions aun
ORDER BY
    size_value, part_type;

-- Функция для получения размеров по типу резьбы
CREATE OR REPLACE FUNCTION get_dimensions_by_thread(p_thread VARCHAR)
RETURNS TABLE (
    part_type TEXT,
    thread_type VARCHAR,
    diameter_parameter TEXT,
    max_length DECIMAL,
    primary_dim DECIMAL,
    secondary_dim DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vcd.part_type::TEXT,
        vcd.thread_d,
        vcd.additional_parameter,
        vcd.max_length,
        vcd.primary_dimension,
        vcd.secondary_dimension
    FROM 
        v_connector_dimensions vcd
    WHERE 
        vcd.thread_d = p_thread
    ORDER BY
        vcd.part_type;
END;
$$ LANGUAGE plpgsql;

-- Функция для получения размеров приборной части
CREATE OR REPLACE FUNCTION get_device_part_dimensions()
RETURNS TABLE (
    size_value INTEGER,
    l_max DECIMAL(5,1),
    d_thread VARCHAR(10),
    d1_thread VARCHAR(10),
    a_length DECIMAL(5,1),
    b_width DECIMAL(5,1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dp.size_value,
        dp.length_l,
        dp.thread_d,
        dp.thread_d1,
        dp.length_a,
        dp.width_b
    FROM 
        device_part_dimensions dp
    ORDER BY
        dp.size_value;
END;
$$ LANGUAGE plpgsql; 