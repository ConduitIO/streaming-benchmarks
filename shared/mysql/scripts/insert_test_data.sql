SET SESSION cte_max_recursion_depth = 3000000;

INSERT INTO testdb.users (
    username, email, first_name, last_name
)
WITH RECURSIVE cte (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 3000000
)
SELECT
    CONCAT('user', n),
    CONCAT('user', n, '@example.com'),
    'John', 'Doe'
FROM cte;