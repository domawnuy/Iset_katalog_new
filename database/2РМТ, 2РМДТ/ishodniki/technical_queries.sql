-- Примеры запросов для работы с техническими характеристиками соединителей 2РМТ, 2РМДТ

-- 1. Получение полной информации о технических характеристиках контактов по диаметрам
SELECT 
    cd.diameter AS "Диаметр контакта, мм", 
    cr.max_resistance AS "Сопротивление, мОм (не более)", 
    cmc.max_current AS "Максимальный ток, А"
FROM 
    contact_diameters cd
    JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
ORDER BY 
    cd.diameter;

-- 2. Получение технических характеристик контактов для конкретного соединителя
SELECT 
    c.full_code AS "Полный код соединителя",
    cd.diameter AS "Диаметр контакта, мм", 
    cr.max_resistance AS "Сопротивление, мОм (не более)", 
    cmc.max_current AS "Максимальный ток, А"
FROM 
    connectors c
    JOIN contact_combinations cc ON c.combination_id = cc.combination_id
    JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
    JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
    JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
WHERE 
    c.full_code = '2РМТ18Б4Г1В1В'
ORDER BY 
    cd.diameter;

-- 3. Получение информации о наработке соединителя в зависимости от температуры
SELECT 
    lifetime_hours AS "Минимальная наработка, ч",
    max_temperature AS "Максимальная температура, °C"
FROM 
    connector_lifetime_by_temperature
ORDER BY 
    lifetime_hours;

-- 4. Получение информации о перегреве контактов в зависимости от токовой нагрузки
SELECT 
    load_percent AS "Токовая нагрузка, % от максимально допустимой",
    overheat_temperature AS "Температура перегрева контактов, °C"
FROM 
    contact_overheat_by_load
ORDER BY 
    load_percent DESC;

-- 5. Получение общих технических характеристик соединителей
SELECT 
    spec_name AS "Характеристика",
    spec_value AS "Значение",
    description AS "Описание"
FROM 
    connector_technical_specs
ORDER BY 
    spec_id;

-- 6. Расчет максимальной температуры контактов при разных токовых нагрузках для соединителя
WITH connector_contacts AS (
    -- Получаем информацию о контактах для конкретного соединителя
    SELECT 
        c.full_code,
        cd.diameter,
        cmc.max_current
    FROM 
        connectors c
        JOIN contact_combinations cc ON c.combination_id = cc.combination_id
        JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
        JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
        JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
    WHERE 
        c.full_code = '2РМТ18Б7Ш1В1В'
)
SELECT 
    cc.full_code AS "Код соединителя",
    cc.diameter AS "Диаметр контакта, мм",
    cc.max_current AS "Максимальный ток, А",
    col.load_percent AS "Токовая нагрузка, %",
    ROUND(cc.max_current * col.load_percent / 100, 1) AS "Расчетный ток, А",
    col.overheat_temperature AS "Температура перегрева, °C"
FROM 
    connector_contacts cc
    CROSS JOIN contact_overheat_by_load col
WHERE 
    col.load_percent IN (50, 75, 100, 110, 120) -- Выбираем только некоторые значения нагрузки
ORDER BY 
    cc.diameter, col.load_percent;

