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

# 4. LAG() and LEAD()

SELECT 
    EmployeeID, FirstName, LastName, Salary,
    LAG(Salary, 1, 0) OVER (ORDER BY Salary) AS LowerSalary,
    LEAD(Salary, 1, 0) OVER (ORDER BY Salary) AS HigherSalary
FROM Employees;

# Custom Frame Specifications ROWS BETWEEN
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    -- Moving average of the current row and the preceding row
    AVG(Salary) OVER (
        PARTITION BY Department 
        ORDER BY Salary 
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS MovingAvgSalary
FROM Employees;

# FIRST_VALUE() and LAST_VALUE()

SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    FIRST_VALUE(Salary) OVER (
        PARTITION BY Department 
        ORDER BY Salary DESC
    ) AS HighestDeptSalary,
    LAST_VALUE(Salary) OVER (
        PARTITION BY Department 
        ORDER BY Salary DESC 
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS LowestDeptSalary
FROM Employees;


# Statistical Distribution: PERCENT_RANK() and CUME_DIST()
/* PERCENT_RANK(): Calculates the relative rank of a row ($(\text{rank} - 1) / (\text{total rows} - 1)$).
CUME_DIST(): Calculates the cumulative distribution, representing the proportion of values less than or equal to the 
current value.
*/
SELECT 
    EmployeeID,
    FirstName,
    Salary,
    PERCENT_RANK() OVER (ORDER BY Salary) AS SalaryPercentRank,
    CUME_DIST() OVER (ORDER BY Salary) AS SalaryCumeDist
FROM Employees;

# NTILE() for Bucket Distribution
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    NTILE(2) OVER (ORDER BY Salary DESC) AS SalaryTier
FROM Employees;



