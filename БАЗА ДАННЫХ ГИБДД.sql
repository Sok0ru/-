-- Создание базы данных ГИБДД
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS gibdd_fines 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE gibdd_fines;

SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;

-- 1. Таблица подразделений ГИБДД
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    head_name VARCHAR(100),
    UNIQUE KEY (department_name, address)
) COMMENT 'Подразделения ГИБДД';

-- 2. Таблица инспекторов
CREATE TABLE inspectors (
    inspector_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    ranked VARCHAR(50) NOT NULL COMMENT 'Звание',
    position VARCHAR(100) NOT NULL COMMENT 'Должность',
    department_id INT NOT NULL,
    badge_number VARCHAR(20) UNIQUE NOT NULL COMMENT 'Номер жетона',
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) COMMENT 'Инспекторы ГИБДД';

-- 3. Таблица типов транспортных средств
CREATE TABLE vehicle_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
) COMMENT 'Типы транспортных средств';

-- 4. Таблица водителей
CREATE TABLE drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    license_number VARCHAR(20) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20)
) COMMENT 'Водители';

-- 5. Таблица транспортных средств
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    license_plate VARCHAR(15) NOT NULL UNIQUE COMMENT 'Госномер',
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT,
    color VARCHAR(30),
    type_id INT,
    owner_id INT NOT NULL,
    FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id),
    FOREIGN KEY (owner_id) REFERENCES drivers(driver_id)
) COMMENT 'Транспортные средства';

-- 6. Таблица видов нарушений
CREATE TABLE violation_types (
    violation_type_id INT AUTO_INCREMENT PRIMARY KEY,
    violation_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    fine_amount DECIMAL(10, 2) NOT NULL,
    article_code VARCHAR(20) NOT NULL COMMENT 'Статья КоАП',
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_fine_amount CHECK (fine_amount > 0)
) COMMENT 'Виды нарушений ПДД';

-- 7. Таблица выписанных штрафов
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    violation_type_id INT NOT NULL,
    inspector_id INT NOT NULL,
    driver_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    violation_date DATETIME NOT NULL,
    issue_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(255) NOT NULL,
    status ENUM('issued', 'paid', 'cancelled', 'in_court') DEFAULT 'issued',
    payment_due_date DATE,
    actual_payment_date DATE,
    notes TEXT,
    FOREIGN KEY (violation_type_id) REFERENCES violation_types(violation_type_id),
    FOREIGN KEY (inspector_id) REFERENCES inspectors(inspector_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
) COMMENT 'Выписанные штрафы';

-- Создание индексов для ускорения запросов
CREATE INDEX idx_fines_inspector ON fines(inspector_id);
CREATE INDEX idx_fines_violation_type ON fines(violation_type_id);
CREATE INDEX idx_fines_driver ON fines(driver_id);
CREATE INDEX idx_fines_vehicle ON fines(vehicle_id);
CREATE INDEX idx_fines_status ON fines(status);
CREATE INDEX idx_fines_dates ON fines(violation_date, issue_date);

-- Заполнение справочных данных

-- Подразделения ГИБДД
INSERT INTO departments (department_name, address, phone, head_name) VALUES 
('ОГИБДД УМВД России по г. Москве', 'г. Москва, ул. Садовая-Самотечная, 1', '+74956205800', 'Иванов Иван Иванович'),
('ОГИБДД УМВД России по г. Санкт-Петербургу', 'г. Санкт-Петербург, ул. Профессора Попова, 37', '+78127303002', 'Петров Петр Петрович'),
('ОГИБДД УМВД России по Московской области', 'г. Красногорск, ул. Речная, 8', '+74955837060', 'Сидоров Сидор Сидорович');

-- Виды транспортных средств
INSERT INTO vehicle_types (type_name, description) VALUES 
('Легковой автомобиль', 'Автомобиль для перевозки пассажиров до 8 человек'),
('Грузовой автомобиль', 'Автомобиль для перевозки грузов'),
('Мотоцикл', 'Двухколесное транспортное средство'),
('Автобус', 'Автомобиль для перевозки пассажиров более 8 человек');

-- Инспекторы
INSERT INTO inspectors (last_name, first_name, middle_name, ranked, position, department_id, badge_number, hire_date) VALUES 
('Смирнов', 'Алексей', 'Владимирович', 'Капитан полиции', 'Старший инспектор ДПС', 1, 'МСК-1234', '2015-06-10'),
('Кузнецов', 'Дмитрий', 'Сергеевич', 'Старший лейтенант полиции', 'Инспектор ДПС', 1, 'МСК-5678', '2018-09-15'),
('Попова', 'Ольга', 'Игоревна', 'Лейтенант полиции', 'Инспектор по исполнению административного законодательства', 2, 'СПБ-9012', '2020-03-22');

