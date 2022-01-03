USE library;


-- 1. Wypisz wszystkich członków biblioteki z adresami i info czy jest dzieckiem czy nie i
-- ilość wypożyczeń w poszczególnych latach i miesiącach.

SELECT firstname + ' ' + lastname                                                            as 'name',
       ISNULL((SELECT TOP 1 'n' FROM juvenile j WHERE m.member_no = j.adult_member_no), 'y') as 'is kid',
       MONTH(out_date)                                                                       as 'month',
       YEAR(out_date)                                                                        as 'year',
       COUNT(l.title_no)                                                                     as 'cnt',
       m.member_no
FROM member m
         INNER JOIN loanhist l on m.member_no = l.member_no
GROUP BY m.member_no, firstname + ' ' + lastname, MONTH(out_date), YEAR(out_date)


USE Northwind

-- 2. Zamówienia z Freight większym niż AVG danego roku.

SELECT OrderID,
       Freight,
       (SELECT AVG(Freight)
        FROM Orders o2
        WHERE Year(o2.OrderDate) = YEAR(o.OrderDate)) as 'avg',
       YEAR(OrderDate)                                as 'year'
FROM Orders o
WHERE (SELECT AVG(Freight)
       FROM Orders o2
       WHERE Year(o2.OrderDate) = YEAR(o.OrderDate)) < o.Freight


-- 3. Klienci, którzy nie zamówili nigdy nic z kategorii 'Seafood' w trzech wersjach.
USE Northwind
SELECT CustomerID
FROM CUSTOMERS
WHERE CustomerID NOT IN (SELECT C.CustomerID
                         FROM Customers C
                                  LEFT JOIN Orders O on C.CustomerID = O.CustomerID
                                  LEFT JOIN [Order Details] OD on O.OrderID = OD.OrderID
                                  LEFT JOIN Products P on OD.ProductID = P.ProductID
                                  LEFT JOIN Categories C2 on P.CategoryID = C2.CategoryID
                         WHERE C2.CategoryName = 'Seafood')


SELECT CustomerID
FROM Customers Ci
WHERE NOT EXISTS(SELECT C.CustomerID
                 FROM Customers C
                          LEFT JOIN Orders O on C.CustomerID = O.CustomerID
                          LEFT JOIN [Order Details] OD on O.OrderID = OD.OrderID
                          LEFT JOIN Products P on OD.ProductID = P.ProductID
                          LEFT JOIN Categories C2 on P.CategoryID = C2.CategoryID
                 WHERE C2.CategoryName = 'Seafood'
                   AND Ci.CustomerID = C.CustomerID)


-- 4. Dla każdego klienta najczęściej zamawianą kategorię w dwóch wersjach.
USE Northwind
SELECT CI.CustomerID,
       (SELECT TOP 1 C2.CategoryName
        FROM Customers C
                 LEFT JOIN Orders O on C.CustomerID = O.CustomerID
                 LEFT JOIN [Order Details] OD on O.OrderID = OD.OrderID
                 LEFT JOIN Products P on OD.ProductID = P.ProductID
                 LEFT JOIN Categories C2 on P.CategoryID = C2.CategoryID
        WHERE C.CustomerID = CI.CustomerID
        GROUP BY C.CustomerID, C2.CategoryName
        ORDER BY COUNT(P.CategoryID) DESC) as 'best_category'
FROM Customers CI


-- 1. Podział na company, year month i suma freight


SELECT S.CompanyName,
       MONTH(OrderDate),
       YEAR(OrderDate),
       SUM(Freight)
FROM Shippers S
         LEFT JOIN Orders O on S.ShipperID = O.ShipVia
GROUP BY S.CompanyName,
         MONTH(OrderDate),
         YEAR(OrderDate)

-- 2. Wypisać wszystkich czytelników, którzy nigdy nie wypożyczyli książki dane
-- adresowe i podział czy ta osoba jest dzieckiem (joiny, in, exists)

USE library

SELECT DISTINCT m.firstname,
                m.lastname,
                m.member_no,
                ISNULL((SELECT 0 FROM adult a WHERE m.member_no = a.member_no), 1) as 'kid',
                (SELECT street
                 FROM juvenile j
                          INNER JOIN member mi2 on j.member_no = mi2.member_no
                          INNER JOIN adult a on a.member_no = j.adult_member_no
                 WHERE j.member_no = m.member_no
                 UNION
                 SELECT street
                 FROM member mi
                          INNER JOIN adult a on a.member_no = mi.member_no
                 WHERE mi.member_no = m.member_no)                                 as 'address'

