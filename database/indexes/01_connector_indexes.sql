-- Индексы для оптимизации запросов к базе данных соединителей 2РМТ, 2РМДТ

-- Индекс для поиска по полному коду соединителя (часто используемый критерий)
CREATE INDEX idx_connectors_full_code ON connectors(full_code);

-- Индекс для поиска по типу соединителя
CREATE INDEX idx_connectors_type_id ON connectors(type_id);

-- Композитный индекс для часто используемого сочетания параметров
CREATE INDEX idx_connectors_size_quantity ON connectors(size_id, quantity_id);

-- Индекс для поиска по виду корпуса
CREATE INDEX idx_connectors_body_type ON connectors(body_type_id);

-- Индекс для поиска по сочетанию контактов
CREATE INDEX idx_connectors_combination ON connectors(combination_id);

-- Индекс для поиска по покрытию контактов
CREATE INDEX idx_connectors_coating ON connectors(coating_id);

-- Индекс для поиска соединителей по части (вилка/розетка)
CREATE INDEX idx_connectors_part ON connectors(part_id);

-- Индекс для поиска диаметров в сочетаниях
CREATE INDEX idx_combination_diameter ON combination_diameter_map(combination_id, diameter_id);

-- Индекс для поиска совместимых соединителей
CREATE INDEX idx_compatible_connectors ON compatible_connectors(connector_id, compatible_connector_id);

-- Индекс для поиска по температуре в таблице наработки
CREATE INDEX idx_lifetime_temperature ON connector_lifetime_by_temperature(max_temperature); 