-- Тесты целостности базы данных соединителей 2РМТ, 2РМДТ

-- Проверка на отсутствие соединителей с несуществующими внешними ключами
DO $$
BEGIN
    -- Проверка наличия всех типов соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connector_types ct ON c.type_id = ct.type_id 
        WHERE ct.type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами';
    
    -- Проверка наличия всех размеров корпуса
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN body_sizes bs ON c.size_id = bs.size_id 
        WHERE bs.size_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими размерами корпуса';
    
    -- Проверка наличия всех типов корпуса
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN body_types bt ON c.body_type_id = bt.body_type_id 
        WHERE bt.body_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами корпуса';
    
    -- Проверка наличия всех типов патрубка (только для кабельных соединителей)
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN nozzle_types nt ON c.nozzle_type_id = nt.nozzle_type_id 
        WHERE c.nozzle_type_id IS NOT NULL AND nt.nozzle_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами патрубка';
    
    -- Проверка наличия всех типов гайки
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN nut_types nut ON c.nut_type_id = nut.nut_type_id 
        WHERE c.nut_type_id IS NOT NULL AND nut.nut_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами гайки';
    
    -- Проверка наличия всех количеств контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_quantities cq ON c.quantity_id = cq.quantity_id 
        WHERE cq.quantity_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими количествами контактов';
    
    -- Проверка наличия всех частей соединителя
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connector_parts cp ON c.part_id = cp.part_id 
        WHERE cp.part_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими частями';
    
    -- Проверка наличия всех сочетаний контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_combinations cc ON c.combination_id = cc.combination_id 
        WHERE cc.combination_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими сочетаниями контактов';
    
    -- Проверка наличия всех покрытий контактов
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN contact_coatings cco ON c.coating_id = cco.coating_id 
        WHERE cco.coating_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими покрытиями контактов';
    
    -- Проверка наличия всех значений теплостойкости
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN heat_resistance hr ON c.resistance_id = hr.resistance_id 
        WHERE hr.resistance_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими значениями теплостойкости';
    
    -- Проверка наличия всех климатических исполнений
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN climate_designs cd ON c.climate_id = cd.climate_id 
        WHERE cd.climate_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими климатическими исполнениями';
    
    -- Проверка наличия всех типов соединения
    ASSERT (
        SELECT COUNT(*) 
        FROM connectors c 
        LEFT JOIN connection_types con ON c.connection_type_id = con.connection_type_id 
        WHERE con.connection_type_id IS NULL
    ) = 0, 'Найдены соединители с несуществующими типами соединения';
    
    -- Проверка на дубликаты полных кодов соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM (
            SELECT full_code, COUNT(*) as cnt
            FROM connectors
            GROUP BY full_code
            HAVING COUNT(*) > 1
        ) AS dupes
    ) = 0, 'Найдены дубликаты полных кодов соединителей';
    
    -- Проверка наличия всех размеров проходных кожухов
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_design_options cdo 
        LEFT JOIN shell_sizes ss ON cdo.shell_size_id = ss.shell_size_id 
        WHERE cdo.shell_size_id IS NOT NULL AND ss.shell_size_id IS NULL
    ) = 0, 'Найдены опции дизайна с несуществующими размерами проходных кожухов';
    
    -- Проверка наличия всех соединителей в таблице опций дизайна
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_design_options cdo 
        LEFT JOIN connectors c ON cdo.connector_id = c.connector_id 
        WHERE c.connector_id IS NULL
    ) = 0, 'Найдены опции дизайна для несуществующих соединителей';
    
    -- Проверка наличия всех соединителей в таблице совместимых соединителей
    ASSERT (
        SELECT COUNT(*) 
        FROM compatible_connectors cc 
        LEFT JOIN connectors c1 ON cc.connector_id = c1.connector_id 
        LEFT JOIN connectors c2 ON cc.compatible_connector_id = c2.connector_id 
        WHERE c1.connector_id IS NULL OR c2.connector_id IS NULL
    ) = 0, 'Найдены записи о совместимости для несуществующих соединителей';

    -- Проверка наличия всех диаметров контактов в таблице связей сочетаний
    ASSERT (
        SELECT COUNT(*) 
        FROM combination_diameter_map cdm 
        LEFT JOIN contact_diameters cd ON cdm.diameter_id = cd.diameter_id 
        WHERE cd.diameter_id IS NULL
    ) = 0, 'Найдены записи о связях с несуществующими диаметрами';
    
    -- Проверка наличия всех сочетаний контактов в таблице связей
    ASSERT (
        SELECT COUNT(*) 
        FROM combination_diameter_map cdm 
        LEFT JOIN contact_combinations cc ON cdm.combination_id = cc.combination_id 
        WHERE cc.combination_id IS NULL
    ) = 0, 'Найдены записи о связях с несуществующими сочетаниями';
    
    -- Проверка наличия всех типов соединителей в таблице документации
    ASSERT (
        SELECT COUNT(*) 
        FROM connector_documentation cd 
        LEFT JOIN connector_types ct ON cd.type_id = ct.type_id 
        WHERE cd.type_id IS NOT NULL AND ct.type_id IS NULL
    ) = 0, 'Найдены записи о документации для несуществующих типов соединителей';
    
    RAISE NOTICE 'Все проверки целостности базы данных выполнены успешно';
EXCEPTION
    WHEN ASSERT_FAILURE THEN
        RAISE EXCEPTION 'Ошибка целостности базы данных: %', SQLERRM;
END$$;

-- Проверка корректности характеристик
SELECT
    'Количество соединителей' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    connectors
UNION ALL
SELECT
    'Количество сочетаний диаметров' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    combination_diameter_map
UNION ALL
SELECT
    'Количество совместимых соединителей' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    compatible_connectors
UNION ALL
SELECT
    'Количество опций дизайна' AS check_name,
    COUNT(*) AS check_value,
    'OK' AS status
FROM
    connector_design_options;

-- Проверка наличия всех технических характеристик для контактов
SELECT
    cd.diameter AS "Диаметр контакта",
    CASE WHEN cr.max_resistance IS NULL THEN 'ОШИБКА' ELSE 'OK' END AS "Сопротивление",
    CASE WHEN cmc.max_current IS NULL THEN 'ОШИБКА' ELSE 'OK' END AS "Макс. ток"
FROM
    contact_diameters cd
    LEFT JOIN contact_resistance cr ON cd.diameter_id = cr.diameter_id
    LEFT JOIN contact_max_current cmc ON cd.diameter_id = cmc.diameter_id
ORDER BY
    cd.diameter; 