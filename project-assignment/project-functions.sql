CREATE FUNCTION udfGetActualReservationWK() RETURNS FLOAT AS BEGIN
DECLARE @val float;
SET @val = (
        SELECT WK
        FROM ReservationVar
        WHERE GETDATE() BETWEEN StartDate AND EndDate
    ) RETURN @val
END
go CREATE FUNCTION udfGetAmountOfOrdersOnDay(@date date) RETURNS int AS BEGIN RETURN (
        SELECT COUNT(OI.OrderID)
        FROM OrdersInfo OI
        WHERE YEAR(@date) = YEAR(OI.OrderDate)
            AND MONTH(@date) = MONTH(OI.OrderDate)
            AND DAY(@date) = DAY(OI.OrderDate)
    )
END
go CREATE FUNCTION udfGetAvgPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
        SELECT AVG(M.Price)
        FROM Menu M
        WHERE MenuID = @MenuID
    )
END
go CREATE FUNCTION udfGetBestMeals(@input int) RETURNS table AS RETURN
SELECT DISTINCT TOP (@input) P.Name,
    MMI.times_sold
FROM Products P
    INNER JOIN MealsMenuInfo MMI on P.ProductID = MMI.ProductID
ORDER BY MMI.times_sold
go CREATE FUNCTION udfGetBestPermDiscountByClientID(@id int) RETURNS FLOAT AS BEGIN
DECLARE @val float;
SET @val = (
        SELECT TOP 1 DV.R1
        FROM Discounts
            INNER JOIN DiscountVars DV on Discounts.SetID = DV.SetID
        WHERE ClientID = @id
            AND DiscountType = 'perm'
            AND GETDATE() BETWEEN AppliedDate AND DATEADD(day, DV.D1, AppliedDate)
        ORDER BY 1 DESC
    ) IF @val IS NULL BEGIN RETURN 0
end RETURN @val
END
go CREATE FUNCTION udfGetBestTempDiscountByClientID(@id int) RETURNS FLOAT AS BEGIN
DECLARE @val float;
SET @val = (
        SELECT TOP 1 DV.R1
        FROM Discounts
            INNER JOIN DiscountVars DV on Discounts.SetID = DV.SetID
        WHERE ClientID = @id
            AND DiscountType = 'temp'
            AND GETDATE() BETWEEN AppliedDate AND DATEADD(day, DV.D1, AppliedDate)
        ORDER BY 1 DESC
    ) IF @val IS NULL BEGIN RETURN 0
end RETURN @val
END
go CREATE FUNCTION udfGetClientsOrderAmount(@clientid int) RETURNS INT AS BEGIN
DECLARE @val int;
SET @val = (
        SELECT times_ordered
        FROM ClientStats
        WHERE ClientID = @clientid
    ) RETURN @val
END
go CREATE FUNCTION udfGetClientsOrderedMoreThanXTimes(@amount int) RETURNS TABLE AS RETURN
SELECT *
FROM ClientStats
WHERE times_ordered > @amount
go CREATE FUNCTION udfGetClientsOrderedMoreThanXValue(@value float) RETURNS TABLE AS RETURN
SELECT *
FROM ClientStats
WHERE ClientStats.value_ordered > @value
go CREATE FUNCTION udfGetClientsWhoOweMoreThanX(@val int) RETURNS table AS RETURN
SELECT client_id,
    money_to_pay
FROM OwingClients
WHERE money_to_pay > @val
go CREATE FUNCTION udfGetDiscountValue(@id int) RETURNS FLOAT AS BEGIN
DECLARE @val float;
DECLARE @type varchar(32);
DECLARE @setid int;
SET @type = (
        SELECT DiscountType
        FROM Discounts
        WHERE DiscountID = @id
    )
SET @setid = (
        SELECT SetID
        FROM Discounts
        WHERE DiscountID = @id
    ) IF @type IS NULL begin
SET @val = 0
end IF @type = 'temp' BEGIN
SET @val = (
        SELECT R2
        FROM DiscountVars DV
        WHERE SetID = @setid
    )
end IF @type = 'perm' BEGIN
SET @val = (
        SELECT R1
        FROM DiscountVars DV
        WHERE SetID = @setid
    )
end RETURN @val
END
go CREATE FUNCTION udfGetEmployeesOfCompany(@CompanyName varchar(255)) RETURNS table AS RETURN
SELECT P.Firstname,
    P.Lastname
