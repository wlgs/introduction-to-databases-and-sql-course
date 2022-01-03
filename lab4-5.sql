Use Northwind;
-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy

SELECT ProductName, UnitPrice, CompanyName, Address
FROM Products as p
         LEFT JOIN Suppliers as s on p.SupplierID = s.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30;


-- 2. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów
-- dostarczanych przez firmę ‘Tokyo Traders’

SELECT ProductName, UnitsInStock, CompanyName
FROM Products
         INNER JOIN Suppliers
                    ON Products.SupplierID = Suppliers.SupplierID AND CompanyName = 'Tokyo Traders';

-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe

SELECT Customers.CustomerID, YEAR(OrderDate)
FROM Customers
         LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID AND YEAR(OrderDate) = 1997
WHERE OrderDate IS NULL;


-- 4. Wybierz nazwy i numery telefonów dostawców, dostarczających produkty,
-- których aktualnie nie ma w magazynie

SELECT CompanyName, Phone
FROM Suppliers
         LEFT JOIN Products on Suppliers.SupplierID = Products.SupplierID AND UnitsInStock = 0

Use library
-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko i data urodzenia dziecka.

SELECT FirstName, LastName, birth_date
FROM member
         INNER JOIN juvenile
                    ON juvenile.member_no = member.member_no

-- 2. Napisz polecenie, które podaje tytuły aktualnie wypożyczonych książek


SELECT title
FROM title
         INNER JOIN loanhist ON title.title_no = loanhist.title_no
WHERE out_date IS NOT NULL
  AND in_date IS NULL;


-- 3. Podaj informacje o karach zapłaconych za przetrzymywanie książki o tytule ‘Tao
-- Teh King’. Interesuje nas data oddania książki, ile dni była przetrzymywana i jaką
-- zapłacono karę

select L.fine_paid, L.in_date, DATEDIFF(Day, L.in_date, L2.out_date)
FROM loanhist L
         INNER JOIN title T
                    ON L.title_no = T.title_no
         INNER JOIN loan L2
                    ON L.title_no = L2.title_no
WHERE T.title = 'Tao Teh King'
  AND L.fine_paid is not null

-- 4. Napisz polecenie które podaje listę książek (mumery ISBN) zarezerwowanych
-- przez osobę o nazwisku: Stephen A. Graff

SELECT isbn
FROM loan L
         INNER JOIN member M
                    ON M.member_no = L.member_no
WHERE firstname = 'Stephen'
  and lastname = 'Graff'
  and middleinitial = 'A'

Use Northwind
-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy,
-- interesują nas tylko produkty z kategorii ‘Meat/Poultry’

SELECT P.ProductName, P.UnitPrice, S.Address
FROM Products P
         LEFT JOIN Suppliers S on P.SupplierID = S.SupplierID
         INNER JOIN Categories C on P.CategoryID = C.CategoryID
WHERE P.UnitPrice BETWEEN 20 AND 30
  AND C.CategoryName = 'Meat/Poultry'


-- 2. Wybierz nazwy i ceny produktów z kategorii ‘Confections’ dla każdego produktu
-- podaj nazwę dostawcy.

SELECT P.ProductName, P.UnitPrice, S.CompanyName
FROM Products P
         LEFT JOIN Suppliers S on P.SupplierID = S.SupplierID
         INNER JOIN Categories C on P.CategoryID = C.CategoryID
WHERE C.CategoryName = 'Confections'

-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma ‘United Package’

SELECT C.ContactName, C.Phone
FROM Customers C
         INNER JOIN ORDERS O on C.CustomerID = O.CustomerID
         INNER JOIN Shippers S on O.ShipVia = S.ShipperID
WHERE YEAR(O.ShippedDate) = 1997 AND S.CompanyName = 'United Package';

-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- ‘Confections’

SELECT C.ContactName, C.Phone
FROM Customers C
         INNER JOIN ORDERS O on C.CustomerID = O.CustomerID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
         INNER JOIN Categories CA on OD.ProductID = CA.CategoryID
WHERE CA.CategoryName = 'Confections'
GROUP BY C.ContactName, C.Phone

USE library;
-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka i adres
-- zamieszkania dziecka


SELECT FirstName, LastName, birth_date, A.street
FROM member M
         INNER JOIN juvenile J
                    ON J.member_no = M.member_no
         INNER JOIN adult A ON J.adult_member_no = A.member_no


-- 2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka, adres
-- zamieszkania dziecka oraz imię i nazwisko rodzica.
SELECT M.FirstName, M.LastName, birth_date, P.firstname, P.lastname
FROM member M
         INNER JOIN juvenile J
                    ON J.member_no = M.member_no
         JOIN member P ON J.adult_member_no = P.member_no

-- 1. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych (baza
-- northwind)
Use Northwind
SELECT a.FirstName, a.LastName, b.FirstName, b.LastName
FROM Employees as a
         JOIN Employees as b ON a.ReportsTo = b.EmployeeID
WHERE a.ReportsTo is not NULL

