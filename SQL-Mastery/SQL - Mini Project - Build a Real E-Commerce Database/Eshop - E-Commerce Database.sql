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





