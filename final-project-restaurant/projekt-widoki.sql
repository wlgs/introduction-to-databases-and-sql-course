CREATE VIEW CurrentMenu AS
SELECT P.Name, M.Price
FROM Products P
         INNER JOIN Menu M
                    ON M.ProductID = P.ProductID
WHERE M.EndDate IS NULL;

CREATE VIEW FreeTables AS
SELECT T.TableID, T.Size
FROM TABLES T
         INNER JOIN ReservationDetails RD ON
    RD.TableID = T.TableID
         INNER JOIN Reservation R ON
    RD.ReservationID = R.ReservationID
WHERE R.Status = 'Cancelled'
   OR R.EndDate < GETDATE();

CREATE VIEW OrdersToPay AS
SELECT O.OrderID, O.ClientID, O.OrderDate
FROM ORDERS O
WHERE O.PAID = 0;

CREATE VIEW PendingTakeaways AS
SELECT O.OrderID, O.ClientID
FROM ORDERS O
         INNER JOIN OrdersTakeaways OT ON
    OT.TakeawayID = O.TakeawayID
WHERE O.Paid = 1
  AND OT.PrefDate < GETDATE();



CREATE VIEW MonthlyTables AS
SELECT T.TableID,
       T.Size,
       YEAR(R.EndDate)  as year,
       MONTH(R.EndDate) as month,
       COUNT(*)            cnt
FROM TABLES T
         INNER JOIN ReservationDetails RD
                    ON RD.TableID = T.TableID
         INNER JOIN Reservation R
                    ON R.ReservationID = RD.ReservationID
GROUP BY T.TableID, T.Size, YEAR(R.EndDate), MONTH(R.EndDate);

CREATE VIEW MonthlyDiscounts AS
SELECT DV.VarName,
       DD.Value,
       YEAR(DD.EndDate)  as year,
       MONTH(DD.EndDate) as month,
       COUNT(*)          as cnt
FROM DiscountVars DV
         INNER JOIN DiscountDetails DD
                    ON DD.VarID = DV.VarID
GROUP BY DV.VarName, DD.Value, YEAR(DD.EndDate), MONTH(DD.EndDate);

CREATE VIEW MonthlyMenu AS
SELECT P.Name,
       M.Price,
       YEAR(M.EndDate)    as year,
       MONTH(M.EndDate)   as month,
       COUNT(*)           as cnt,
       M.Price * COUNT(*) as income
FROM PRODUCTS P
         INNER JOIN MENU M
                    ON M.ProductID = P.ProductID
GROUP BY P.Name, M.Price, YEAR(M.EndDate), MONTH(M.EndDate);

--


CREATE VIEW WeeklyMenu AS
SELECT P.Name,
       M.Price,
       YEAR(M.EndDate)           year,
       DATEPART(week, M.EndDate) week,
       COUNT(*)           as     how_many_times,
       M.Price * COUNT(*) as     income
FROM PRODUCTS P
         INNER JOIN MENU M
                    ON M.ProductID = P.ProductID
GROUP BY P.Name, M.Price, YEAR(M.EndDate), DATEPART(week, M.EndDate)

CREATE VIEW WeeklyTables AS
SELECT T.TableID,
       T.Size,
       YEAR(R.EndDate)           year,
       DATEPART(week, R.EndDate) week,
       COUNT(*)                  cnt
FROM TABLES T
         INNER JOIN ReservationDetails RD
                    ON RD.TableID = T.TableID
         INNER JOIN Reservation R
                    ON R.ReservationID = RD.ReservationID
GROUP BY T.TableID, T.Size, YEAR(R.EndDate), DATEPART(week, R.EndDate)

CREATE VIEW WeeklyDiscounts AS
SELECT DV.VarName,
       DD.Value,
       YEAR(DD.EndDate)           year,
       DATEPART(week, DD.EndDate) week,
       COUNT(*)                   how_many_times
FROM DiscountVars DV
         INNER JOIN DiscountDetails DD
                    ON DD.VarID = DV.VarID
GROUP BY DV.VarName, DD.Value, YEAR(DD.EndDate), DATEPART(week, DD.EndDate)


--


CREATE VIEW MostPopularMealsAllTime AS
SELECT TOP 5 P.NAME
FROM Products P
         INNER JOIN OrderDetails OD on P.ProductID = OD.ProductID
         INNER JOIN Orders O on OD.OrderID = O.OrderID
GROUP BY P.Name
ORDER BY COUNT(OD.ProductID) DESC


