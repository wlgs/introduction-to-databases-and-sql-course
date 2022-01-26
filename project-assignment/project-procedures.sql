CREATE PROCEDURE uspAddCategory @CategoryName varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY IF EXISTS(
        SELECT *
        FROM Category
        WHERE @CategoryName = CategoryName
    ) BEGIN;
THROW 52000,
N'Kategoria jest już dodana',
1
end
DECLARE @CategoryID INT
SELECT @CategoryID = ISNULL(MAX(CategoryID), 0) + 1
FROM Category
INSERT INTO Category(CategoryID, CategoryName)
VALUES(@CategoryID, @CategoryName);
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodawania kategorii: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1;
END CATCH
END
go CREATE PROCEDURE uspAddClient @City varchar(255),
    @Street varchar(255),
    @PostalCode varchar(255),
    @Phone varchar(32),
    @Email varchar(255),
    @ClientType varchar(1),
    @CompanyName varchar(255),
    @NIP varchar(32),
    @FirstName varchar(255),
    @LastName varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY IF EXISTS(
        SELECT *
        FROM Clients
        WHERE Phone = @Phone
    ) BEGIN;
THROW 52000,
N 'Numer telefonu jest już w bazie',
1
END IF EXISTS(
    SELECT *
    FROM Clients
    WHERE Email = @Email
) BEGIN;
THROW 52000,
N'Email jest już w bazie',
1
END IF EXISTS(
    SELECT *
    FROM Companies
    WHERE @CompanyName = CompanyName
) BEGIN;
THROW 52000,
N'Firma jest już w bazie',
1
END IF EXISTS(
    SELECT *
    FROM Companies
    WHERE @NIP = NIP
) BEGIN;
THROW 52000,
N 'NIP jest już w bazie',
1
END
DECLARE @ClientID INT
SELECT @ClientID = ISNULL(MAX(ClientID), 0) + 1
FROM Clients
DECLARE @PersonID INT
SELECT @PersonID = ISNULL(MAX(PersonID), 0) + 1
FROM Person
INSERT INTO Clients(ClientID, City, Street, PostalCode, Phone, Email)
VALUES (
        @ClientID,
        @City,
        @Street,
        @PostalCode,
        @Phone,
        @Email
    );
IF @ClientType = 'C' BEGIN
INSERT INTO Companies(ClientID, CompanyName, NIP)
VALUES (@ClientID, @CompanyName, @NIP)
END
ELSE BEGIN
INSERT INTO Person(FirstName, LastName, PersonID)
VALUES (@FirstName, @LastName, @PersonID)
INSERT INTO IndividualClient(PersonID, ClientID)
VALUES (@PersonID, @ClientID)
END
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania klienta: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddEmployee @CompanyName varchar(255),
    @FirstName varchar(255),
    @LastName varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY IF EXISTS(
        SELECT *
        FROM Employees
            INNER JOIN Person P on Employees.PersonID = P.PersonID
            INNER JOIN Companies C on Employees.CompanyID = C.ClientID
        WHERE @FirstName = P.FirstName
            AND @LastName = P.LastName
            AND @CompanyName = C.CompanyName
    ) BEGIN;
THROW 52000,
N'Pracownik jest już w bazie',
1
END IF NOT EXISTS(
    SELECT *
    FROM Companies
    WHERE @CompanyName = CompanyName
) BEGIN;
THROW 52000,
'Nie ma takiej firmy',
1
end
DECLARE @PersonID INT
DECLARE @CompanyID INT
SELECT @PersonID = ISNULL(MAX(PersonID), 0) + 1
FROM Person
SELECT @CompanyID = ClientID
FROM Companies
WHERE @CompanyName = CompanyName
INSERT INTO Person(FirstName, LastName, PersonID)
VALUES (@FirstName, @LastName, @PersonID)
INSERT INTO Employees(PersonID, CompanyID)
VALUES (@PersonID, @CompanyID)
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania pracownika: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddOrder @ClientID int,
    @Takeaway bit,
    @Reservation bit,
    @Paid bit,
    @PrefDate datetime,
    @StartDate datetime,
    @EndDate datetime AS BEGIN