-- Виды нарушений
INSERT INTO violation_types (violation_name, description, fine_amount, article_code) VALUES 
('Превышение скорости на 20-40 км/ч', 'Превышение установленной скорости движения на величину более 20, но не более 40 км/ч', 500.00, '12.9 ч.2'),
('Превышение скорости на 40-60 км/ч', 'Превышение установленной скорости движения на величину более 40, но не более 60 км/ч', 1000.00, '12.9 ч.3'),
('Проезд на запрещающий сигнал светофора', 'Проезд на запрещающий сигнал светофора или на запрещающий жест регулировщика', 1000.00, '12.12 ч.1'),
('Управление ТС без документов', 'Управление транспортным средством без документов, предусмотренных ПДД', 500.00, '12.3 ч.2'),
('Парковка в неположенном месте', 'Нарушение правил остановки или стоянки транспортных средств', 1500.00, '12.19 ч.1'),
('Вождение в нетрезвом виде', 'Управление транспортным средством в состоянии опьянения', 30000.00, '12.8 ч.1');

-- Водители
INSERT INTO drivers (last_name, first_name, middle_name, license_number, birth_date, address, phone) VALUES 
('Васильев', 'Андрей', 'Николаевич', '77АВ123456', '1985-07-15', 'г. Москва, ул. Ленина, 15, кв. 42', '+79161234567'),
('Николаева', 'Елена', 'Владимировна', '78ВС654321', '1990-11-22', 'г. Санкт-Петербург, пр. Просвещения, 33, кв. 12', '+79119876543'),
('Федоров', 'Сергей', 'Александрович', '50КМ789012', '1978-03-30', 'Московская обл., г. Химки, ул. Московская, 8', '+79035554433');

-- Транспортные средства
INSERT INTO vehicles (license_plate, make, model, year, color, type_id, owner_id) VALUES 
('А123БВ77', 'Toyota', 'Camry', 2018, 'Серебристый', 1, 1),
('В456СЕ78', 'Volkswagen', 'Polo', 2020, 'Красный', 1, 2),
('Е789КМ50', 'KAMAZ', '6520', 2015, 'Синий', 2, 3);

-- Выписанные штрафы
INSERT INTO fines (violation_type_id, inspector_id, driver_id, vehicle_id, violation_date, issue_date, location, status, payment_due_date) VALUES 
(1, 1, 1, 1, '2023-01-15 14:30:00', '2023-01-15 14:35:00', 'г. Москва, Ленинский пр-т, д. 42', 'paid', '2023-02-15'),
(2, 1, 2, 2, '2023-02-20 09:15:00', '2023-02-20 09:20:00', 'г. Москва, ул. Тверская, д. 10', 'issued', '2023-03-20'),
(3, 2, 3, 3, '2023-03-10 16:45:00', '2023-03-10 16:50:00', 'г. Москва, Садовое кольцо', 'paid', '2023-04-10'),
(4, 3, 1, 1, '2023-04-05 11:20:00', '2023-04-05 11:25:00', 'г. Санкт-Петербург, Невский пр-т', 'in_court', '2023-05-05'),
(5, 1, 2, 2, '2023-05-12 18:30:00', '2023-05-12 18:35:00', 'г. Москва, ул. Арбат', 'issued', '2023-06-12'),
(6, 2, 3, 3, '2023-06-18 22:10:00', '2023-06-18 22:15:00', 'Московская обл., г. Красногорск', 'cancelled', '2023-07-18');

-- Представления для часто используемых запросов

-- 1. Штрафы по инспекторам
CREATE VIEW inspector_fines AS
SELECT 
    i.inspector_id,
    CONCAT(i.last_name, ' ', i.first_name, ' ', COALESCE(i.middle_name, '')) AS inspector_name,
    i.ranked,
    d.department_name,
    COUNT(f.fine_id) AS fines_count,
    SUM(vt.fine_amount) AS total_fines_amount
FROM inspectors i
JOIN departments d ON i.department_id = d.department_id
LEFT JOIN fines f ON i.inspector_id = f.inspector_id
LEFT JOIN violation_types vt ON f.violation_type_id = vt.violation_type_id
GROUP BY i.inspector_id;

-- 2. Анализ штрафов по видам нарушений
CREATE VIEW violation_type_stats AS
SELECT 
    vt.violation_type_id,
    vt.violation_name,
    vt.article_code,
    vt.fine_amount,
    COUNT(f.fine_id) AS violations_count,
    COUNT(f.fine_id) * vt.fine_amount AS total_fines_amount,
    ROUND(COUNT(f.fine_id) * 100.0 / (SELECT COUNT(*) FROM fines), 2) AS percentage
FROM violation_types vt
LEFT JOIN fines f ON vt.violation_type_id = f.violation_type_id
GROUP BY vt.violation_type_id;

-- 3. Штрафы выше заданной суммы
CREATE VIEW high_amount_fines AS
SELECT 
    f.fine_id,
    vt.violation_name,
    vt.fine_amount,
    f.violation_date,
    f.location,
    CONCAT(d.last_name, ' ', d.first_name, ' ', COALESCE(d.middle_name, '')) AS driver_name,
    v.license_plate,
    CONCAT(i.last_name, ' ', i.first_name, ' ', COALESCE(i.middle_name, '')) AS inspector_name