CREATE VIEW LeastPopularMealsAllTime AS
SELECT TOP 5 P.NAME
FROM Products P
         INNER JOIN OrderDetails OD on P.ProductID = OD.ProductID
         INNER JOIN Orders O on OD.OrderID = O.OrderID
GROUP BY P.Name
ORDER BY COUNT(OD.ProductID)


CREATE VIEW MostPopularMealPerMenu AS
SELECT M.MenuID,
       M.StartDate,
       M.EndDate,
       (SELECT TOP 1 P.NAME
        FROM Products P
                 INNER JOIN OrderDetails OD on P.ProductID = OD.ProductID
                 INNER JOIN Orders O on OD.OrderID = O.OrderID
                 INNER JOIN Menu M on P.ProductID = M.ProductID
        GROUP BY P.Name
        ORDER BY COUNT(OD.ProductID) DESC) product_name
FROM Menu M

CREATE VIEW LeastPopularMealPerMenu AS
SELECT M.MenuID,
       M.StartDate,
       M.EndDate,
       (SELECT TOP 1 P.NAME
        FROM Products P
                 INNER JOIN OrderDetails OD on P.ProductID = OD.ProductID
                 INNER JOIN Orders O on OD.OrderID = O.OrderID
                 INNER JOIN Menu M on P.ProductID = M.ProductID
        GROUP BY P.Name
        ORDER BY COUNT(OD.ProductID)) product_name
FROM Menu M


CREATE VIEW BestIndividualCustomersByAmountOrdered AS
SELECT TOP 5 O.ClientID,
             P.FirstName,
             P.LastName,
             COUNT(O.OrderID) cnt
FROM Orders O
         INNER JOIN Clients C
                    ON C.ClientID = O.ClientID
         INNER JOIN IndividualClient IC
                    ON IC.ClientID = C.ClientID
         INNER JOIN Person P
                    ON P.PersonID = IC.PersonID
GROUP BY O.ClientID, P.FirstName, P.LastName


CREATE VIEW BestIndividualCustomersByValueOrdered AS
SELECT TOP 5 O.ClientID,
             P.FirstName,
             P.LastName,
             SUM(OD.Quantity * M.Price) total_sum
FROM Orders O
         INNER JOIN Clients C
                    ON C.ClientID = O.ClientID
         INNER JOIN IndividualClient IC
                    ON IC.ClientID = C.ClientID
         INNER JOIN Person P
                    ON P.PersonID = IC.PersonID
         INNER JOIN OrderDetails OD
                    ON OD.OrderID = O.OrderID
         INNER JOIN Products P2
                    ON P2.ProductID = OD.ProductID
         INNER JOIN Menu M
                    ON M.ProductID = P2.ProductID
GROUP BY O.ClientID, P.FirstName, P.LastName
ORDER BY SUM(OD.Quantity * M.Price) DESC

CREATE VIEW BestCompaniesByAmountOrdered AS
SELECT TOP 5 CO.CompanyName,
             Count(O.OrderID) cnt
FROM Orders O
         INNER JOIN Clients C
                    ON C.ClientID = O.ClientID
         INNER JOIN Companies CO
                    ON CO.ClientID = C.ClientID
GROUP BY CO.CompanyName
ORDER BY Count(O.OrderID) DESC

CREATE VIEW BestCompaniesByValueOrdered AS
SELECT TOP 5 CO.CompanyName,
             SUM(OD.Quantity * M.Price) total_sum
FROM Orders O
         INNER JOIN Clients C
                    ON C.ClientID = O.ClientID
         INNER JOIN Companies CO
                    ON CO.ClientID = C.ClientID
         INNER JOIN OrderDetails OD
                    ON OD.OrderID = O.OrderID
         INNER JOIN Products P
                    ON P.ProductID = OD.ProductID
         INNER JOIN Menu M
                    ON M.ProductID = P.ProductID
GROUP BY CO.CompanyName
ORDER BY SUM(OD.Quantity * M.Price) DESC

-- best customer (orders amount / orders value)
-- best company -=-
--
-- most occupied hours for reservations per day XD
--
-- customers discounts
--
--
-- obrut per day month (rollup probably)

-- TODO :
-- CREATE VIEW OrderStats AS
-- SELECT O.OrderID, O.OrderDate, sum(OD.Quantity * M.Price) total_sum
-- FROM ORDERS O
--          INNER JOIN OrderDetails OD
--                     ON OD.OrderID = O.OrderID
--          INNER JOIN Products P
--                     ON P.ProductID = OD.ProductID
--          INNER JOIN Menu M
--                     ON M.ProductID = P.ProductID
-- GROUP BY O.OrderID, O.OrderDate
