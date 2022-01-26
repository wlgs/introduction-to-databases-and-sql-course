create trigger TR_ProperDiscountVar on DiscountVars for
insert as BEGIN if (
        select COUNT(*)
        from inserted
    ) > 1 begin RAISERROR('Dodawaj rabaty pojedynczo! ', 16, 1) ROLLBACK TRANSACTION
end
else if (
    select R1
    from inserted
) not between 0 and 1 BEGIN RAISERROR('Wprowadzono niepoprawny rabat R1', 16, 1) ROLLBACK TRANSACTION
END
else if (
    select R2
    from inserted
) not between 0 and 1 BEGIN RAISERROR('Wprowadzono niepoprawny rabat R2', 16, 1) ROLLBACK TRANSACTION
END
END
go create trigger TR_ProperMinOrdersVar on DiscountVars for
insert as BEGIN if (
        select COUNT(*)
        from inserted
    ) > 1 begin RAISERROR('Dodawaj rabaty pojedynczo! ', 16, 1) ROLLBACK TRANSACTION
end
else if (
    select Z1
    from inserted
) <= 0 BEGIN RAISERROR('Wprowadzono niepoprawny rabat Z1', 16, 1) ROLLBACK TRANSACTION
END
END
go CREATE TRIGGER TR_DeleteOrderDetails ON OrderDetails FOR DELETE AS BEGIN
SET NOCOUNT ON;
DELETE FROM OrderDetails
WHERE OrderID in (
        select O.OrderID
        from Orders O
            inner join Reservation R on O.ReservationID = R.ReservationID
        where R.Status = 'Canceled'
    )
end
go CREATE TRIGGER TR_SeaFoodCheckMonday ON OrderDetails
AFTER
INSERT AS BEGIN
SET NOCOUNT ON;
IF EXISTS(
    SELECT *
    FROM inserted AS I
        INNER JOIN Orders AS O ON O.OrderID = I.OrderID
        INNER JOIN Products AS P ON P.ProductID = I.ProductID
        INNER JOIN OrdersTakeaways AS OT ON O.TakeawayID = OT.TakeawayID
        INNER JOIN Reservation AS R ON O.ReservationID = R.ReservationID
    WHERE (
            DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Thursday'
            AND DATEDIFF(day, O.OrderDate, OT.PrefDate) <= 2
            AND CategoryID = 6
        )
        OR (
            DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Friday'
            AND DATEDIFF(day, O.OrderDate, OT.PrefDate) <= 3
            AND CategoryID = 6
        )
        OR (
            DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Saturday'
            AND DATEDIFF(day, O.OrderDate, OT.PrefDate) <= 4
            AND CategoryID = 6
        )
        OR (
            DATENAME(WEEKDAY, R.StartDate) LIKE 'Thursday'
            AND DATEDIFF(day, O.OrderDate, R.StartDate) <= 2
            AND CategoryID = 6
        )
        OR (
            DATENAME(WEEKDAY, R.StartDate) LIKE 'Friday'
            AND DATEDIFF(day, O.OrderDate, R.StartDate) <= 3
            AND CategoryID = 6
        )
        OR (
            DATENAME(WEEKDAY, R.StartDate) LIKE 'Saturday'
            AND DATEDIFF(day, O.OrderDate, R.StartDate) <= 4
            AND CategoryID = 6
        )
) BEGIN;
THROW 50001,
'Takie zamówienie winno być złożone maksymalnie do poniedziałku poprzedzającego zamówienie. ',
1
END
END
go