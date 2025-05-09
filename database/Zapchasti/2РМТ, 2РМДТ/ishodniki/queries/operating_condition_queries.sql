-- Примеры SQL-запросов для работы с условиями эксплуатации соединителей

-- 1. Получение всех механических факторов условий эксплуатации
SELECT 
    factor_name AS "Наименование фактора",
    parameter_name AS "Параметр",
    parameter_value AS "Значение"
FROM 
    mechanical_factors
ORDER BY 
    factor_id;

-- 2. Получение всех климатических факторов условий эксплуатации
SELECT 
    factor_name AS "Наименование фактора",
    parameter_value AS "Значение"
FROM 
    climate_factors
ORDER BY 
    factor_id;

-- 3. Получение полного списка условий эксплуатации
SELECT 
    factor_type AS "Тип фактора",
    factor_name AS "Наименование фактора",
    parameter_name AS "Параметр",
    parameter_value AS "Значение"
FROM 
    v_operating_conditions
ORDER BY 
    factor_type, factor_name;

-- 4. Использование функции для получения полного списка условий эксплуатации
SELECT * FROM get_operating_conditions();

-- 5. Поиск механических факторов с ударным ускорением больше заданного значения
SELECT 
    factor_name AS "Наименование фактора",
    parameter_name AS "Параметр",
    parameter_value AS "Значение",
    CAST(SUBSTRING(parameter_value FROM 1 FOR POSITION(' ' IN parameter_value)) AS DECIMAL) AS "Числовое значение"
FROM 
    mechanical_factors
WHERE 
    parameter_name = 'пиковое ударное ускорение' AND 
    CAST(SUBSTRING(parameter_value FROM 1 FOR POSITION(' ' IN parameter_value)) AS DECIMAL) > 1000
ORDER BY 
    CAST(SUBSTRING(parameter_value FROM 1 FOR POSITION(' ' IN parameter_value)) AS DECIMAL) DESC;

-- 6. Форматированный вывод условий эксплуатации для технической документации
WITH formatted_conditions AS (
    -- Форматирование механических факторов
    SELECT
        factor_name,
        ROW_NUMBER() OVER (ORDER BY factor_id) AS item_num,
        CASE 
            WHEN parameter_name IS NOT NULL AND parameter_value IS NOT NULL THEN
                parameter_name || ': ' || parameter_value
            ELSE
                NULL
        END AS formatted_value,
        'Механический фактор' AS factor_type,
        1 AS type_order
    FROM
        mechanical_factors
    
    UNION ALL
    
    -- Форматирование климатических факторов
    SELECT
        factor_name,
        ROW_NUMBER() OVER (ORDER BY factor_id) AS item_num,
        parameter_value AS formatted_value,
        'Климатический фактор' AS factor_type,
        2 AS type_order
    FROM
        climate_factors
)
SELECT
    factor_type AS "Тип фактора",
    item_num AS "№ п/п",
    factor_name AS "Наименование фактора",
    formatted_value AS "Параметры"
FROM
    formatted_conditions
ORDER BY
    type_order, item_num;

-- 7. Получение количества факторов каждого типа
SELECT 
    'Механические факторы' AS "Тип факторов",
    COUNT(*) AS "Количество"
FROM 
    mechanical_factors
UNION ALL
SELECT 
    'Климатические факторы' AS "Тип факторов",
    COUNT(*) AS "Количество"
FROM 
    climate_factors
ORDER BY 
    "Тип факторов";

-- 8. Получение условий эксплуатации с выделением ключевых параметров для анализа
WITH key_parameters AS (
    -- Извлечение числовых значений из механических факторов
    SELECT
        factor_name,
        parameter_name,
        parameter_value,
        CASE 
            WHEN parameter_value ~ E'^\\d+' THEN
                CAST(SUBSTRING(parameter_value FROM E'^\\d+') AS DECIMAL)
            ELSE
                NULL
        END AS numeric_value,
        CASE 
            WHEN parameter_value ~ E'\\(([0-9]+) g\\)' THEN
                CAST(SUBSTRING(parameter_value FROM E'\\(([0-9]+) g\\)') AS INTEGER)
            ELSE
                NULL
        END AS g_force,
        'Механический' AS factor_type
    FROM 
        mechanical_factors
    
    UNION ALL
    
    -- Извлечение числовых значений из климатических факторов
    SELECT
        factor_name,
        NULL AS parameter_name,
        parameter_value,
        CASE 
            WHEN parameter_value ~ E'^\\d+' THEN
                CAST(SUBSTRING(parameter_value FROM E'^\\d+') AS DECIMAL)
            WHEN parameter_value ~ E'минус (\\d+)' THEN
                -CAST(SUBSTRING(parameter_value FROM E'минус (\\d+)') AS DECIMAL)
            ELSE
                NULL
        END AS numeric_value,
        NULL AS g_force,
        'Климатический' AS factor_type
    FROM 
        climate_factors
)
SELECT
    factor_type AS "Тип фактора",
    factor_name AS "Наименование фактора",
    parameter_name AS "Параметр",
    parameter_value AS "Значение параметра",
    numeric_value AS "Числовое значение",
    g_force AS "Значение g"
FROM
    key_parameters
ORDER BY
    factor_type, 
    CASE 
        WHEN g_force IS NOT NULL THEN g_force
        ELSE 0
    END DESC,
    numeric_value DESC NULLS LAST;

-- 9. Подсчет количества параметров механических факторов
SELECT
    parameter_name AS "Параметр",
    COUNT(*) AS "Количество факторов с данным параметром"
FROM
    mechanical_factors
WHERE
    parameter_name IS NOT NULL
GROUP BY
    parameter_name
ORDER BY
    "Количество факторов с данным параметром" DESC;

-- 10. Создание текстового описания условий эксплуатации для включения в техническую документацию
WITH mechanical_desc AS (
    SELECT
        'Механические факторы:' AS header,
        STRING_AGG(
            item_num || '. ' || factor_name || CASE 
                WHEN parameter_name IS NOT NULL THEN ': ' || parameter_name || ' = ' || parameter_value
                ELSE ''
            END,
            E'\n'
            ORDER BY item_num
        ) AS section_content,
        1 AS section_order
    FROM (
        SELECT
            factor_name,
            parameter_name,
            parameter_value,
            ROW_NUMBER() OVER (ORDER BY factor_id) AS item_num
        FROM
            mechanical_factors
    ) AS numbered_items
),
climate_desc AS (
    SELECT
        'Климатические факторы:' AS header,
        STRING_AGG(
            item_num || '. ' || factor_name || ' = ' || parameter_value,
            E'\n'
            ORDER BY item_num
        ) AS section_content,
        2 AS section_order
    FROM (
        SELECT
            factor_name,
            parameter_value,
            ROW_NUMBER() OVER (ORDER BY factor_id) AS item_num
        FROM
            climate_factors
    ) AS numbered_items
)
SELECT
    header AS "Раздел",
    section_content AS "Содержание раздела"
FROM (
    SELECT * FROM mechanical_desc
    UNION ALL
    SELECT * FROM climate_desc
) AS combined_sections
ORDER BY
    section_order; 