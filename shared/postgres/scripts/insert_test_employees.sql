-- For parameterization
\set total_records :TOTAL_RECORDS

-- Set higher work_mem for better performance
SET work_mem = '1GB';  -- Adjust based on your system

-- Disable triggers and indices temporarily for faster inserts
ALTER TABLE employees DISABLE TRIGGER ALL;

-- The actual insert
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
