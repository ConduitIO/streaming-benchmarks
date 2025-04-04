SET SESSION cte_max_recursion_depth = 1000000;

INSERT INTO testdb.users (
    username, email, first_name, last_name, phone, street, city, state, zip_code, country,
    status, subscription_type, last_login, created_at, age, notifications, newsletter, theme,
    last_updated, device_type, browser
)
WITH RECURSIVE cte (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT
    CONCAT('user', n),
    CONCAT('user', n, '@example.com'),
    'John', 'Doe',
    CONCAT('+10000', FLOOR(RAND() * 99999)),
    CONCAT(FLOOR(RAND() * 999), ' Main St'),
    'New York', 'NY',
    LPAD(FLOOR(RAND() * 99999), 5, '0'),
    'USA',
    'active', 'premium',
    NOW(), NOW(),
    FLOOR(RAND() * 50) + 20,
    1, 0,
    'dark', NOW(),
    'desktop', 'Chrome'
FROM cte;