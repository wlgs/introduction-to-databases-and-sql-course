USE Northwind

-- ćwiczenie 1
-- 1. Napisz polecenie, które oblicza wartość sprzedaży dla każdego
-- zamówienia i wynik zwraca posortowany w malejącej kolejności
-- (wg wartości sprzedaży).
-- 2. Zmodyfikuj zapytanie z punktu 1., tak aby zwracało pierwszych 10
-- wierszy
-- 3. Zmodyfikuj zapytanie z punktu 2., tak aby zwracało 10 pierwszych
-- produktów wliczając równorzędne. Porównaj wyniki.

SELECT TOP 10 WITH TIES OrderID, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM [Order Details]
GROUP BY OrderID

-- ćwiczenie 2
-- 1. Podaj liczbę zamówionych jednostek produktów dla produktów o
-- identyfikatorze < 3

SELECT ProductID, COUNT(*) as 'ilosc'
FROM [Order Details]
WHERE ProductID < 3
GROUP BY ProductID

-- 2. Zmodyfikuj zapytanie z punktu 1. tak aby podawało liczbę
-- zamówionych jednostek produktu dla wszystkich produktów

SELECT ProductID, COUNT(*) as 'ilosc'
FROM [Order Details]
GROUP BY ProductID

-- 3. Podaj wartość zamówienia dla każdego zamówienia, dla którego
-- łączna liczba zamawianych jednostek produktów jest > 250

SELECT ProductID, SUM((UnitPrice * Quantity * (1 - Discount))) as 'wartosc'
FROM [Order Details]
GROUP BY ProductID
HAVING sum(Quantity)>250

-- ćwiczenie 3

-- 1. Napisz polecenie, które oblicza sumaryczną ilość zamówionych
-- towarów i porządkuje wg productid i orderid oraz wykonuje
-- kalkulacje rollup.

SELECT ProductID, OrderID ,SUM(quantity) as 'quantity sum'
FROM [Order Details]
GROUP BY ROLLUP (ProductID, OrderID)


-- 2. Zmodyfikuj zapytanie z punktu 1., tak aby ograniczyć wynik tylko do
-- produktu o numerze 50.

SELECT ProductID, OrderID ,SUM(quantity) as 'quantity sum'
FROM [Order Details]
WHERE ProductID=50
GROUP BY ROLLUP (ProductID, OrderID)

-- 3. Jakie jest znaczenie wartości null w kolumnie productid i orderid?

--odp: oznacza to sumę podliczoną dla danej kolumny

-- 4. Zmodyfikuj polecenie z punktu 1. używając operator cube zamiast
-- rollup. Użyj również funkcji GROUPING na kolumnach productid i
-- orderid do rozróżnienia między sumarycznymi i szczegółowymi
-- wierszami w zbiorze

SELECT ProductID, OrderID ,SUM(quantity) as 'quantity sum',
       GROUPING(ProductID) as 'prdid_grp', GROUPING(OrderID) as 'ordid_grp'
FROM [Order Details]
GROUP BY CUBE (ProductID, OrderID)


-- 5. Które wiersze są podsumowaniami?
-- Które podsumowują według produktu, a które według zamówienia?

-- wiersze które są podsumowaniami mają odpowiednio 1 w prdid_grp lub ordid_grp
