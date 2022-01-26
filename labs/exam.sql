-- Zad 1.

USE library
SELECT j.member_no,
       m.firstname,
       m.lastname
FROM juvenile j
         INNER JOIN loanhist l on j.member_no = l.member_no
         INNER JOIN title t on l.title_no = t.title_no
         INNER JOIN member m on j.member_no = m.member_no
WHERE YEAR(l.in_date) = 2001
  AND MONTH(l.in_date) = 12
  AND DAY(l.in_date) = 14
  AND title = 'Walking'


-- Zad 2.

USE Northwind
SELECT DISTINCT P.ProductName  as 'product name',
                CompanyName    as 'company name',
                C.CategoryName as 'category name'
FROM PRODUCTS P
         INNER JOIN Categories C on P.CategoryID = C.CategoryID
         INNER JOIN [Order Details] on P.ProductID = [Order Details].ProductID
         INNER JOIN Orders O on [Order Details].OrderID = O.OrderID
         INNER JOIN Shippers S on O.ShipVia = S.ShipperID
WHERE OrderDate NOT BETWEEN '1997-02-20' AND '1997-02-25'
  AND CategoryName = 'Beverages'


-- Zad 3.

USE Northwind
SELECT [imie i naziwsko],
       SUM([ilosc zamowien])   as 'ilosc zamowien',
       SUM([wartosc zamowien]) as 'wartosc zamowien'
FROM (
         SELECT E.FirstName + ' ' + E.LastName                                      as 'imie i naziwsko',
                ISNULL(SUM((UnitPrice * Quantity * (1 - Discount))) + O.Freight, 0) as 'wartosc zamowien',
                COUNT(O.OrderID)                                                    as 'ilosc zamowien'
         FROM Employees E
                  LEFT JOIN Orders O
                            on E.EmployeeID = O.EmployeeID AND (YEAR(OrderDate) = 1997 AND MONTH(OrderDate) = 2)
                  LEFT JOIN [Order Details] OD on O.OrderID = OD.OrderID
         GROUP BY E.FirstName + ' ' + E.LastName, Freight) as main
GROUP BY [imie i naziwsko]