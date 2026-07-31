create database company_db;

use company_db

# What are SQL ranking functions, and what is their basic syntax
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Insert table content (rows)
INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'Alice', 'Smith', 'Engineering', 85000.00),
(2, 'Bob', 'Jones', 'Marketing', 62000.00),
(3, 'Charlie', 'Brown', 'Engineering', 91000.00),
(4, 'Diana', 'Prince', 'HR', 55000.00);