FROM Person P
    INNER JOIN Employees E on P.PersonID = E.PersonID
    INNER JOIN Companies C on E.CompanyID = C.ClientID
WHERE @CompanyName = CompanyName
go CREATE FUNCTION udfGetMaxPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
        SELECT TOP 1 MAX(M.Price)
        FROM Menu M
        WHERE MenuID = @MenuID
    )
END
go CREATE FUNCTION udfGetMealsSoldAtLeastXTimes(@input int) RETURNS table AS RETURN
SELECT MSI.Name,
    MSI.times_sold
FROM MealsSoldInfo MSI
WHERE MSI.times_sold > @input
go CREATE FUNCTION udfGetMenuItemsByDate(@date date) RETURNS TABLE AS RETURN
SELECT M.MenuID,
    M.StartDate,
    M.EndDate,
    P.Name,
    P.ProductID,
    M.Price
FROM Products P
    INNER JOIN Menu M ON M.ProductID = P.ProductID
WHERE @date BETWEEN M.StartDate AND M.EndDate
go CREATE FUNCTION udfGetMenuItemsById(@id int) RETURNS TABLE AS RETURN
SELECT M.MenuID,
    M.StartDate,
    M.EndDate,
    P.Name,
    M.Price
FROM Products P
    INNER JOIN Menu M ON M.ProductID = P.ProductID
WHERE (M.MenuID = @id)
go CREATE FUNCTION udfGetMinPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
        SELECT TOP 1 MIN(M.Price)
        FROM Menu M
        WHERE MenuID = @MenuID
    )
END
go CREATE FUNCTION udfGetOrderDiscountValue(@orderid int) RETURNS FLOAT AS BEGIN
DECLARE @id float;
SET @id = (
        SELECT AppliedDiscount
        FROM Orders
        WHERE OrderID = @orderid
    ) IF @id IS NULL BEGIN RETURN 0
end RETURN dbo.udfGetDiscountValue (@id)
END
go CREATE FUNCTION udfGetOrdersAboveXValue(@input int) RETURNS table AS RETURN
SELECT OI.OrderID,
    OI.ClientID,
    OI.order_value
FROM OrdersInfo OI
WHERE OI.order_value > @input
go CREATE FUNCTION udfgetOrderValue(@id int) RETURNS money AS BEGIN RETURN (
        SELECT order_value *(1 - dbo.udfGetOrderDiscountValue(@id))
        FROM OrdersInfo
        WHERE OrderID = @id
    )
END
go CREATE FUNCTION udfgetValueOfOrdersInMonth(@year int, @month int) RETURNS int AS BEGIN RETURN (
        SELECT SUM(
                OI.order_value * (1 - dbo.udfGetDiscountValue(O.AppliedDiscount))
            )
        FROM OrdersInfo OI
            INNER JOIN Orders O on OI.OrderID = O.OrderID
        WHERE @year = YEAR(OI.OrderDate)
            AND @month = MONTH(OI.OrderDate)
    )
END
go CREATE FUNCTION udfgetValueOfOrdersOnDay(@date date) RETURNS int AS BEGIN RETURN (
        SELECT SUM(
                OI.order_value * (1 - dbo.udfGetDiscountValue(O.AppliedDiscount))
            )
        FROM OrdersInfo OI
            INNER JOIN Orders O on OI.OrderID = O.OrderID
        WHERE YEAR(@date) = YEAR(OI.OrderDate)
            AND MONTH(@date) = MONTH(OI.OrderDate)
            AND DAY(@date) = DAY(OI.OrderDate)
    )
END
go CREATE FUNCTION udfMenuIsCorrect(@id int) RETURNS int AS BEGIN
DECLARE @sameItems int
SET @sameItems = (
        SELECT COUNT(*)
        FROM (
                SELECT ProductID
                FROM Menu
                WHERE MenuID = (@id - 1) --prev table
                INTERSECT
                SELECT ProductID
                FROM Menu
                WHERE MenuID = @id --table to check
            ) out
    )
DECLARE @minAmountToChange int
SET @minAmountToChange = (
        SELECT COUNT(*)
        FROM Menu
        WHERE MenuID =(@id -1)
    ) / 2 IF @sameItems <= @minAmountToChange BEGIN return 1
end return 0
END
go