-- 2. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych
-- (baza northwind)

SELECT W.FirstName, W.LastName
FROM Employees W
         JOIN Employees P on W.EmployeeID = P.ReportsTo
WHERE W.ReportsTo IS NULL
GROUP BY W.FirstName, W.LastName


-- 3. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996
Use library
SELECT DISTINCT A.Street, A.city, A.zip, A.member_no
FROM adult A
         INNER JOIN juvenile J on J.adult_member_no = A.member_no AND YEAR(J.birth_date) < 1996

-- 4. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996. Interesują nas tylko adresy takich członków
-- biblioteki, którzy aktualnie nie przetrzymują książek.

SELECT DISTINCT A.Street, A.city, A.zip, A.member_no
FROM adult A
         INNER JOIN juvenile J on J.adult_member_no = A.member_no AND YEAR(J.birth_date) < 1996
         LEFT JOIN loan L on A.member_no = L.member_no
WHERE L.out_date IS NULL


-- 1. Napisz polecenie które zwraca imię i nazwisko (jako pojedynczą kolumnę –
-- name), oraz informacje o adresie: ulica, miasto, stan kod (jako pojedynczą
-- kolumnę – address) dla wszystkich dorosłych członków biblioteki

SELECT M.firstname + ' ' + M.lastname as 'name', A.street + ', ' + A.city + ', ' + A.state + ', ' + a.zip as 'address'
FROM adult A
         LEFT JOIN member M on A.member_no = M.member_no;



-- 2. Napisz polecenie, które zwraca: isbn, copy_no, on_loan, title, translation, cover,
-- dla książek o isbn 1, 500 i 1000. Wynik posortuj wg ISBN

SELECT I.isbn, C.copy_no, C.on_loan, T.title, I.translation, I.cover
FROM item I
         INNER JOIN title T on I.title_no = T.title_no
         INNER JOIN copy C on I.isbn = C.isbn
WHERE I.isbn = 1
   OR I.isbn = 500
   or I.isbn = 1000
ORDER BY 1 DESC;


-- 3. Napisz polecenie które zwraca o użytkownikach biblioteki o nr 250, 342, i 1675
-- (dla każdego użytkownika: nr, imię i nazwisko członka biblioteki), oraz informację
-- o zarezerwowanych książkach (isbn, data)

SELECT M.member_no, M.firstname, M.lastname, R.isbn, R.log_date
FROM member M
         LEFT JOIN reservation R ON M.member_no = R.member_no
WHERE M.member_no = 250
   OR M.member_no = 342
   or M.member_no = 1675

-- 4. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają więcej niż
-- dwoje dzieci zapisanych do biblioteki


SELECT (firstname + ' ' + lastname) as 'name', COUNT(juvenile.member_no) as 'kids'
FROM member
         JOIN juvenile ON juvenile.adult_member_no = member.member_no
         JOIN adult ON member.member_no = adult.member_no
WHERE adult.State = 'AZ'
GROUP BY member.member_no, (firstname + ' ' + lastname)
HAVING COUNT(juvenile.member_no) > 2

-- 1. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej
-- niż dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni
-- (CA) i mają więcej niż troje dzieci zapisanych do biblioteki

SELECT (firstname + ' ' + lastname) as 'name', COUNT(juvenile.member_no) as 'kids'
FROM member
         JOIN juvenile ON juvenile.adult_member_no = member.member_no
         JOIN adult ON member.member_no = adult.member_no
WHERE adult.State = 'AZ'
GROUP BY member.member_no, (firstname + ' ' + lastname)
HAVING COUNT(juvenile.member_no) > 2
UNION
SELECT (firstname + ' ' + lastname) as 'name', COUNT(juvenile.member_no) as 'kids'
FROM member
         JOIN juvenile ON juvenile.adult_member_no = member.member_no
         JOIN adult ON member.member_no = adult.member_no
WHERE adult.State = 'CA'
GROUP BY member.member_no, (firstname + ' ' + lastname)
HAVING COUNT(juvenile.member_no) > 3

-- \/ćwiczenia końcowe\/
-- ćwiczenie 1
-- 1. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek towaru oraz
-- nazwę klienta.
Use Northwind;
SELECT o.OrderID, SUM(Quantity), C.CompanyName
FROM [Order Details] as o
         LEFT JOIN Orders as o2 on o.OrderID = o2.OrderID
        INNER JOIN Customers C on o2.CustomerID = C.CustomerID
GROUP BY o.OrderID, C.CompanyName


-- 2. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczbę zamówionych jednostek jest większa niż 250

SELECT o.OrderID, SUM(Quantity), o2.CustomerID
FROM [Order Details] as o
         LEFT JOIN Orders as o2 on o.OrderID = o2.OrderID
GROUP BY o.OrderID, o2.CustomerID
HAVING SUM(Quantity) > 250


-- 3. Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz nazwę
-- klienta

SELECT o.OrderID, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc', o2.CustomerID
FROM [Order Details] as o
         LEFT JOIN Orders as o2 ON o.OrderID = o2.OrderID
