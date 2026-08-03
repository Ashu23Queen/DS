create database company_db;

use company_db

# SQL ranking functions
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

# 1. ROW_NUMBER()

SELECT 
    EmployeeID, FirstName, LastName, Department, Salary,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank
FROM Employees;


# 2. RANK() and DENSE_RANK()
/* Useful when you want to handle ties. RANK leaves gaps in ranking numbers if there's a tie, 
whereas DENSE_RANK does not.
*/
SELECT 
    EmployeeID, FirstName, LastName, Department, Salary,
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryDenseRank
FROM Employees;


# 3. SUM()
SELECT 
    EmployeeID, FirstName, LastName, Department, Salary,
    SUM(Salary) OVER (PARTITION BY Department) AS TotalDepartmentSalary,
    SUM(Salary) OVER (ORDER BY Salary) AS RunningTotalSalary
FROM Employees;






