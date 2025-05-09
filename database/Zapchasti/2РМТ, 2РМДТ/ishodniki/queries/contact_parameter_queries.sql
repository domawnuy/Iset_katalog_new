-- Примеры SQL-запросов для работы с параметрами электромеханических соединителей и их контактов

-- 1. Получение полной информации о соединителях по типам и размерам
SELECT 
    cs.size_code AS "Условный размер",
    cr.series_name AS "Тип соединителя",
    ep.contact_diameter AS "Диаметр контакта, мм",
    ep.contact_quantity AS "Количество контактов",
    ep.contact_combination_code AS "Номер сочетания контактов",
    ep.max_current AS "Макс. суммарная токовая нагрузка, А",
    ep.max_voltage AS "Макс. напряжение на один контакт, В",
    ep.max_working_voltage AS "Макс. рабочее напряжение, В"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
ORDER BY 
    cs.size_code, cr.series_name, ep.contact_quantity;

-- 2. Получение соединителей с максимальной токовой нагрузкой
SELECT 
    cs.size_code AS "Условный размер",
    cr.series_name AS "Тип соединителя",
    ep.contact_diameter AS "Диаметр контакта, мм",
    ep.contact_quantity AS "Количество контактов",
    ep.max_current AS "Макс. суммарная токовая нагрузка, А"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
ORDER BY 
    ep.max_current DESC
LIMIT 5;

-- 3. Сравнение соединителей типа 2РМТ и 2РМДТ с одинаковым размером и количеством контактов
WITH rmt AS (
    SELECT 
        ep.size_code,
        ep.contact_quantity,
        ep.contact_diameter,
        ep.max_current,
        ep.max_voltage
    FROM 
        electromechanical_parameters ep
    WHERE 
        ep.series_name = '2РМТ'
),
rmdt AS (
    SELECT 
        ep.size_code,
        ep.contact_quantity,
        ep.contact_diameter,
        ep.max_current,
        ep.max_voltage
    FROM 
        electromechanical_parameters ep
    WHERE 
        ep.series_name = '2РМДТ'
)
SELECT 
    rmt.size_code AS "Условный размер",
    rmt.contact_quantity AS "Количество контактов",
    rmt.contact_diameter AS "Диаметр контакта 2РМТ, мм",
    rmdt.contact_diameter AS "Диаметр контакта 2РМДТ, мм",
    rmt.max_current AS "Макс. ток 2РМТ, А",
    rmdt.max_current AS "Макс. ток 2РМДТ, А",
    rmt.max_voltage AS "Макс. напряжение 2РМТ, В",
    rmdt.max_voltage AS "Макс. напряжение 2РМДТ, В",
    ROUND((rmdt.max_current - rmt.max_current) / rmt.max_current * 100, 1) AS "Разница тока, %"
FROM 
    rmt
    JOIN rmdt ON rmt.size_code = rmdt.size_code AND rmt.contact_quantity = rmdt.contact_quantity
ORDER BY 
    rmt.size_code, rmt.contact_quantity;

-- 4. Расчет удельной токовой нагрузки на один контакт для всех соединителей
SELECT 
    cs.size_code AS "Условный размер",
    cr.series_name AS "Тип соединителя",
    ep.contact_quantity AS "Количество контактов",
    ep.max_current AS "Макс. суммарная токовая нагрузка, А",
    ROUND(ep.max_current / ep.contact_quantity, 2) AS "Нагрузка на один контакт, А",
    ep.max_voltage AS "Макс. напряжение на контакт, В"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
ORDER BY 
    (ep.max_current / ep.contact_quantity) DESC;

-- 5. Нахождение соединителей с наибольшим диаметром контактов
SELECT 
    cs.size_code AS "Условный размер",
    cr.series_name AS "Тип соединителя",
    ep.contact_diameter AS "Диаметр контакта, мм",
    ep.contact_quantity AS "Количество контактов",
    ep.max_current AS "Макс. ток, А",
    ep.max_voltage AS "Макс. напряжение, В"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
WHERE 
    ep.contact_diameter IS NOT NULL
ORDER BY 
    ep.contact_diameter DESC, ep.max_current DESC;

