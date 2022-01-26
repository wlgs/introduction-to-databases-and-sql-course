--
USE library
SELECT title
FROM title
WHERE title_no = 10;

USE library
SELECT member_no
FROM loanhist
WHERE isnull(fine_assessed, 0) > isnull(fine_paid, 0) + isnull(fine_waived, 0)

USE library
SELECT DISTINCT city, state
FROM adult

USE library
SELECT (lower(firstname + middleinitial + substring(lastname, 1, 2))) AS 'email_name'
FROM member
WHERE lastname = 'Anderson';

USE Northwind
SELECT (UnitPrice * Quantity * (1 - Discount)) as 'wartosc'
FROM [Order Details]
WHERE OrderID = 10250;


USE Northwind
SELECT SupplierID, (isnull(Phone, 'brak') + ', ' + isnull(Fax, 'brak')) as 'Phone and Fax'
FROM Suppliers;

USE Northwind
SELECT TOP 5 WITH TIES orderid, productid, quantity
FROM [Order Details]
ORDER BY Quantity DESC;

--        ##### CW 1 KONCOWE:
-- #### Ćwiczenie 1 – wybieranie danych
--1. Napisz polecenie select, za pomocą którego uzyskasz tytuł i numer książki

USE library
SELECT title_no, title
FROM title


--2. Napisz polecenie, które wybiera tytuł o numerze 10

USE library
SELECT title
FROM title
WHERE title_no = 10


--3. Napisz polecenie, które wybiera numer czytelnika i karę dla tych czytelników, którzy mają kary między $8 a $9


USE library
SELECT member_no, fine_assessed
FROM loanhist
WHERE fine_assessed BETWEEN 8 AND 9

--4. Napisz polecenie select, za pomocą którego uzyskasz numer książki i autora dla wszystkich książek, których utorem jest Charles Dickens lub Jane Austen

USE library
SELECT title_no, author
FROM title
WHERE author = 'Charles Dickens'
   or author = 'Jane Austen'

--5. Napisz polecenie, które wybiera numer tytułu i tytuł dla wszystkich rekordów zawierających string „adventures” gdzieś w tytule

USE library
SELECT title_no, title
FROM title
WHERE title LIKE '%adventures%'

--6. Napisz polecenie, które wybiera numer czytelnika, karę oraz zapłaconą karę dla wszystkich, którzy jeszcze nie zapłacili.

USE library
SELECT member_no, fine_assessed, fine_paid
FROM loanhist
WHERE fine_paid = 0

--7. Napisz polecenie, które wybiera wszystkie unikalne pary miast i stanów z tablicy adult.
USE library
SELECT DISTINCT city, state
FROM adult


--##### Ćwiczenie 2 – manipulowanie wynikowym zbiorem

--1. Napisz polecenie, które wybiera wszystkie tytuły z tablicy title i wyświetla je w porządku alfabetycznym.

USE library
SELECT title
FROM title
ORDER BY title ASC;

--2. Napisz polecenie, które:
-- wybiera numer członka biblioteki, isbn książki i wartość naliczonej kary dla wszystkich wypożyczeń, dla których naliczono karę
-- stwórz kolumnę wyliczeniową zawierającą podwojoną wartość kolumny fine_assessed
-- stwórz alias ‘double fine’ dla tej kolumny

USE library
SELECT member_no, isbn, sum(fine_assessed) as 'total fines', fine_assessed * 2 as 'double fine'
FROM loanhist
WHERE fine_assessed IS NOT NULL
  AND fine_assessed != 0
GROUP BY member_no, isbn, fine_assessed

--3. Napisz polecenie, które generuje pojedynczą kolumnę, która zawiera kolumny: imię
--członka biblioteki, inicjał drugiego imienia i nazwisko dla
--wszystkich członków biblioteki, którzy nazywają się Anderson
--nazwij tak powstałą kolumnę „email_name”
-- zmodyfikuj polecenie, tak by zwróciło „listę proponowanych loginów e
--mail” utworzonych przez połączenie imienia członka biblioteki, z inicjałem drugiego imienia i pierwszymi dwoma
--literami nazwiska (wszystko małymi literami).
-- wykorzystaj funkcję SUBSTRING do uzyskania części kolumny
--znakowej oraz LOWER do zwrócenia wyniku małymi literami
-- wykorzystaj operator (+) do połączenia stringów.

USE library
SELECT LOWER(firstname + middleinitial + substring(lastname, 1, 2)) as 'email_name'
FROM member
WHERE lastname = 'Anderson'

--4. Napisz polecenie, które wybiera title i title_no z tablicy
-- title. Wynikiem powinna być pojedyncza kolumna o formacie jak w
-- przykładzie poniżej:
-- The title is: Poems, title number
-- 7
-- Czyli zapytanie powinno zwracać pojedynczą kolumnę w oparciu
-- o wyrażenie, które łączy 4 elementy:
-- stała znakowa ‘The title is:’
-- wartość kolumny title
-- stała znakowa ‘title number’
-- wartość kolumny title_no

USE library
SELECT 'The title is: ' + title + ', title number ' + str(title_no)
FROM title
ORDER BY title_no;


-- #2 AGREGATY

USE Northwind

-- 1. Podaj liczbę produktów o cenach mniejszych niż 10$ lub
-- większych niż 20$

