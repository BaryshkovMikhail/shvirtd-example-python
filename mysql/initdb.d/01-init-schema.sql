-- ./mysql/initdb.d/01-init-schema.sql
CREATE DATABASE IF NOT EXISTS virtd;

USE virtd;

CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_date DATETIME,
    request_ip VARCHAR(255)
);