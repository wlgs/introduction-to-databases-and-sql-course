--Wybierz nazwy i adresy klientów, mających siedziby w Londynie

SELECT ContactName, Address
FROM Customers
WHERE City='London';
--Wybierz nazwy i adresy klientów, mających siedziby w Londynie lub Madrycie

SELECT ContactName, Address
FROM Customers
WHERE City='LONDON' or City='Madrid';
--Wybierz nazwy produktów, których cena jednostkowa jest większa niż 40

SELECT ProductName
FROM Products
WHERE UnitPrice>40;
--Wybierz nazwy produktów, których cena jednostkowa jest większa niż 40, posortuj w porządku rosnącym
SELECT ProductName
FROM Products
WHERE UnitPrice>40
ORDER BY UnitPrice;
--Podaj ile jest produktów, których cena jednostkowa jest większa niż 40
SELECT COUNT(ProductID)
FROM Products
WHERE UnitPrice>40;
--Podaj ile jest produktów, których cena jednostkowa jest większa niż 40, których stan magazynowy jest powyżej 100 sztuk
SELECT COUNT(ProductID)
FROM Products
WHERE UnitPrice>40 and UnitsInStock>100;
--Podaj ile jest produktów z kategorii 2-3, których cena jednostkowa jest większa niż 40, których stan magazynowy jest powyżej 100 sztuk
SELECT COUNT(ProductID)
FROM Products
WHERE (CategoryID=2 or CategoryID=3)
  and UnitPrice>40
  and UnitsInStock>100;