FROM member m
WHERE m.member_no NOT IN (SELECT l.member_no FROM loanhist l)

SELECT *
FROM loanhist
WHERE member_no = 2
-- adresy wszystkich memberow w LIBRARY
SELECT street
FROM juvenile j
         INNER JOIN member mi2 on j.member_no = mi2.member_no
         INNER JOIN adult a on a.member_no = j.adult_member_no
WHERE j.member_no = 13
UNION
SELECT street
FROM member mi1
         INNER JOIN adult a on a.member_no = mi1.member_no
WHERE mi1.member_no = 13


-- 3. Najczęściej wybierana kategoria w 1997 dla każdego klienta

USE Northwind;


SELECT CI.CustomerID,
       (SELECT TOP 1 C2.CategoryName
        FROM Customers C
                 LEFT JOIN Orders O on C.CustomerID = O.CustomerID
                 LEFT JOIN [Order Details] OD on O.OrderID = OD.OrderID
                 LEFT JOIN Products P on OD.ProductID = P.ProductID
                 LEFT JOIN Categories C2 on P.CategoryID = C2.CategoryID
        WHERE C.CustomerID = CI.CustomerID
          AND YEAR(O.OrderDate) = 1997
        GROUP BY C.CustomerID, C2.CategoryName
        ORDER BY COUNT(P.CategoryID) DESC)
FROM Customers CI


-- 4. Dla każdego czytelnika imię nazwisko, suma książek wypożyczony przez tą osobę i
-- jej dzieci, który żyje w Arizona ma mieć więcej niż 2 dzieci lub kto żyje w Kalifornii
-- ma mieć więcej niż 3 dzieci

USE library

SELECT a.member_no,
       firstname,
       lastname,
       (SELECT COUNT(*) FROM loanhist l WHERE l.member_no = a.member_no) as 'books_parent',
       (SELECT COUNT(*)
        FROM juvenile j
                 INNER JOIN loanhist l2 on j.member_no = l2.member_no
        WHERE j.adult_member_no = a.member_no)                           as 'books_kids'
FROM adult a
         LEFT JOIN member m on a.member_no = m.member_no
WHERE (a.state = 'AZ' AND (SELECT COUNT(*) from juvenile j2 WHERE j2.adult_member_no = a.member_no) > 2)
   OR (a.state = 'CA' AND (SELECT COUNT(*) from juvenile j2 WHERE j2.adult_member_no = a.member_no) > 3)


-- 1. Jaki był najpopularniejszy autor wśród dzieci w Arizonie w 2001

SELECT TOP 1 author
FROM juvenile j
         INNER JOIN loanhist l on j.member_no = l.member_no
         INNER JOIN title t on l.title_no = t.title_no
WHERE YEAR(l.out_date) = 2001
GROUP BY author
ORDER BY COUNT(author) DESC;


-- 2. Dla każdego dziecka wybierz jego imię nazwisko, adres, imię i nazwisko rodzica i
-- ilość książek, które oboje przeczytali w 2001


SELECT m.firstname,
       m.lastname,
       (SELECT street + '' + state
        FROM adult
                 INNER JOIN juvenile j2 on adult.member_no = j2.adult_member_no
        WHERE j2.member_no = j.member_no)                                                               address,
       (SELECT firstname FROM member WHERE j.adult_member_no = member.member_no)                        parent,
       (SELECT lastname FROM member WHERE j.adult_member_no = member.member_no)                         parent2,
       (SELECT COUNT(*) FROM loanhist l WHERE l.member_no = j.member_no AND YEAR(in_date) = 2001) +
       (SELECT COUNT(*) FROM loanhist l where l.member_no = j.adult_member_no AND YEAR(in_date) = 2001) books
FROM juvenile j
         INNER JOIN member m on j.member_no = m.member_no


-- 3. Kategorie które w roku 1997 grudzień były obsłużone wyłącznie przez ‘United
-- Package’

USE Northwind

SELECT DISTINCT CategoryName
FROM Categories
         INNER JOIN Products P on Categories.CategoryID = P.CategoryID
         INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
         INNER JOIN Orders O on [O D].OrderID = O.OrderID
         INNER JOIN Shippers S2 on O.ShipVia = S2.ShipperID
WHERE S2.CompanyName = 'United Package'
  AND YEAR(ShippedDate) = 1997


-- 4. Wybierz klientów, którzy kupili przedmioty wyłącznie z jednej kategorii w marcu
-- 1997 i wypisz nazwę tej kategorii