SET NOCOUNT ON BEGIN TRY IF ISNULL(@PrefDate, '9999-01-01') < GETDATE() BEGIN;
THROW 52000,
N 'Niepoprawna data odbioru zamówienia na wynos',
1
END IF @EndDate < GETDATE()
OR @StartDate < GETDATE() BEGIN;
THROW 52000,
'Niepoprawna data rezerwacji',
1
end
DECLARE @OrderID INT
Declare @ReservationIDIns INT = null
Declare @TakeAwayIDIns INT = null
Declare @ReservationID INT = null
SELECT @ReservationID = ISNULL(MAX(ReservationID), 0) + 1
FROM Reservation
Declare @TakeawayID INT = null
SELECT @TakeawayID = ISNULL(MAX(TakeawayID), 0) + 1
FROM OrdersTakeaways
DECLARE @CurrentMenuID int
SELECT TOP 1 @CurrentMenuId = MenuID
FROM Menu M
WHERE GETDATE() BETWEEN M.StartDate AND M.EndDate
SELECT @OrderID = ISNULL(MAX(OrderID), 0) + 1
FROM Orders IF (@Takeaway = 1) BEGIN
SET @TakeAwayIDIns = @TakeawayID
INSERT INTO OrdersTakeaways(TakeawayID, PrefDate)
VALUES (@TakeawayID, @PrefDate)
END IF (@Reservation = 1) BEGIN
SET @ReservationIDIns = @ReservationID
INSERT INTO Reservation(ReservationID, StartDate, EndDate, Status)
VALUES (@ReservationID, @StartDate, @EndDate, 'Pending')
END
INSERT INTO Orders(
        OrderID,
        ClientID,
        OrderDate,
        TakeawayID,
        ReservationID,
        Paid,
        MenuID
    )
VALUES (
        @OrderID,
        @ClientID,
        GETDATE(),
        @TakeawayIDIns,
        @ReservationIDIns,
        @Paid,
        @CurrentMenuID
    )
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodawania zamówienia: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddProductToMenu @Name varchar(255),
    @Price money,
    @MenuID int AS BEGIN
SET NOCOUNT ON BEGIN TRY IF NOT EXISTS(
        SELECT *
        FROM Products
        WHERE Name = @Name
    ) BEGIN;
THROW 52000,
'Nie ma takiej potrawy',
1
END IF NOT EXISTS(
    SELECT *
    FROM Menu
    WHERE MenuID = @MenuID
) BEGIN;
THROW 52000,
'Nie ma takiego menu',
1
END
DECLARE @ProductID INT
SELECT @ProductID = ProductID
FROM Products
WHERE Name = @Name
DECLARE @StartDate date
SELECT TOP 1 @StartDate = StartDate
FROM Menu
WHERE MenuID = @MenuID
DECLARE @EndDate date
SELECT TOP 1 @EndDate = EndDate
FROM Menu
WHERE MenuID = @MenuID
INSERT INTO Menu(MenuID, StartDate, EndDate, Price, ProductID)
VALUES (
        @MenuID,
        @StartDate,
        @EndDate,
        @Price,
        @ProductID
    );
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania potrawy do menu: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddProduct @Name varchar(255),
    @CategoryName varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY IF EXISTS(
        SELECT *
        FROM Products
        WHERE Name = @Name
    ) BEGIN;
THROW 52000,
N'Potrawa jest już dodana',
1
END IF NOT EXISTS(
    SELECT *
    FROM Category
    WHERE CategoryName = @CategoryName
) BEGIN;
THROW 52000,
'Nie ma takiej kategorii',
1
END
DECLARE @CategoryID INT
SELECT @CategoryID = CategoryID
FROM Category
WHERE CategoryName = @CategoryName
DECLARE @ProductID INT
SELECT @ProductID = ISNULL(MAX(ProductID), 0) + 1
FROM Products
INSERT INTO Products(ProductID, Name, CategoryID)
VALUES (@ProductID, @Name, @CategoryID);
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania potrawy: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1;
END CATCH
END
go CREATE PROCEDURE uspAddProductToOrder @OrderID int,
    @Quantity int,
    @ProductName varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY IF NOT EXISTS(
        SELECT *
        FROM Products
        WHERE Name = @ProductName
    ) BEGIN;
THROW 52000,
'Nie ma takiej potrawy',
1
END IF NOT EXISTS(
    SELECT *
    FROM Orders
    WHERE OrderID = @OrderID
) BEGIN;
THROW 52000,
'Nie ma takiego zamowienia',
1
END IF NOT EXISTS(
    SELECT *
    FROM CurrentMenu
    WHERE Name = @ProductName
) BEGIN;
THROW 52000,
'Nie mozna zamowic tego produktu, gdyz nie ma go obecnie w menu',
1
end IF EXISTS (
    SELECT *
    FROM Products P
        INNER JOIN Category C on P.CategoryID = C.CategoryID
    WHERE @ProductName = P.Name
) BEGIN;
DECLARE @OrderDate DATE
SELECT @OrderDate = OrderDate
FROM Orders
WHERE OrderID = @OrderID IF DATEPART(WEEKDAY, @OrderDate) != 4
    AND DATEPART(WEEKDAY, @OrderDate) != 5
    AND DATEPART(WEEKDAY, @OrderDate) != 6 BEGIN;
