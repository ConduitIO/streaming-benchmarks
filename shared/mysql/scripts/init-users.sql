-- Create the database (if not exists)
CREATE DATABASE IF NOT EXISTS testdb;

-- Use the database
USE testdb;

-- Drop the table if it already exists
DROP TABLE IF EXISTS users;

-- Create the users table
CREATE TABLE users (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       username VARCHAR(50) NOT NULL,
                       email VARCHAR(100) UNIQUE NOT NULL,
                       first_name VARCHAR(50),
                       last_name VARCHAR(50)
);