SELECT C.CustomerID,
       (SELECT COUNT(DISTINCT C2.CategoryID)
        FROM Categories C2
                 INNER JOIN Products P on C2.CategoryID = P.CategoryID
                 INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
                 INNER JOIN Orders O on [O D].OrderID = O.OrderID
        WHERE C.CustomerID = O.CustomerID
          AND (YEAR(OrderDate) = 1997 AND MONTH(OrderDate) = 3)),
       (SELECT TOP 1 C2.CategoryName
        FROM Categories C2
                 INNER JOIN Products P on C2.CategoryID = P.CategoryID
                 INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
                 INNER JOIN Orders O on [O D].OrderID = O.OrderID
        WHERE C.CustomerID = O.CustomerID
          AND (YEAR(OrderDate) = 1997 AND MONTH(OrderDate) = 3))
FROM Customers C
WHERE (SELECT COUNT(DISTINCT C2.CategoryID)
       FROM Categories C2
                INNER JOIN Products P on C2.CategoryID = P.CategoryID
                INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
                INNER JOIN Orders O on [O D].OrderID = O.OrderID
       WHERE C.CustomerID = O.CustomerID
         AND (YEAR(OrderDate) = 1997 AND MONTH(OrderDate) = 3)) = 1

-- 1. Wybierz dzieci wraz z adresem, które nie wypożyczyły książek w lipcu 2001
-- autorstwa ‘Jane Austin

USE library


SELECT DISTINCT j.member_no, street, firstname, lastname
FROM juvenile j
         INNER JOIN adult a on j.adult_member_no = a.member_no
         INNER JOIN member m on m.member_no = j.member_no
         INNER JOIN loanhist l on j.member_no = l.member_no
WHERE j.member_no NOT IN (SELECT member_no
                          FROM loanhist
                                   INNER JOIN title t on t.title_no = loanhist.title_no
                          WHERE YEAR(out_date) = 2001
                            AND MONTH(out_date) = 7
                            AND author = 'Jane Austin')


-- 2. Wybierz kategorię, która w danym roku 1997 najwięcej zarobiła, podział na miesiące

USE Northwind


SELECT CategoryName,
       MONTH(OrderDate) month,
       SUM(Quantity * [O D].UnitPrice * (1 - Discount))
FROM Categories
         INNER JOIN Products P on Categories.CategoryID = P.CategoryID
         INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
         INNER JOIN Orders O on [O D].OrderID = O.OrderID
WHERE YEAR(OrderDate) = 1997
GROUP BY CategoryName, MONTH(OrderDate)
ORDER BY 1 DESC;



-- 3. Dane pracownika i najczęstszy dostawca pracowników bez podwładnych

--bez podwladnych
SELECT EmployeeID
FROM Employees E
WHERE NOT EXISTS(SELECT E2.EmployeeID FROM Employees E2 WHERE E2.Reportsto = E.EmployeeID)

--z podwladnymi
SELECT EmployeeID
FROM Employees E
WHERE EXISTS(SELECT E2.EmployeeID FROM Employees E2 WHERE E2.Reportsto = E.EmployeeID)


SELECT DISTINCT E.EmployeeID,
                (SELECT TOP 1 Shippers.CompanyName
                 FROM Orders
                          INNER JOIN Employees E3 on Orders.EmployeeID = E3.EmployeeID
                          INNER JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
                 WHERE E3.EmployeeID = E.EmployeeID
                 GROUP BY Shippers.CompanyName
                 ORDER BY COUNT(ShipVia) DESC) BestShipper
FROM Employees E
         INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
WHERE NOT EXISTS(SELECT E2.EmployeeID FROM Employees E2 WHERE E2.Reportsto = E.EmployeeID)
GROUP BY E.EmployeeID, ShipVia


-- 4. Wybierz tytuły książek, gdzie ilość wypożyczeń książki jest większa od średniej ilości
-- wypożyczeń książek tego samego autora.


USE library


SELECT title,
       (SELECT COUNT(*) FROM loanhist l2 WHERE l2.title_no = t.title_no),
       (SELECT AVG(cnt)
        FROM (
                 SELECT COUNT(title) cnt
                 FROM loanhist
                          INNER JOIN title ON loanhist.title_no = title.title_no
                 WHERE author = t.author
                 GROUP BY title
             ) as cnts)
FROM title t
         INNER JOIN loanhist l on t.title_no = l.title_no
WHERE (SELECT COUNT(*) FROM loanhist l2 WHERE l2.title_no = t.title_no) >
      (SELECT AVG(cnt)
       FROM (
                SELECT COUNT(title) cnt
                FROM loanhist
                         INNER JOIN title ON loanhist.title_no = title.title_no
                WHERE author = t.author
                GROUP BY title
            ) as cnts)