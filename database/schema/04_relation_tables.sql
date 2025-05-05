-- Таблицы связей и таблица соединителей

-- Главная таблица соединителей
CREATE TABLE connectors (
    connector_id SERIAL PRIMARY KEY,
    gost VARCHAR(50) NOT NULL, -- ГОСТ или ТУ соединителя
    type_id INTEGER NOT NULL REFERENCES connector_types(type_id),
    size_id INTEGER NOT NULL REFERENCES body_sizes(size_id),
    body_type_id INTEGER NOT NULL REFERENCES body_types(body_type_id),
    nozzle_type_id INTEGER REFERENCES nozzle_types(nozzle_type_id),
    nut_type_id INTEGER REFERENCES nut_types(nut_type_id),
    quantity_id INTEGER NOT NULL REFERENCES contact_quantities(quantity_id),
    part_id INTEGER NOT NULL REFERENCES connector_parts(part_id),
    combination_id INTEGER NOT NULL REFERENCES contact_combinations(combination_id),
    coating_id INTEGER NOT NULL REFERENCES contact_coatings(coating_id),
    resistance_id INTEGER NOT NULL REFERENCES heat_resistance(resistance_id),
    special_design_id INTEGER REFERENCES special_designs(special_design_id),
    climate_id INTEGER NOT NULL REFERENCES climate_designs(climate_id),
    connection_type_id INTEGER NOT NULL REFERENCES connection_types(connection_type_id),
    full_code VARCHAR(50) NOT NULL UNIQUE, -- Полный код соединителя, например 2РМТ18Б4Г1В1В
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE connectors IS 'Основная таблица соединителей';

-- Таблица для хранения опций дизайна соединителя (например, возможность установки проходного кожуха)
CREATE TABLE connector_design_options (
    option_id SERIAL PRIMARY KEY,
    connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    shell_size_id INTEGER REFERENCES shell_sizes(shell_size_id),
    option_name VARCHAR(100) NOT NULL,
    option_value TEXT,
    description TEXT
);
COMMENT ON TABLE connector_design_options IS 'Опции дизайна соединителя';

-- Таблица для хранения совместимых соединителей
CREATE TABLE compatible_connectors (
    compatibility_id SERIAL PRIMARY KEY,
    connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    compatible_connector_id INTEGER NOT NULL REFERENCES connectors(connector_id),
    description TEXT,
    UNIQUE (connector_id, compatible_connector_id)
);
COMMENT ON TABLE compatible_connectors IS 'Совместимые соединители';

-- Таблица для хранения документации по соединителям
CREATE TABLE connector_documentation (
    doc_id SERIAL PRIMARY KEY,
    connector_id INTEGER REFERENCES connectors(connector_id),
    type_id INTEGER REFERENCES connector_types(type_id),
    doc_name VARCHAR(100) NOT NULL,
    doc_path VARCHAR(255),
    description TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE connector_documentation IS 'Документация по соединителям';

-- Триггер для автоматического обновления updated_at при изменении записи соединителя
CREATE OR REPLACE FUNCTION update_connector_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_connector_timestamp
BEFORE UPDATE ON connectors
FOR EACH ROW
EXECUTE FUNCTION update_connector_timestamp(); 