CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER '${MYSQL_INIT_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_INIT_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_INIT_USER}'@'%';
FLUSH PRIVILEGES;
USE ${MYSQL_DATABASE};

-- 테이블 생성 예시
/* CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); */

-- 초기 데이터 삽입 예시
--INSERT INTO users (username, password, email) VALUES ('admin', 'adminpassword', 'admin@example.com');