\set total_records :TOTAL_RECORDS

-- Disable triggers and indices temporarily for faster inserts
ALTER TABLE employees DISABLE TRIGGER ALL;

INSERT INTO employees (name, email, full_time, position, hire_date, salary, updated_at, created_at)
SELECT 
    'John Doe', 
    'john.doe@example.com', 
    true, 
    'Software Engineer', 
    CURRENT_DATE, 
    60000.00, 
    NOW(), 
    NOW()
FROM generate_series(1, :total_records);

-- Re-enable triggers and indices
ALTER TABLE employees ENABLE TRIGGER ALL;
