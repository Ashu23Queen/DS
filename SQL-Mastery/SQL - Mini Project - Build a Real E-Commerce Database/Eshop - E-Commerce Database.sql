CREATE DATABASE EshopDatabase;

USE EshopDatabase;
 
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(255) NOT NULL UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    SignupDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    City VARCHAR(100)
);
  
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    OrderStatus VARCHAR(50) NOT NULL, -- e.g., 'Completed','Cancelled','Returned'
    TotalAmount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PaymentMethod VARCHAR(50),
    Amount DECIMAL(12,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);






----------------------- inserting data ---------------------------------

-- Categories
INSERT INTO Categories (CategoryName) VALUES ('Beverages'),('Snacks'),('Supplements'),('Accessories');

-- Products
INSERT INTO Products (ProductName, CategoryID, Price) VALUES
('Green Tea', 1, 199.00), ('Protein Bar', 2, 99.00), ('Whey Protein 1kg', 3, 2499.00),
('Shaker Bottle', 4, 299.00);

-- Customers
INSERT INTO Customers (Email, FirstName, LastName, SignupDate, City) VALUES
('alice@example.com','Alice','Roy','2024-10-05','Bengaluru'),
('bob@example.com','Bob','Kumar','2025-01-12','Chennai'),
('cara@example.com','Cara','Das','2024-11-20','Hyderabad');

-- Orders + OrderItems + Payments
INSERT INTO Orders (CustomerID, OrderDate, OrderStatus, TotalAmount)
VALUES (1, '2025-11-01 10:15', 'Completed', 298.00),
       (2, '2025-11-10 18:20', 'Completed', 2598.00),
       (1, '2025-11-15 09:00', 'Cancelled', 99.00);

-- OrderItems (info:- UnitPrice replicates Products.Price at time of sale)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 199.00), (1, 4, 1, 99.00),
(2, 3, 1, 2499.00), (2, 4, 1, 99.00),
(3, 2, 1, 99.00);

INSERT INTO Payments (OrderID, PaymentDate, PaymentMethod, Amount) VALUES
(1, '2025-11-01 10:20', 'Card', 298.00),
(2, '2025-11-10 18:25', 'UPI', 2598.00);


----------------------- quering ---------------------------------
 
SELECT COUNT(*) AS CustomersCount FROM Customers;
SELECT COUNT(*) AS OrdersCount FROM Orders;


SELECT o.OrderID, c.Email, o.TotalAmount
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC
LIMIT 10;

########################### quering ##############################################3

# How many customers and orders exist?
select count(*) As CustomersCount FROM Customers;
SELECT COUNT(*) AS OrdersCount FROM Orders;


################### Revenue by month ###############################3
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,
    SUM(TotalAmount) AS Revenue
FROM Orders
WHERE OrderStatus = 'Completed'
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY YearMonth;


################### Top 5 products by quantity sold  ##############################3
SELECT 
    p.ProductName, 
    SUM(oi.Quantity) AS TotalQuantitySold
FROM orderitems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQuantitySold DESC
LIMIT 5;

###############   How to check your exact table names     #################
SHOW TABLES FROM eshopdatabase;


#####################   Customer lifetime value ##########################
SELECT 
    c.CustomerID, 
    c.Email, 
    COALESCE(o_stats.OrdersCount, 0) AS OrdersCount,    # COALESCE evaluates arguments from left to right and returns the first non-null value it encounters.
    COALESCE(o_stats.TotalSpent, 0) AS TotalSpent       # If o_stats.TotalSpent is NULL (because the customer has no orders), COALESCE replaces it with 0.
FROM Customers c
LEFT JOIN (
    SELECT 
        CustomerID,
        COUNT(OrderID) AS OrdersCount,
        SUM(CASE WHEN OrderStatus = 'Completed' THEN TotalAmount ELSE 0 END) AS TotalSpent
    FROM Orders
    GROUP BY CustomerID
) o_stats ON c.CustomerID = o_stats.CustomerID
ORDER BY TotalSpent DESC;

###############################    Sales Revenue by Product Category   ###########################
SELECT 
    cat.CategoryName,
    SUM(oi.Quantity) AS TotalUnitsSold,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM OrderItems oi
JOIN Orders o ON oi.OrderID = o.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE o.OrderStatus = 'Completed'
GROUP BY cat.CategoryName
ORDER BY TotalRevenue DESC;


###########################   The True Order of Execution #######################3
/*

FROM / JOIN: The database gets the raw data from the tables.

WHERE: Filters out individual rows before any grouping happens.

GROUP BY: Collapses the remaining rows into summary groups.

HAVING: Filters the grouped summaries (works like a WHERE clause, but for aggregates).

SELECT: Extracts the specific columns/computations you requested.

ORDER BY: Sorts the final output.

*/

# Basic Filtering and Sorting 
# Find all active (Completed) orders that were large transactions (over ₹200), sorted from highest to lowest.

Select OrderId, CustomerId, TotalAmount
from Orders
where OrderStatus = 'Completed' AND TotalAmount > 200
order by TotalAmount DESC;



# Grouping Data
# Calculate the total revenue generated by each payment method

select PaymentMethod, SUM(Amount) AS TotalRevenue
FRom Payments
GROUP BY PaymentMethod;


# Combining Filtering, Grouping, and Sorting
/* Find out how many items were sold for each product, 
but only count items from orders that were successfully 'Completed'. 
Sort by the highest quantity sold
*/
SELECT ProductID, SUM(Quantity) AS TotalQtySold
FROM OrderItems
JOIN Orders ON OrderItems.OrderID = Orders.OrderID
WHERE Orders.OrderStatus = 'Completed'
GROUP BY ProductID
ORDER BY TotalQtySold DESC;

# Lifecycle (WHERE vs HAVING)
/* 
Identify "high-value cities" where customers have placed more than 1 completed order.
This query uses all five clauses so you can see the complete execution pipeline in action.
*/

 
SELECT City, COUNT(Orders.OrderID) AS CompletedOrderCount
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderStatus = 'Completed'
GROUP BY City
HAVING COUNT(Orders.OrderID) > 1
ORDER BY CompletedOrderCount DESC;



