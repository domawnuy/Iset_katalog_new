-- Примеры SQL-запросов для работы с размерами соединителей

-- 1. Получение всех размеров приборной части соединителей
SELECT 
    size_value AS "Размер соединителя (D*)",
    length_l AS "L max, мм",
    thread_d AS "D нав",
    thread_d1 AS "D1",
    length_a AS "A, мм",
    width_b AS "B, мм"
FROM 
    device_part_dimensions
ORDER BY 
    size_value;

-- 2. Получение размеров кабельной части для определенного размера (по резьбе)
SELECT 
    thread_d AS "Резьба D",
    diameter_d1 AS "Диаметр D1, мм",
    length_l AS "Длина L, мм"
FROM 
    cable_part_dimensions
WHERE 
    thread_d = 'M18x1';

-- 3. Сравнение длин патрубков разных типов для одного размера
SELECT 
    'Прямой с экранированной гайкой (ПЭ)' AS "Тип патрубка",
    thread_d AS "Резьба D",
    diameter_d1 AS "Диаметр d1, мм",
    length_l AS "Длина L, мм"
FROM 
    straight_shielded_nozzle_dimensions
WHERE 
    thread_d = 'M22x1'
UNION ALL
SELECT 
    'Прямой с неэкранированной гайкой (ПН)' AS "Тип патрубка",
    thread_d,
    diameter_d1,
    length_l
FROM 
    straight_unshielded_nozzle_dimensions
WHERE 
    thread_d = 'M22x1'
UNION ALL
SELECT 
    'Угловой с экранированной гайкой (УЭ)' AS "Тип патрубка",
    thread_d,
    diameter_d1,
    length_l
FROM 
    angled_shielded_nozzle_dimensions
WHERE 
    thread_d = 'M22x1'
UNION ALL
SELECT 
    'Угловой с неэкранированной гайкой (УН)' AS "Тип патрубка",
    thread_d,
    diameter_d1,
    length_l
FROM 
    angled_unshielded_nozzle_dimensions
WHERE 
    thread_d = 'M22x1'
ORDER BY 
    "Длина L, мм";

-- 4. Анализ разницы в размерах между экранированными и неэкранированными патрубками
WITH shielded_nozzles AS (
    SELECT 
        thread_d,
        'Прямой' AS nozzle_type,
        diameter_d1,
        length_l
    FROM 
        straight_shielded_nozzle_dimensions
    UNION ALL
    SELECT 
        thread_d,
        'Угловой' AS nozzle_type,
        diameter_d1,
        length_l
    FROM 
        angled_shielded_nozzle_dimensions
),
unshielded_nozzles AS (
    SELECT 
        thread_d,
        'Прямой' AS nozzle_type,
        diameter_d1,
        length_l
    FROM 
        straight_unshielded_nozzle_dimensions
    UNION ALL
    SELECT 
        thread_d,
        'Угловой' AS nozzle_type,
        diameter_d1,
        length_l
    FROM 
        angled_unshielded_nozzle_dimensions
)
SELECT 
    sn.thread_d AS "Резьба D",
    sn.nozzle_type AS "Тип патрубка",
    sn.length_l AS "Длина с экранированной гайкой, мм",
    un.length_l AS "Длина с неэкранированной гайкой, мм",
    un.length_l - sn.length_l AS "Разница, мм",
    ROUND((un.length_l - sn.length_l) / sn.length_l * 100, 1) AS "Разница, %"
FROM 
    shielded_nozzles sn
    JOIN unshielded_nozzles un ON sn.thread_d = un.thread_d AND sn.nozzle_type = un.nozzle_type
ORDER BY 
    sn.thread_d, sn.nozzle_type;

-- 5. Создание сводной таблицы размеров для всех типов соединителей
SELECT * FROM v_connector_dimensions;

-- 6. Получение размеров для конкретного размера соединителя
SELECT
    part_type AS "Тип части соединителя",
    thread_d AS "Резьба D",
    additional_parameter AS "Дополнительный параметр",
    max_length AS "L max, мм",
    primary_dimension AS "Размер A, мм",
    secondary_dimension AS "Размер B, мм"
FROM
    v_connector_dimensions
WHERE
    size_value = 18
ORDER BY
    part_type;