SELECT COUNT(ProductID) as 'Count'
FROM Products
WHERE UnitPrice < 10
   or UnitPrice < 20;



-- 2. Podaj maksymalną cenę produktu dla produktów o cenach
-- poniżej 20$

SELECT TOP 1 ProductName, UnitPrice
FROM Products
WHERE UnitPrice < 20
ORDER BY UnitPrice DESC;



-- 3. Podaj maksymalną, minimalną i średnią cenę produktu dla
-- produktów sprzedawanych w butelkach (‘bottle’)


SELECT (SELECT TOP 1 UnitPrice
        FROM Products
        WHERE QuantityPerUnit LIKE '%bottle%'
        ORDER BY UnitPrice DESC)               as 'max price',
       (SELECT TOP 1 UnitPrice
        FROM Products
        WHERE QuantityPerUnit LIKE '%bottle%'
        ORDER BY UnitPrice)                    as 'min price',
       (SELECT AVG(UnitPrice)
        FROM Products
        WHERE QuantityPerUnit LIKE '%bottle%') as 'avg price';

-- 4. Wypisz informację o wszystkich produktach o cenie
-- powyżej średniej
--

SELECT AVG(UnitPrice)
FROM Products;

SELECT *
FROM Products
WHERE UnitPrice > 28.8663;

-- 5. Podaj wartość zamówienia o numerze 10250
SELECT SUM((UnitPrice * Quantity * (1 - Discount)))
FROM [Order Details]
WHERE OrderID = 10250;

-- ćwiczenie kolejne

-- 1. Podaj maksymalną cenę zamawianego produktu dla
-- każdego zamówienia. Posortuj zamówienia wg
-- maksymalnej ceny produktu


SELECT OrderID, MAX((UnitPrice * Quantity * (1 - Discount))) as maxprice
FROM [Order Details]
GROUP BY OrderID
ORDER BY maxprice DESC;


-- 2. Podaj maksymalną i minimalną cenę zamawianego
-- produktu dla każdego zamówienia

SELECT OrderID,
       MAX((UnitPrice * Quantity * (1 - Discount))) as maxprice,
       MIN((UnitPrice * Quantity * (1 - Discount))) as minprice
FROM [Order Details]
GROUP BY OrderID;

-- 3. Podaj liczbę zamówień dostarczanych przez
-- poszczególnych spedytorów

SELECT ShipVia, COUNT(*) as no_orders
FROM Orders
GROUP BY ShipVia

-- 4. Który ze spedytorów był najaktywniejszy w 1997 roku?
SELECT Shippers.CompanyName, COUNT(OrderId) as no_orders
FROM Orders
         INNER JOIN Shippers ON ShipperID = Orders.ShipVia
WHERE YEAR(OrderDate) = 1997
GROUP BY Shippers.CompanyName
ORDER BY no_orders DESC

--#ćw kolejne
-- 1. Wyświetl zamówienia dla których liczba pozycji
-- zamówienia jest większa niż 5


SELECT orderid, COUNT(*) as 'total orders'
FROM [Order Details]
GROUP BY orderid
HAVING COUNT(*) > 5


-- 2. Wyświetl klientów, dla których w 1998 roku zrealizowano
-- więcej niż 8 zamówień (wyniki posortuj malejąco wg
-- łącznej kwoty za dostarczenie zamówień dla każdego z
-- klientów)


SELECT Orders.CustomerID,
       COUNT(Orders.OrderID)                        as 'total orders',
       SUM((UnitPrice * Quantity * (1 - Discount))) as 'total sum'
FROM Orders
         INNER JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
WHERE YEAR(ShippedDate) = 1998
GROUP BY CustomerID
HAVING COUNT(Orders.OrderID) > 8
ORDER BY 'total sum' DESC;

-- apparently freight = oplata za przewoz XDDD
-- freight z ang. = załadunek XDDDDD

SELECT CustomerID, SUM((UnitPrice * Quantity * (1 - Discount))) as 'totalsum'
FROM Orders,
     [Order Details]
WHERE YEAR(ShippedDate) = 1998
GROUP BY CustomerID
HAVING COUNT(Orders.OrderID) > 8
ORDER BY totalsum DESC;



SELECT productid, orderid, sum(quantity)
FROM orderhist
GROUP BY productid, orderid
WITH CUBE
ORDER BY productid, orderid


SELECT '<null>', '<null>', sum(quantity)
FROM orderhist


SELECT productid, sum(quantity)
FROM orderhist
WHERE ProductID = 1 --2
GROUP BY productid


--ZADANIE AGREGATY KONCOWE


SELECT FirstName + ' ' + LastName, DATEDIFF(year, HireDate, GETDATE())
FROM Employees


SELECT MIN(LEN(FirstName))
FROM Employees


SELECT EmployeeID, COUNT(*), MIN(OrderDate)
FROM Orders
GROUP BY EmployeeID
ORDER BY EmployeeID


SELECT CustomerID, SUM(Freight)
FROM Orders
WHERE RequiredDate - ShippedDate < 0
GROUP BY CustomerID


USE Library
SELECT TOP 1 YEAR(in_date), SUM(fine_assessed)
FROM loanhist
GROUP BY YEAR(in_date)
ORDER BY SUM(fine_assessed) DESC;