THROW 52000,
N 'Nieprawidłowa data złożenia zamówienia na owoce morza',
1
end
end
DECLARE @ProductID INT
SELECT @ProductID = ProductID
FROM Products
WHERE Name = @ProductName
INSERT INTO OrderDetails(OrderID, Quantity, ProductID)
VALUES (@OrderID, @Quantity, @ProductID)
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania produktu do zamowienia: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddReservation @ClientID int,
    @StartDate datetime,
    @EndDate datetime,
    @Status varchar(255),
    @People int AS BEGIN
SET NOCOUNT ON BEGIN TRY IF NOT EXISTS(
        SELECT *
        FROM Clients
        WHERE ClientID = @ClientID
    ) BEGIN;
THROW 52000,
'Nie ma takiego klienta',
1
end IF @People < 2 BEGIN;
THROW 52000,
N 'Nie można złożyć zamówienia na 1 osobę',
1
end
DECLARE @CurWK float
SET @CurWK = [dbo].[udfGetActualReservationWK]()
DECLARE @AmountOrdered float
SET @AmountOrdered = [dbo].[udfGetClientsOrderAmount](@ClientID) IF @AmountOrdered < @CurWK BEGIN;
THROW 52000,
N'Klient nie zamówił wystarczająco razy by rezerwować.',
1
end
DECLARE @ReservationID INT
DECLARE @PersonID INT
SELECT @ReservationID = ISNULL(MAX(ReservationID), 0) + 1
FROM Reservation
INSERT INTO Reservation(
        ReservationID,
        StartDate,
        EndDate,
        Status,
        People
    )
VALUES (
        @ReservationID,
        @StartDate,
        @EndDate,
        @Status,
        @People
    );
IF EXISTS(
    SELECT *
    FROM Companies
    WHERE ClientID = @ClientID
) BEGIN
INSERT INTO ReservationCompany(ReservationID, ClientID, PersonID)
VALUES (@ReservationID, @ClientID, null)
end
ELSE BEGIN
SELECT @PersonID = PersonID
FROM IndividualClient
WHERE ClientID = @ClientID
INSERT INTO ReservationIndividual(ReservationID, ClientID, PersonID)
VALUES (@ReservationID, @ClientID, @PersonID)
END
END TRY BEGIN CATCH
DECLARE @errorMsg nvarchar(2048) = N'Błąd dodania rezerwacji: ' + ERROR_MESSAGE();
THROW 52000,
@errorMsg,
1
END CATCH
END
go CREATE PROCEDURE uspAddTable @Size int AS BEGIN
SET NOCOUNT ON BEGIN TRY
DECLARE @TableID INT
SELECT @TableID = ISNULL(MAX(TableID), 0) + 1
FROM Tables
INSERT INTO Tables(TableID, Size)
VALUES(@TableID, @Size);
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodawania stolika: ' + ERROR_MESSAGE();
THROW 5200,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspAddTableToReservation @ReservationID int,
    @TableID int AS BEGIN
SET NOCOUNT ON BEGIN TRY IF NOT EXISTS(
        SELECT *
        FROM Tables
        WHERE TableID = @TableID
    ) BEGIN;
THROW 52000,
'Nie ma takiego stolika',
1
END IF NOT EXISTS(
    SELECT *
    FROM Reservation
    WHERE ReservationID = @ReservationID
) BEGIN;
THROW 52000,
'Nie ma takiej rezerwacji',
1
END
INSERT INTO ReservationDetails(ReservationID, TableID)
VALUES (@ReservationID, @TableID)
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd dodania stolika do rezerwacji: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspChangeOrderPaymentStatus @OrderID int,
    @Paid bit AS BEGIN
SET NOCOUNT ON BEGIN TRY BEGIN
UPDATE Orders
SET Paid = @Paid
WHERE Orders.OrderID = @OrderID
END
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd zmiany statusu platnosci: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspChangeReservationStatus @ReservationID int,
    @Status varchar(255) AS BEGIN
SET NOCOUNT ON BEGIN TRY BEGIN
UPDATE Reservation
SET Status = @Status
WHERE Reservation.ReservationID = @ReservationID
END
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd edytowania rezerwacji: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go CREATE PROCEDURE uspModifyTable @TableID int,
    @Size int AS BEGIN
SET NOCOUNT ON BEGIN TRY IF NOT EXISTS(
        SELECT *
        FROM Tables
        WHERE TableID = @TableID
    ) BEGIN;
THROW 52000,
'Nie ma takiego stolika.',
1
END IF @Size < 2 BEGIN;
THROW 52000,
N'Stolik musi mieć przynajmniej 2 miejsca.',
1
END IF @Size IS NOT NULL BEGIN
UPDATE Tables
SET Size = @Size
WHERE Tables.TableID = @TableID
END
END TRY BEGIN CATCH
DECLARE @msg nvarchar(2048) = N'Błąd edytowania stolika: ' + ERROR_MESSAGE();
THROW 52000,
@msg,
1
END CATCH
END
go