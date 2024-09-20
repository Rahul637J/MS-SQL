/*
@Author: Rahul 
@Date: 2024-09-18
@Last Modified by: Rahul
@Last Modified: 2024-09-18
@Title : Implemented the joins operation
*/


create database Employee_data_operation;

use Employee_data_operation;

-- Creating the tables 
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);


CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,
    Salary DECIMAL(10, 2),
    HireDate DATE,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Bonus (
    BonusID INT PRIMARY KEY,
    EmployeeID INT,
    BonusAmount DECIMAL(10, 2),
    BonusDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);



-- Inserting into the tables
INSERT INTO Department (DepartmentID, DepartmentName) VALUES
(1, 'Human Resources'),
(2, 'Finance'),
(3, 'Engineering'),
(4, 'Marketing');


INSERT INTO Employee (EmployeeID, FirstName, LastName, DepartmentID, Salary, HireDate) VALUES
(1, 'John', 'Doe', 3, 75000, '2020-01-15'),
(2, 'Jane', 'Smith', 2, 65000, '2019-03-22'),
(3, 'David', 'Jones', 3, 85000, '2021-05-12'),
(4, 'Emily', 'Davis', 1, 50000, '2020-07-09'),
(5, 'Michael', 'Brown', 4, 60000, '2018-10-03');


INSERT INTO Bonus (BonusID, EmployeeID, BonusAmount, BonusDate) VALUES
(1, 1, 5000, '2021-12-15'),
(2, 2, 4000, '2021-11-20'),
(3, 3, 6000, '2021-12-05');

--INNER JOIN
SELECT e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName
FROM Employee e
JOIN Department d ON e.DepartmentID = d.DepartmentID;

SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    d.DepartmentName, 
    b.BonusAmount, 
    b.BonusDate
FROM 
    Employee e
INNER JOIN 
    Department d ON e.DepartmentID = d.DepartmentID
INNER JOIN 
    Bonus b ON e.EmployeeID = b.EmployeeID;



--LEFT JOIN

SELECT e.EmployeeID, e.FirstName, e.LastName, b.BonusAmount
FROM Employee e
LEFT JOIN Bonus b ON e.EmployeeID = b.EmployeeID;

SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    d.DepartmentName, 
    b.BonusAmount, 
    b.BonusDate
FROM 
    Employee e
LEFT JOIN 
    Department d ON e.DepartmentID = d.DepartmentID
LEFT JOIN 
    Bonus b ON e.EmployeeID = b.EmployeeID;




--RIGHT JOIN
SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    d.DepartmentName
FROM 
    Employee e
RIGHT JOIN 
    Department d ON e.DepartmentID = d.DepartmentID;


SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    b.BonusAmount, 
    b.BonusDate
FROM 
    Employee e
RIGHT JOIN 
    Bonus b ON e.EmployeeID = b.EmployeeID;



--FULL OUTER JOIN
SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    d.DepartmentName
FROM 
    Employee e
FULL OUTER JOIN 
    Department d ON e.DepartmentID = d.DepartmentID;


SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    b.BonusAmount, 
    b.BonusDate
FROM 
    Employee e
FULL OUTER JOIN 
    Bonus b ON e.EmployeeID = b.EmployeeID;



--CARTESION JOIN
SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    d.DepartmentID, 
    d.DepartmentName
FROM 
    Employee e
CROSS JOIN 
    Department d;


SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    b.BonusID, 
    b.BonusAmount, 
    b.BonusDate
FROM 
    Employee e
CROSS JOIN 
    Bonus b;





--SELF JOIN
SELECT 
    e1.EmployeeID AS Employee1_ID, 
    e1.FirstName AS Employee1_Name, 
    e2.EmployeeID AS Employee2_ID, 
    e2.FirstName AS Employee2_Name, 
    e1.DepartmentID
FROM 
    Employee e1
INNER JOIN 
    Employee e2 
ON 
    e1.DepartmentID = e2.DepartmentID 
    AND e1.EmployeeID <> e2.EmployeeID;




SELECT 
    e1.EmployeeID AS Employee1_ID, 
    e1.FirstName AS Employee1_Name, 
    e2.EmployeeID AS Employee2_ID, 
    e2.FirstName AS Employee2_Name, 
    e1.Salary AS Employee1_Salary, 
    e2.Salary AS Employee2_Salary
FROM 
    Employee e1
INNER JOIN 
    Employee e2 
ON 
    e1.DepartmentID = e2.DepartmentID 
    AND e1.Salary > e2.Salary;