-- 7. Сравнение размеров патрубков для всех размеров соединителей
WITH nozzle_dimensions AS (
    SELECT
        CAST(SUBSTRING(thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Прямой с экранированной гайкой (ПЭ)' AS nozzle_type,
        thread_d,
        diameter_d1,
        length_l
    FROM
        straight_shielded_nozzle_dimensions
    UNION ALL
    SELECT
        CAST(SUBSTRING(thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Прямой с неэкранированной гайкой (ПН)' AS nozzle_type,
        thread_d,
        diameter_d1,
        length_l
    FROM
        straight_unshielded_nozzle_dimensions
    UNION ALL
    SELECT
        CAST(SUBSTRING(thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Угловой с экранированной гайкой (УЭ)' AS nozzle_type,
        thread_d,
        diameter_d1,
        length_l
    FROM
        angled_shielded_nozzle_dimensions
    UNION ALL
    SELECT
        CAST(SUBSTRING(thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Угловой с неэкранированной гайкой (УН)' AS nozzle_type,
        thread_d,
        diameter_d1,
        length_l
    FROM
        angled_unshielded_nozzle_dimensions
)
SELECT
    size_value AS "Размер соединителя",
    nozzle_type AS "Тип патрубка",
    thread_d AS "Резьба D",
    diameter_d1 AS "Диаметр d1, мм",
    length_l AS "Длина L, мм"
FROM
    nozzle_dimensions
ORDER BY
    size_value, nozzle_type;

-- 8. Получение размеров соединителя для использования в технической документации
WITH connector_parts AS (
    SELECT
        dp.size_value,
        'Приборная часть' AS part_name,
        dp.thread_d,
        dp.thread_d1 AS param1,
        dp.length_l AS max_length,
        dp.length_a AS dimension1,
        dp.width_b AS dimension2
    FROM
        device_part_dimensions dp
    UNION ALL
    SELECT
        CAST(SUBSTRING(cp.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Кабельная часть' AS part_name,
        cp.thread_d,
        cp.diameter_d1::TEXT AS param1,
        cp.length_l AS dimension1,
        NULL AS dimension2
    FROM
        cable_part_dimensions cp
)
SELECT
    cp.size_value AS "Размер",
    cp.part_name AS "Наименование части",
    cp.thread_d AS "Резьба",
    cp.param1 AS "Параметр 1",
    cp.dimension1 AS "Размер 1",
    cp.dimension2 AS "Размер 2"
FROM
    connector_parts cp
WHERE
    cp.size_value = 14
ORDER BY
    cp.part_name;

-- 9. Использование функции для получения размеров по типу резьбы
SELECT 
    part_type AS "Тип части соединителя",
    thread_type AS "Резьба D",
    diameter_parameter AS "Дополнительный параметр",
    max_length AS "L max, мм",
    primary_dim AS "Размер A, мм",
    secondary_dim AS "Размер B, мм"
FROM 
    get_dimensions_by_thread('M22x1');

-- 10. Получение полного набора данных для создания спецификации соединителя
WITH connector_spec AS (
    -- Получаем размеры приборной части
    SELECT
        dp.size_value,
        'Габаритные размеры приборной части' AS spec_section,
        1 AS section_order,
        'D* = ' || dp.size_value || ', L max = ' || dp.length_l || 
        ', D нав = ' || dp.thread_d || ', D1 = ' || dp.thread_d1 ||
        ', A = ' || dp.length_a || ' мм, B = ' || dp.width_b || ' мм' AS specs
    FROM
        device_part_dimensions dp
    
    UNION ALL
    
    -- Получаем размеры кабельной части
    SELECT
        CAST(SUBSTRING(cp.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Габаритные размеры кабельной части' AS spec_section,
        2 AS section_order,
        'Резьба D = ' || cp.thread_d || ', D1 = ' || cp.diameter_d1 ||
        ' мм, L = ' || cp.length_l || ' мм' AS specs
    FROM
        cable_part_dimensions cp
    
    UNION ALL
    
    -- Получаем размеры прямого патрубка с экранированной гайкой
    SELECT
        CAST(SUBSTRING(ssn.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Патрубок прямой с экранированной гайкой (ПЭ)' AS spec_section,
        3 AS section_order,
        'Резьба D = ' || ssn.thread_d || ', d1 = ' || ssn.diameter_d1 ||
        ' мм, L = ' || ssn.length_l || ' мм' AS specs
    FROM
        straight_shielded_nozzle_dimensions ssn
    
    UNION ALL
    
    -- Получаем размеры прямого патрубка с неэкранированной гайкой
    SELECT
        CAST(SUBSTRING(sun.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Патрубок прямой с неэкранированной гайкой (ПН)' AS spec_section,
        4 AS section_order,
        'Резьба D = ' || sun.thread_d || ', d1 = ' || sun.diameter_d1 ||
        ' мм, L = ' || sun.length_l || ' мм' AS specs
    FROM
        straight_unshielded_nozzle_dimensions sun
    
    UNION ALL
    
    -- Получаем размеры углового патрубка с экранированной гайкой
    SELECT
        CAST(SUBSTRING(asn.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Патрубок угловой с экранированной гайкой (УЭ)' AS spec_section,
        5 AS section_order,
        'Резьба D = ' || asn.thread_d || ', d1 = ' || asn.diameter_d1 ||
        ' мм, L = ' || asn.length_l || ' мм' AS specs
    FROM
        angled_shielded_nozzle_dimensions asn
    
    UNION ALL
    
    -- Получаем размеры углового патрубка с неэкранированной гайкой
    SELECT
        CAST(SUBSTRING(aun.thread_d FROM 2 FOR 2) AS INTEGER) AS size_value,
        'Патрубок угловой с неэкранированной гайкой (УН)' AS spec_section,
        6 AS section_order,
        'Резьба D = ' || aun.thread_d || ', d1 = ' || aun.diameter_d1 ||
        ' мм, L = ' || aun.length_l || ' мм' AS specs
    FROM
        angled_unshielded_nozzle_dimensions aun
)
SELECT
    spec_section AS "Раздел спецификации",
    specs AS "Технические характеристики"
FROM
    connector_spec
WHERE
    size_value = 18
ORDER BY
    section_order;

-- 11. Использование функции для получения размеров приборной части
SELECT
    size_value AS "D*",
    l_max AS "L max, мм",
    d_thread AS "D нав",
    d1_thread AS "D1",
    a_length AS "A, мм",
    b_width AS "B, мм"
FROM
    get_device_part_dimensions();

-- 12. Сравнение размеров приборных частей разных размеров
WITH device_dimensions AS (
    SELECT
        size_value,
        length_l,
        thread_d,
        thread_d1,
        length_a,
        width_b
    FROM
        device_part_dimensions
)
SELECT
    d1.size_value AS "D* первого размера",
    d2.size_value AS "D* второго размера",
    d2.length_l - d1.length_l AS "Разница L max, мм",
    d2.length_a - d1.length_a AS "Разница A, мм",
    d2.width_b - d1.width_b AS "Разница B, мм"
FROM
    device_dimensions d1
    CROSS JOIN device_dimensions d2
WHERE
    d1.size_value < d2.size_value
ORDER BY
    d1.size_value, d2.size_value; 