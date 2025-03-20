-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(255) UNIQUE NOT NULL
);

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

-- Salaries table
CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- Departments 
INSERT INTO departments (department_name) VALUES 
('HR'), 
('IT'), 
('Finance'), 
('Marketing'),
('Sales'),
('Customer Support'),
('Operations'),
('Legal');

-- Employees
INSERT INTO employees (first_name, last_name, department_id) VALUES
-- HR 
('Alice', 'Smith', 1),
('George', 'Anderson', 1),
('Mia', 'Rodriguez', 1),
('Ethan', 'Harris', 1),
('Sophia', 'King', 1),

-- IT 
('Bob', 'Johnson', 2),
('Charlie', 'Brown', 2),
('Hannah', 'Martinez', 2),
('Noah', 'Lewis', 2),
('Liam', 'Clark', 2),
('Emma', 'Davis', 2),
('Olivia', 'Taylor', 2),
('Lucas', 'Baker', 2),
('Ava', 'Evans', 2),
('William', 'Nelson', 2),

-- Finance 
('David', 'Williams', 3),
('Isaac', 'Thomas', 3),
('Jack', 'White', 3),
('Grace', 'Robinson', 3),
('Daniel', 'Scott', 3),
('Victoria', 'Lopez', 3),

-- Marketing 
('Frank', 'Miller', 4),
('Karen', 'Lopez', 4),
('Henry', 'Wright', 4),
('Zoe', 'Allen', 4),
('Elijah', 'Parker', 4),
('Charlotte', 'Adams', 4),

-- Sales 
('Samuel', 'Gonzalez', 5),
('Eleanor', 'Carter', 5),
('Jacob', 'Mitchell', 5),
('Michael', 'Perez', 5),
('Scarlett', 'Turner', 5),
('Benjamin', 'Phillips', 5),
('Madison', 'Campbell', 5),
('Daniel', 'Stewart', 5),

-- Customer Support
('Evelyn', 'Edwards', 6),
('Anthony', 'Collins', 6),
('Andrew', 'Morris', 6),
('Sofia', 'Reed', 6),
('Thomas', 'Ward', 6),
('Mila', 'Peterson', 6),

-- Operations 
('Joshua', 'Howard', 7),
('Penelope', 'Ross', 7),
('Matthew', 'Cox', 7),
('Aria', 'Diaz', 7),
('Nathan', 'Sanchez', 7),
('Sebastian', 'Russell', 7),

-- Legal 
('Nicholas', 'Bell', 8),
('Emily', 'Hayes', 8),
('Joseph', 'Perry', 8),
('Addison', 'Wood', 8),
('Ryan', 'Brooks', 8),
('Aubrey', 'Bennett', 8);

-- Salaries 
INSERT INTO salaries (employee_id, salary) VALUES
(1, 50000),
(2, 55000),
(3, 52000),
(4, 58000),
(5, 60000),
(6, 70000),
(7, 80000),
(8, 75000),
(9, 72000),
(10, 67000),
(11, 85000),
(12, 88000),
(13, 90000),
(14, 92000),
(15, 94000),
(16, 62000),
(17, 65000),
(18, 68000),
(19, 70000),
(20, 73000),
(21, 76000),
(22, 78000),
(23, 81000),
(24, 83000),
(25, 86000),
(26, 89000),
(27, 91000),
(28, 93000),
(29, 95000),
(30, 98000),
(31, 99000),
(32, 102000),
(33, 104000),
(34, 105000),
(35, 107000),
(36, 109000),
(37, 111000),
(38, 113000),
(39, 115000),
(40, 117000),
(41, 119000),
(42, 121000),
(43, 123000),
(44, 125000),
(45, 127000),
(46, 129000),
(47, 131000),
(48, 133000),
(49, 91000),
(50, 137000),
(51, 139000),
(52, 141000),
(53, 143000),
(54, 145000),
(55, 147000),
(56, 149000),
(57, 151000),
(58, 153000),
(59, 155000),
(60, 91000),
(61, 159000),
(62, 161000),
(63, 163000),
(64, 165000),
(65, 167000),
(66, 169000),
(67, 171000),
(68, 173000),
(69, 175000),
(70, 177000),
(71, 179000),
(72, 181000),
(73, 183000),
(74, 185000),
(75, 187000),
(76, 189000);