FROM fines f
JOIN violation_types vt ON f.violation_type_id = vt.violation_type_id
JOIN drivers d ON f.driver_id = d.driver_id
JOIN vehicles v ON f.vehicle_id = v.vehicle_id
JOIN inspectors i ON f.inspector_id = i.inspector_id
WHERE vt.fine_amount > 1000 -- Заданная минимальная сумма штрафа
ORDER BY vt.fine_amount DESC;

-- Хранимые процедуры для выполнения требований ТЗ

-- 1. Штрафы, выписанные конкретным инспектором
DELIMITER //
CREATE PROCEDURE get_fines_by_inspector(IN p_inspector_id INT)
BEGIN
    SELECT 
        f.fine_id,
        vt.violation_name,
        vt.fine_amount,
        f.violation_date,
        f.location,
        CONCAT(d.last_name, ' ', d.first_name, ' ', COALESCE(d.middle_name, '')) AS driver_name,
        v.license_plate,
        f.status
    FROM fines f
    JOIN violation_types vt ON f.violation_type_id = vt.violation_type_id
    JOIN drivers d ON f.driver_id = d.driver_id
    JOIN vehicles v ON f.vehicle_id = v.vehicle_id
    WHERE f.inspector_id = p_inspector_id
    ORDER BY f.violation_date DESC;
END //
DELIMITER ;

-- 2. Анализ штрафов по видам нарушений с фильтрами
DELIMITER //
CREATE PROCEDURE analyze_violations(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_min_fine_amount DECIMAL(10, 2)
)
BEGIN
    SELECT 
        vt.violation_name,
        vt.article_code,
        vt.fine_amount,
        COUNT(f.fine_id) AS violations_count,
        SUM(vt.fine_amount) AS total_fines_amount
    FROM violation_types vt
    LEFT JOIN fines f ON vt.violation_type_id = f.violation_type_id
        AND (p_start_date IS NULL OR DATE(f.violation_date) >= p_start_date)
        AND (p_end_date IS NULL OR DATE(f.violation_date) <= p_end_date)
    WHERE vt.fine_amount >= p_min_fine_amount
    GROUP BY vt.violation_type_id
    ORDER BY violations_count DESC;
END //
DELIMITER ;

-- 3. Статистика по штрафам выше заданной суммы
DELIMITER //
CREATE PROCEDURE get_high_amount_fines_stats(IN p_min_amount DECIMAL(10, 2))
BEGIN
    SELECT 
        COUNT(f.fine_id) AS fines_count,
        SUM(vt.fine_amount) AS total_amount,
        AVG(vt.fine_amount) AS average_fine,
        MAX(vt.fine_amount) AS max_fine,
        MIN(vt.fine_amount) AS min_fine
    FROM fines f
    JOIN violation_types vt ON f.violation_type_id = vt.violation_type_id
    WHERE vt.fine_amount >= p_min_amount;
END //
DELIMITER ;

-- Триггер для логирования изменений статуса штрафа
CREATE TABLE fine_status_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    fine_id INT NOT NULL,
    old_status ENUM('issued', 'paid', 'cancelled', 'in_court'),
    new_status ENUM('issued', 'paid', 'cancelled', 'in_court'),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) COMMENT 'Пользователь или система, изменившая статус',
    FOREIGN KEY (fine_id) REFERENCES fines(fine_id)
) COMMENT 'Лог изменений статуса штрафов';

DELIMITER //
CREATE TRIGGER log_fine_status_change
BEFORE UPDATE ON fines
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO fine_status_log (fine_id, old_status, new_status, changed_by)
        VALUES (NEW.fine_id, OLD.status, NEW.status, CURRENT_USER());
    END IF;
END //
DELIMITER ;

-- Создание пользователей с разными правами доступа
CREATE USER 'gibdd_operator'@'localhost' IDENTIFIED BY 'operator_pass123';
GRANT SELECT, INSERT, UPDATE ON gibdd_fines.* TO 'gibdd_operator'@'localhost';

CREATE USER 'gibdd_analyst'@'localhost' IDENTIFIED BY 'analyst_pass456';
GRANT SELECT ON gibdd_fines.* TO 'gibdd_analyst'@'localhost';
GRANT EXECUTE ON PROCEDURE gibdd_fines.analyze_violations TO 'gibdd_analyst'@'localhost';
GRANT EXECUTE ON PROCEDURE gibdd_fines.get_high_amount_fines_stats TO 'gibdd_analyst'@'localhost';

CREATE USER 'gibdd_admin'@'localhost' IDENTIFIED BY 'admin_pass789';
GRANT ALL PRIVILEGES ON gibdd_fines.* TO 'gibdd_admin'@'localhost';

FLUSH PRIVILEGES;

-- Сообщение об успешном завершении
SELECT 'База данных ГИБДД для учета штрафов успешно создана и заполнена тестовыми данными' AS message;
