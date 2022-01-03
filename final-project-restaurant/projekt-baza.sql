CREATE TABLE Category
(
    CategoryID   int          NOT NULL,
    CategoryName varchar(255) NOT NULL,
    CONSTRAINT Category_pk PRIMARY KEY (CategoryID)
)

CREATE TABLE Clients
(
    ClientID   int          NOT NULL,
    City       varchar(255) NOT NULL,
    Street     varchar(255) NOT NULL,
    PostalCode varchar(255) NOT NULL,
    Phone      varchar(32)  NOT NULL,
    Email      varchar(255) NOT NULL,
    CONSTRAINT ValidPostalCode CHECK (PostalCode LIKE '[0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT ValidEmail CHECK (Email LIKE '%@%'),
    CONSTRAINT UniqueEmail UNIQUE (Email),
    CONSTRAINT ValidPhone CHECK (Phone LIKE '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT UniquePhone UNIQUE (Phone),
    CONSTRAINT Clients_pk PRIMARY KEY (ClientID)
)

CREATE TABLE Companies
(
    ClientID    int          NOT NULL,
    CompanyName varchar(255) NOT NULL,
    NIP         varchar(32)  NOT NULL,
    CONSTRAINT ValidNIP CHECK (NIP LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT UniqueNIP UNIQUE (NIP),
    CONSTRAINT Companies_pk PRIMARY KEY (ClientID)
)


CREATE TABLE DiscountDetails
(
    VarID     int      NOT NULL,
    Value     float(2) NOT NULL,
    StartDate int      NOT NULL,
    EndDate   int      NOT NULL,
    CONSTRAINT ValidDate CHECK (EndDate > StartDate),
    CONSTRAINT ValidValue CHECK (Value > 0 AND Value < 1)
)


CREATE TABLE DiscountVars
(
    VarID      int        NOT NULL,
    VarName    varchar(2) NOT NULL,
    DiscountID int        NOT NULL,
    CONSTRAINT DiscountVars_pk PRIMARY KEY (VarID)
)


CREATE TABLE Discounts
(
    DiscountID  int      NOT NULL,
    AppliedDate datetime NOT NULL,
    ClientID    int      NOT NULL,
    CONSTRAINT Discounts_pk PRIMARY KEY (DiscountID)
)


CREATE TABLE Employees
(
    PersonID  int NOT NULL,
    CompanyID int NOT NULL,
    CONSTRAINT Employees_pk PRIMARY KEY (PersonID)
)


CREATE TABLE IndividualClient
(
    PersonID int NOT NULL,
    ClientID int NOT NULL,
    CONSTRAINT IndividualClient_pk PRIMARY KEY (ClientID)
)


CREATE TABLE Menu
(
    MenuID    int   NOT NULL,
    StartDate date  NOT NULL,
    EndDate   date  NULL,
    Price     money NOT NULL,
    ProductID int   NOT NULL,
    CONSTRAINT ValidMenuDate CHECK (EndDate > StartDate),
    CONSTRAINT ValidPrice CHECK (Price > 0),
    CONSTRAINT Menu_pk PRIMARY KEY (MenuID)
)


CREATE TABLE OrderDetails
(
    OrderID   int NOT NULL,
    Quantity  int NOT NULL,
    ProductID int NOT NULL,
    CONSTRAINT ValidQuantity CHECK (Quantity > 0),
    CONSTRAINT OrderDetails_pk PRIMARY KEY (OrderID)
)


CREATE TABLE Orders
(
    OrderID       int      NOT NULL,
    ClientID      int      NOT NULL,
    OrderDate     datetime NOT NULL,
    TakeawayID    int      NULL,
    ReservationID int      NULL,
    Paid          bit      NOT NULL,
    CONSTRAINT Orders_pk PRIMARY KEY (OrderID)
)


CREATE TABLE OrdersTakeaways
(
    TakeawayID int      NOT NULL,
    PrefDate   datetime NOT NULL,
    CONSTRAINT ValidPrefDate CHECK (PrefDate > GETDATE()),
    CONSTRAINT OrdersTakeaways_pk PRIMARY KEY (TakeawayID)
)


CREATE TABLE Person
(
    FirstName varchar(255) NOT NULL,
    LastName  varchar(255) NOT NULL,
    PersonID  int          NOT NULL,
    CONSTRAINT Person_pk PRIMARY KEY (PersonID)
)

CREATE TABLE Products
(
    CategoryID  int          NOT NULL,
    ProductID   int          NOT NULL,
    Name        varchar(255) NOT NULL,
    Description varchar(255) NOT NULL DEFAULT 'brak opisu',
    CONSTRAINT MenuItems_pk PRIMARY KEY (ProductID)
)


CREATE TABLE Reservation
(
    ReservationID int         NOT NULL,
    StartDate     datetime    NOT NULL,
    EndDate       datetime    NOT NULL,
    Status        varchar(16) NOT NULL,
    CONSTRAINT ValidReservationDate CHECK (EndDate > StartDate),
    CONSTRAINT Reservation_pk PRIMARY KEY (ReservationID)
)

CREATE TABLE ReservationCompany
(
    ReservationID int NOT NULL,
    ClientID      int NOT NULL,
    PersonID      int NULL,
    CONSTRAINT ReservationCompany_pk PRIMARY KEY (ReservationID)
)


CREATE TABLE ReservationDetails
(
    ReservationID int NOT NULL,
    TableID       int NOT NULL
)


CREATE TABLE ReservationIndividual
(
    ReservationID int NOT NULL,
    ClientID      int NOT NULL,
    PersonID      int NOT NULL,
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID)
)


CREATE TABLE ReservationVar
(
    WZ               int      NOT NULL,
    WK               int      NOT NULL,
    ReservationVarID int      NOT NULL,
    StartDate        datetime NOT NULL,
    EndDate          datetime NULL,
    CONSTRAINT ValidReservationVar CHECK (WZ > 0 AND WK > 0 AND ISNULL(EndDate, '9999-12-31 23:59:59') > StartDate ),
    CONSTRAINT ReservationVar_pk PRIMARY KEY (ReservationVarID)
)

CREATE TABLE Tables
(
    TableID int NOT NULL,
    Size    int NOT NULL,
    CONSTRAINT ValidSize CHECK (Size > 0),
    CONSTRAINT Tables_pk PRIMARY KEY (TableID)
)

ALTER TABLE ReservationDetails
    ADD CONSTRAINT Tables_ReservationDetails
        FOREIGN KEY (TableID)
            REFERENCES Tables (TableID)

ALTER TABLE ReservationDetails
    ADD CONSTRAINT ReservationDetails_ReservationIndividual
        FOREIGN KEY (ReservationID)
            REFERENCES ReservationIndividual (ReservationID)

ALTER TABLE ReservationDetails
    ADD CONSTRAINT ReservationDetails_ReservationCompany
        FOREIGN KEY (ReservationID)
            REFERENCES ReservationCompany (ReservationID)

ALTER TABLE ReservationIndividual
    ADD CONSTRAINT ReservationIndividual_Reservation
        FOREIGN KEY (ReservationID)
            REFERENCES Reservation (ReservationID)

ALTER TABLE Products
    ADD CONSTRAINT Category_MenuItems
        FOREIGN KEY (CategoryID)
            REFERENCES Category (CategoryID)

ALTER TABLE Orders
    ADD CONSTRAINT Reservation_Orders
        FOREIGN KEY (ReservationID)
            REFERENCES Reservation (ReservationID)

ALTER TABLE Orders
    ADD CONSTRAINT Orders_Clients
        FOREIGN KEY (ClientID)
            REFERENCES Clients (ClientID)

ALTER TABLE Orders
    ADD CONSTRAINT Orders_OrdersTakeaways
        FOREIGN KEY (TakeawayID)
            REFERENCES OrdersTakeaways (TakeawayID)

ALTER TABLE Companies
    ADD CONSTRAINT Companies_Clients
        FOREIGN KEY (ClientID)
            REFERENCES Clients (ClientID)

ALTER TABLE Menu
    ADD CONSTRAINT Menu_Products
        FOREIGN KEY (ProductID)
            REFERENCES Products (ProductID)
ALTER TABLE IndividualClient
    ADD CONSTRAINT IndividualClient_Clients
        FOREIGN KEY (ClientID)
            REFERENCES Clients (ClientID)

ALTER TABLE IndividualClient
    ADD CONSTRAINT Person_IndividualClient
        FOREIGN KEY (PersonID)
            REFERENCES Person (PersonID)
ALTER TABLE Employees
    ADD CONSTRAINT Employees_Companies
        FOREIGN KEY (CompanyID)
            REFERENCES Companies (ClientID)

ALTER TABLE Employees
    ADD CONSTRAINT Person_Employees
        FOREIGN KEY (PersonID)
            REFERENCES Person (PersonID)

ALTER TABLE Discounts
    ADD CONSTRAINT Discounts_IndividualClient
        FOREIGN KEY (ClientID)
            REFERENCES IndividualClient (ClientID)
ALTER TABLE DiscountVars
    ADD CONSTRAINT DiscountVars_Discounts
        FOREIGN KEY (DiscountID)
            REFERENCES Discounts (DiscountID)

ALTER TABLE DiscountDetails
    ADD CONSTRAINT DiscountDetails_DiscountVars
        FOREIGN KEY (VarID)
            REFERENCES DiscountVars (VarID)

ALTER TABLE ReservationCompany
    ADD CONSTRAINT Companies_ReservationCompany
        FOREIGN KEY (ClientID)
            REFERENCES Companies (ClientID)

ALTER TABLE ReservationCompany
    ADD CONSTRAINT ReservationCompany_Reservation
        FOREIGN KEY (ReservationID)
            REFERENCES Reservation (ReservationID)

ALTER TABLE OrderDetails
    ADD CONSTRAINT OrderDetails_Orders
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID)

ALTER TABLE OrderDetails
    ADD CONSTRAINT OrderDetails_Products
        FOREIGN KEY (ProductID)
            REFERENCES Products (ProductID)