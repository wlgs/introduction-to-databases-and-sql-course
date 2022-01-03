--adresy all ludzi z library

SELECT j.member_no, street + ' ' + state + ' ' + zip
FROM juvenile j
         INNER JOIN member mi2 on j.member_no = mi2.member_no
         INNER JOIN adult a on a.member_no = j.adult_member_no
UNION
SELECT a.member_no, street + ' ' + state + ' ' + zip
FROM member mi1
         INNER JOIN adult a on a.member_no = mi1.member_no


--PRACOWNICY bez podwladnych
USE Northwind
SELECT EmployeeID
FROM Employees E
WHERE NOT EXISTS(SELECT E2.EmployeeID FROM Employees E2 WHERE E2.Reportsto = E.EmployeeID)

--PRACOWNICY z podwladnymi
SELECT EmployeeID
FROM Employees E
WHERE EXISTS(SELECT E2.EmployeeID FROM Employees E2 WHERE E2.Reportsto = E.EmployeeID)