-- 7. Определение допустимого срока эксплуатации соединителя при заданной рабочей температуре
WITH temperature_range AS (
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
    lifetime_hours AS "Минимальная наработка, ч",
    max_temperature AS "Максимальная температура, °C"
FROM 
    temperature_range
WHERE 
    max_temperature >= 100 AND next_temperature < 100 -- Ищем диапазон для 100°C
UNION
SELECT 
    tr.next_lifetime AS "Минимальная наработка, ч",
    tr.next_temperature AS "Максимальная температура, °C"
FROM 
    temperature_range tr
WHERE 
    tr.max_temperature >= 100 AND tr.next_temperature < 100;

-- 8. Комплексный анализ тепловых режимов и токовых нагрузок для соединителя
WITH connector_type_info AS (
    -- Получаем информацию о типе соединителя
    SELECT 
        c.connector_id,
        c.full_code,
        ct.type_name,
        bs.size_value,
        cq.quantity,
        cc.code AS combination_code
    FROM 
        connectors c
        JOIN connector_types ct ON c.type_id = ct.type_id
        JOIN body_sizes bs ON c.size_id = bs.size_id
        JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id
        JOIN contact_combinations cc ON c.combination_id = cc.combination_id
    WHERE 
        c.full_code = '2РМТ18Б7Ш1В1В'
),
contact_info AS (
    -- Получаем информацию о контактах для выбранного сочетания
    SELECT 
        cti.full_code,
        cti.type_name,
        cti.size_value,
        cti.quantity,
        cd.diameter,
        cr.max_resistance,
        cmc.max_current
    FROM 
        connector_type_info cti
        JOIN contact_combinations cc ON cc.code = cti.combination_code
        JOIN combination_diameter_map cdm ON cc.combination_id = cdm.combination_id
        JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id
        JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
        JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
)
SELECT 
    ci.full_code AS "Код соединителя",
    ci.type_name AS "Тип",
    ci.size_value AS "Размер",
    ci.quantity AS "Кол-во контактов",
    ci.diameter AS "Диаметр контакта, мм",
    ci.max_resistance AS "Сопротивление, мОм",
    ci.max_current AS "Максимальный ток, А",
    col.load_percent AS "Нагрузка, %",
    col.overheat_temperature AS "Температура перегрева, °C",
    CASE 
        WHEN col.overheat_temperature <= 50 THEN 'Нормальный режим'
        WHEN col.overheat_temperature <= 80 THEN 'Повышенный нагрев'
        WHEN col.overheat_temperature <= 120 THEN 'Высокий нагрев'
        ELSE 'Критический нагрев'
    END AS "Режим работы"
FROM 
    contact_info ci
    CROSS JOIN contact_overheat_by_load col
WHERE 
    col.load_percent IN (50, 75, 100, 120, 180) -- Выбираем только некоторые значения нагрузки
ORDER BY 
    ci.diameter, col.load_percent;

-- Запросы для проверки технических характеристик соединителей 2РМТ, 2РМДТ

-- Получение данных о максимальном сопротивлении и токе контактов по диаметрам
SELECT * FROM v_contact_specs;

-- Получение данных о наработке соединителей при разных температурах
SELECT * FROM v_thermal_specs WHERE spec_type = 'Наработка' ORDER BY max_temperature;

-- Получение данных о температуре перегрева контактов при разных нагрузках
SELECT * FROM v_thermal_specs WHERE spec_type = 'Перегрев' ORDER BY hours DESC;

-- Получение общих технических характеристик соединителей
SELECT name, value, description FROM connector_specifications ORDER BY id;

-- Пример комплексного запроса: получение полных данных о контактах
SELECT 
    cd.diameter AS "Диаметр контакта (мм)",
    cr.max_resistance_mohm AS "Сопротивление (мОм)",
    mc.max_current_amp AS "Максимальный ток (А)",
    ROUND(1000 / cr.max_resistance_mohm, 2) AS "Проводимость (Сименс)"
FROM 
    contact_diameters cd
    JOIN contact_resistances cr ON cd.diameter_id = cr.contact_diameter_id
    JOIN max_currents mc ON cd.diameter_id = mc.contact_diameter_id
ORDER BY 
    cd.diameter;

-- Пример расчета рекомендуемого тока с учетом температурного запаса (70% от максимального)
SELECT 
    cd.diameter AS "Диаметр контакта (мм)",
    mc.max_current_amp AS "Максимальный ток (А)",
    ROUND(mc.max_current_amp * 0.7, 1) AS "Рекомендуемый ток (А)",
    (SELECT temperature_rise FROM contact_overheat WHERE load_percent = 70) AS "Перегрев при рек. токе (°C)"
FROM 
    contact_diameters cd
    JOIN max_currents mc ON cd.diameter_id = mc.contact_diameter_id
ORDER BY 
    cd.diameter;

-- Расчет максимальной наработки соединителя при разных температурах окружающей среды
WITH ambient_temps AS (
    SELECT unnest(ARRAY[25, 50, 75, 100]) AS ambient_temp
)
SELECT 
    at.ambient_temp AS "Темп. окружающей среды (°C)",
    oh.max_temperature AS "Макс. рабочая темп. (°C)",
    oh.max_temperature - at.ambient_temp AS "Температурный запас (°C)",
    oh.hours AS "Наработка (часов)"
FROM 
    operating_hours oh
    CROSS JOIN ambient_temps at
WHERE 
    oh.max_temperature > at.ambient_temp
ORDER BY 
    at.ambient_temp, oh.hours DESC;

-- Исследование зависимости между током нагрузки и температурой перегрева
SELECT 
    co.load_percent AS "Нагрузка (%)",
    co.temperature_rise AS "Перегрев (°C)",
    ROUND(CAST(co.temperature_rise AS DECIMAL) / co.load_percent, 2) AS "Коэф. перегрева (°C/%)"
FROM 
    contact_overheat co
ORDER BY 
    co.load_percent;

-- Получение контактов с наилучшей эффективностью (отношение макс. тока к сопротивлению)
SELECT 
    cd.diameter AS "Диаметр контакта (мм)",
    cr.max_resistance_mohm AS "Сопротивление (мОм)",
    mc.max_current_amp AS "Максимальный ток (А)",
    ROUND(mc.max_current_amp / cr.max_resistance_mohm, 2) AS "Эффективность (А/мОм)"
FROM 
    contact_diameters cd
    JOIN contact_resistances cr ON cd.diameter_id = cr.contact_diameter_id
    JOIN max_currents mc ON cd.diameter_id = mc.contact_diameter_id
ORDER BY 
    (mc.max_current_amp / cr.max_resistance_mohm) DESC; 