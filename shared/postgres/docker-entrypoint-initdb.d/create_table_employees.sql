DROP TABLE IF EXISTS employees;
DROP SEQUENCE IF EXISTS employees_id_seq;
CREATE TABLE employees (
    id int NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255),
    full_time BOOLEAN NOT NULL DEFAULT TRUE,
    position VARCHAR(100),
    hire_date DATE NOT NULL,
    salary REAL CHECK (salary >= 0),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id)
);
CREATE SEQUENCE employees_id_seq;
ALTER TABLE employees ALTER id SET DEFAULT NEXTVAL('employees_id_seq');
ALTER TABLE employees REPLICA IDENTITY FULL;