GROUP BY o.OrderID, o2.CustomerID


-- 4. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczba jednostek jest większa niż 250.

SELECT o.OrderID, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc', o2.CustomerID
FROM [Order Details] as o
         LEFT JOIN Orders as o2 ON o.OrderID = o2.OrderID
GROUP BY o.OrderID, o2.CustomerID
HAVING SUM(Quantity) > 250;

-- 5. Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i nazwisko
-- pracownika obsługującego zamówienie


SELECT o.OrderID,
       SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc',
       o2.CustomerID,
       E.FirstName + ' ' + E.LastName
FROM [Order Details] as o
         LEFT JOIN Orders as o2 ON o.OrderID = o2.OrderID
         LEFT JOIN Employees E on o2.EmployeeID = E.EmployeeID
GROUP BY o.OrderID, o2.CustomerID, E.FirstName + ' ' + E.LastName
HAVING SUM(Quantity) > 250;


-- ćwiczenie 2
Use Northwind
-- 1. Dla każdej kategorii produktu (nazwa), podaj łączną liczbę zamówionych przez
-- klientów jednostek towarów z tek kategorii.

SELECT C.CategoryName, SUM(OD.Quantity)
FROM Categories C
         LEFT JOIN Products P on C.CategoryID = P.CategoryID
         INNER JOIN [Order Details] OD on P.ProductID = OD.ProductID
GROUP BY C.CategoryName
ORDER BY 2 DESC;

-- 2. Dla każdej kategorii produktu (nazwa), podaj łączną wartość zamówionych przez
-- klientów jednostek towarów z tek kategorii.

SELECT C.CategoryName, SUM((OD.UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM Categories C
         LEFT JOIN Products P on C.CategoryID = P.CategoryID
         INNER JOIN [Order Details] OD on P.ProductID = OD.ProductID
GROUP BY C.CategoryName
ORDER BY 2 DESC;

-- 3. Posortuj wyniki w zapytaniu z poprzedniego punktu wg:
-- a) łącznej wartości zamówień
-- b) łącznej liczby zamówionych przez klientów jednostek towarów.


-- 4. Dla każdego zamówienia podaj jego wartość uwzględniając opłatę za przesyłkę

SELECT OD.OrderID,
       SUM((UnitPrice * Quantity * (1 - Discount))) + O.Freight as 'wartosc z przesylka',
       SUM((UnitPrice * Quantity * (1 - Discount)))             as 'wartosc bez przesylki'
FROM [Order Details] OD
         LEFT JOIN Orders O on OD.OrderID = O.OrderID
GROUP BY OD.OrderID, O.Freight;

-- ćwiczenie 3

-- 1. Dla każdego przewoźnika (nazwa) podaj liczbę zamówień które przewieźli w 1997r
-- 2. Który z przewoźników był najaktywniejszy (przewiózł największą liczbę
-- zamówień) w 1997r, podaj nazwę tego przewoźnika

SELECT TOP 1 S.CompanyName, COUNT(O.OrderID)
FROM Shippers S
         INNER JOIN Orders O on S.ShipperID = O.ShipVia
WHERE YEAR(O.ShippedDate) = 1997
GROUP BY S.CompanyName
ORDER BY 2 DESC;

-- 3. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika

SELECT E.FirstName + ' ' + E.LastName, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM Employees E
         LEFT JOIN Orders O on E.EmployeeID = O.EmployeeID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY E.FirstName + ' ' + E.LastName

-- 4. Który z pracowników obsłużył największą liczbę zamówień w 1997r, podaj imię i
-- nazwisko takiego pracownika

SELECT TOP 1 E.FirstName + ' ' + E.LastName, COUNT(O.OrderID) as 'ilosc'
FROM Employees E
         LEFT JOIN Orders O on E.EmployeeID = O.EmployeeID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY E.FirstName + ' ' + E.LastName
ORDER BY 2 DESC;


-- 5. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o
-- największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika

SELECT TOP 1 E.FirstName + ' ' + E.LastName, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM Employees E
         LEFT JOIN Orders O on E.EmployeeID = O.EmployeeID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY E.FirstName + ' ' + E.LastName
ORDER BY 2 DESC;


-- ćwiczenie 4

-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika
-- – Ogranicz wynik tylko do pracowników
-- a) którzy mają podwładnych
-- b) którzy nie mają podwładnych

--a)

SELECT P.FirstName, P.LastName, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM Employees P
         JOIN Employees W on W.EmployeeID = P.ReportsTo AND P.ReportsTo IS NOT NULL
         LEFT JOIN Orders O on W.EmployeeID = O.EmployeeID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY P.FirstName, P.LastName

--b)

SELECT W.FirstName, W.LastName, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM Employees W
         JOIN Employees P on W.EmployeeID = P.ReportsTo AND W.ReportsTo IS NULL
         LEFT JOIN Orders O on W.EmployeeID = O.EmployeeID
         INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY W.FirstName, W.LastName