-- 6. Получение среднего значения максимального тока и напряжения по типам соединителей
SELECT 
    cr.series_name AS "Тип соединителя",
    ROUND(AVG(ep.max_current), 2) AS "Средний макс. ток, А",
    ROUND(AVG(ep.max_voltage), 2) AS "Среднее макс. напряжение, В",
    COUNT(*) AS "Количество вариантов исполнения"
FROM 
    electromechanical_parameters ep
    JOIN connector_series cr ON ep.series_name = cr.series_name
GROUP BY 
    cr.series_name
ORDER BY 
    "Средний макс. ток, А" DESC;

-- 7. Получение вариантов исполнения для соединителей с разным количеством контактов
SELECT 
    cs.size_code AS "Условный размер",
    ep.contact_quantity AS "Количество контактов",
    STRING_AGG(cr.series_name, ', ' ORDER BY cr.series_name) AS "Доступные типы соединителей",
    COUNT(*) AS "Количество вариантов"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
GROUP BY 
    cs.size_code, ep.contact_quantity
ORDER BY 
    cs.size_code, ep.contact_quantity;

-- 8. Анализ зависимости максимального тока от диаметра контакта
SELECT 
    ep.contact_diameter AS "Диаметр контакта, мм",
    ROUND(AVG(ep.max_voltage), 2) AS "Среднее макс. напряжение, В",
    ROUND(AVG(ep.max_current / ep.contact_quantity), 2) AS "Средний ток на один контакт, А",
    COUNT(*) AS "Количество вариантов исполнения"
FROM 
    electromechanical_parameters ep
WHERE 
    ep.contact_diameter IS NOT NULL
GROUP BY 
    ep.contact_diameter
ORDER BY 
    ep.contact_diameter;

-- 9. Получение информации о максимальном рабочем напряжении
SELECT 
    ep.max_working_voltage AS "Максимальное рабочее напряжение, В",
    COUNT(*) AS "Количество соединителей",
    STRING_AGG(DISTINCT cr.series_name, ', ' ORDER BY cr.series_name) AS "Типы соединителей"
FROM 
    electromechanical_parameters ep
    JOIN connector_series cr ON ep.series_name = cr.series_name
GROUP BY 
    ep.max_working_voltage
ORDER BY 
    ep.max_working_voltage;

-- 10. Комплексный анализ соединителей по размеру и типу
WITH connector_summary AS (
    SELECT 
        cs.size_code,
        cr.series_name,
        COUNT(*) AS variant_count,
        MIN(ep.contact_quantity) AS min_contacts,
        MAX(ep.contact_quantity) AS max_contacts,
        MIN(ep.contact_diameter) AS min_diameter,
        MAX(ep.contact_diameter) AS max_diameter,
        MIN(ep.max_current) AS min_current,
        MAX(ep.max_current) AS max_current
    FROM 
        electromechanical_parameters ep
        JOIN connector_sizes cs ON ep.size_code = cs.size_code
        JOIN connector_series cr ON ep.series_name = cr.series_name
    GROUP BY 
        cs.size_code, cr.series_name
)
SELECT 
    cs.size_code AS "Условный размер",
    cs.series_name AS "Тип соединителя",
    cs.variant_count AS "Количество вариантов",
    cs.min_contacts || ' - ' || cs.max_contacts AS "Диапазон количества контактов",
    cs.min_diameter || ' - ' || cs.max_diameter AS "Диапазон диаметров контактов, мм",
    cs.min_current || ' - ' || cs.max_current AS "Диапазон максимального тока, А"
FROM 
    connector_summary cs
ORDER BY 
    cs.size_code, cs.series_name;

-- 11. Использование функции для получения параметров по типу соединителя
SELECT * FROM get_connector_parameters('2РМТ');

-- 12. Получение соединителей с определенным количеством контактов
SELECT 
    cs.size_code AS "Условный размер",
    cr.series_name AS "Тип соединителя",
    ep.contact_diameter AS "Диаметр контакта, мм",
    ep.contact_quantity AS "Количество контактов",
    ep.max_current AS "Макс. суммарная токовая нагрузка, А",
    ep.max_voltage AS "Макс. напряжение на контакт, В"
FROM 
    electromechanical_parameters ep
    JOIN connector_sizes cs ON ep.size_code = cs.size_code
    JOIN connector_series cr ON ep.series_name = cr.series_name
WHERE 
    ep.contact_quantity = 4
ORDER BY 
    cs.size_code, cr.series_name; 