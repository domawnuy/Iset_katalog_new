-- Таблицы технических характеристик соединителей 2РМТ, 2РМДТ

-- Таблица сопротивления контактов в зависимости от диаметра
CREATE TABLE contact_resistance (
    resistance_id SERIAL PRIMARY KEY,
    diameter_id INTEGER NOT NULL REFERENCES contact_diameters(diameter_id),
    max_resistance DECIMAL(5,2) NOT NULL -- мОм
);
COMMENT ON TABLE contact_resistance IS 'Сопротивление контактов в зависимости от диаметра';
COMMENT ON COLUMN contact_resistance.resistance_id IS 'Уникальный идентификатор';
COMMENT ON COLUMN contact_resistance.diameter_id IS 'Ссылка на диаметр контакта';
COMMENT ON COLUMN contact_resistance.max_resistance IS 'Максимальное сопротивление контакта в мОм';

-- Таблица максимальных токов по диаметрам контактов
CREATE TABLE contact_max_current (
    current_id SERIAL PRIMARY KEY,
    diameter_id INTEGER NOT NULL REFERENCES contact_diameters(diameter_id),
    max_current DECIMAL(5,1) NOT NULL -- А
);
COMMENT ON TABLE contact_max_current IS 'Максимальный ток на одиночный контакт';
COMMENT ON COLUMN contact_max_current.current_id IS 'Уникальный идентификатор';
COMMENT ON COLUMN contact_max_current.diameter_id IS 'Ссылка на диаметр контакта';
COMMENT ON COLUMN contact_max_current.max_current IS 'Максимальный ток в амперах';

-- Таблица минимальной наработки соединителя в зависимости от температуры
CREATE TABLE connector_lifetime_by_temperature (
    lifetime_id SERIAL PRIMARY KEY,
    lifetime_hours INTEGER NOT NULL, -- часы
    max_temperature INTEGER NOT NULL -- °C
);
COMMENT ON TABLE connector_lifetime_by_temperature IS 'Минимальная наработка соединителя в зависимости от максимальной температуры';
COMMENT ON COLUMN connector_lifetime_by_temperature.lifetime_id IS 'Уникальный идентификатор записи';
COMMENT ON COLUMN connector_lifetime_by_temperature.lifetime_hours IS 'Минимальная наработка соединителя в часах';
COMMENT ON COLUMN connector_lifetime_by_temperature.max_temperature IS 'Максимальная температура соединителя в °C';

-- Таблица температуры перегрева контактов в зависимости от токовой нагрузки
CREATE TABLE contact_overheat_by_load (
    overheat_id SERIAL PRIMARY KEY,
    load_percent INTEGER NOT NULL, -- % от максимально допустимой по ТУ
    overheat_temperature INTEGER NOT NULL -- °C
);
COMMENT ON TABLE contact_overheat_by_load IS 'Температура перегрева контактов в зависимости от токовой нагрузки';
COMMENT ON COLUMN contact_overheat_by_load.overheat_id IS 'Уникальный идентификатор записи';
COMMENT ON COLUMN contact_overheat_by_load.load_percent IS 'Токовая нагрузка в процентах от максимально допустимой по ТУ';
COMMENT ON COLUMN contact_overheat_by_load.overheat_temperature IS 'Температура перегрева контактов в °C';

-- Таблица общих технических характеристик соединителей
CREATE TABLE connector_technical_specs (
    spec_id SERIAL PRIMARY KEY,
    spec_name VARCHAR(100) NOT NULL,
    spec_value VARCHAR(100) NOT NULL,
    description TEXT
);
COMMENT ON TABLE connector_technical_specs IS 'Общие технические характеристики соединителей';
COMMENT ON COLUMN connector_technical_specs.spec_id IS 'Уникальный идентификатор характеристики';
COMMENT ON COLUMN connector_technical_specs.spec_name IS 'Наименование характеристики';
COMMENT ON COLUMN connector_technical_specs.spec_value IS 'Значение характеристики';
COMMENT ON COLUMN connector_technical_specs.description IS 'Дополнительное описание';

-- Таблица размеров проходных кожухов
CREATE TABLE shell_sizes (
    shell_size_id SERIAL PRIMARY KEY,
    diameter NUMERIC(5,1) NOT NULL UNIQUE,
    description TEXT
);
COMMENT ON TABLE shell_sizes IS 'Размеры проходных кожухов';
COMMENT ON COLUMN shell_sizes.shell_size_id IS 'Уникальный идентификатор размера';
COMMENT ON COLUMN shell_sizes.diameter IS 'Диаметр проходного кожуха в мм';
COMMENT ON COLUMN shell_sizes.description IS 'Описание размера'; 