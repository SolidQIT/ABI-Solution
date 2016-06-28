/*
#
# Adaptive BI Framework 3.0
# Sample Reference Solution
#
# Last Revision: 2
# Last Date: 2016-06-28
# Last Author: dmauri
#
# Notes:
# The script must be executed *after* having created and executed the ETL-STG SSIS solution
#
*/

USE [AdaptiveBI30_STG]
GO

IF (OBJECT_ID('[proxy_cfg].PersonType') IS NOT NULL) DROP SYNONYM [proxy_cfg].PersonType;
GO
CREATE SYNONYM [proxy_cfg].PersonType FOR AdaptiveBI30_CFG.cfg.PersonType

IF (OBJECT_ID('[proxy_cfg].StoreSize') IS NOT NULL) DROP SYNONYM [proxy_cfg].StoreSize;
GO
CREATE SYNONYM [proxy_cfg].StoreSize FOR AdaptiveBI30_CFG.cfg.StoreSize

IF (OBJECT_ID('[proxy_cfg].OrderStatus') IS NOT NULL) DROP SYNONYM [proxy_cfg].OrderStatus;
GO
CREATE SYNONYM [proxy_cfg].OrderStatus FOR AdaptiveBI30_CFG.cfg.OrderStatus
GO

IF (OBJECT_ID('etl.vw_dim_Products') IS NOT NULL) DROP VIEW etl.vw_dim_Products;
GO
CREATE VIEW etl.vw_dim_Products
AS
SELECT 
	bk_ProductID = ProductID,
	bk_ProductSubcategoryID = sc.ProductSubcategoryID,
	bk_ProductCategoryID = c.ProductCategoryID,
	p.ProductNumber,
	ProductName = ISNULL(p.Name, 'N/A'),
	SubcategoryName = ISNULL(sc.Name, 'N/A'),
	CategoryName = ISNULL(c.Name, 'N/A')
FROM 
	stg.Production__Product p
LEFT JOIN
	stg.Production__ProductSubCategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN
	stg.Production__ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GO

IF (OBJECT_ID('etl.vw_dim_Customers') IS NOT NULL) DROP VIEW etl.vw_dim_Customers;
GO
CREATE VIEW etl.vw_dim_Customers
AS
SELECT
	bk_CustomerID = c.CustomerID,
	bk_PersonID = p.BusinessEntityID,
	bk_PersonTypeID = pt.PersonTypeID,
	bk_StoreID = s.BusinessEntityId,
	bk_StoreSizeID = ss.StoreSizeID,
	PersonFullName = ISNULL(p.FirstName + ' ' + p.LastName, 'N/A'),
	PersonType = ISNULL(pt.PersonType, 'N/A') ,
	StoreName = ISNULL(s.Name, 'N/A'),
	ss.StoreSize,
	s.SquareFeet
FROM
	stg.Sales__Customer c
LEFT JOIN
	stg.Person__Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN
	proxy_cfg.PersonType pt ON p.PersonType = pt.PersonTypeID
LEFT JOIN
	stg.Sales__Store s ON c.StoreID = s.BusinessEntityId
LEFT JOIN
	proxy_cfg.StoreSize ss ON s.SquareFeet BETWEEN ss.FromSquareFeet AND ss.ToSquareFeet
GO


IF (OBJECT_ID('etl.vw_fact_Orders') IS NOT NULL) DROP VIEW etl.vw_fact_Orders;
GO

CREATE VIEW etl.vw_fact_Orders
AS
SELECT
	bk_CustomerID = CustomerID,
	bk_OrderStatusID = [Status],
	bk_OnlineOrderFlagID = CAST(OnlineOrderFlag AS TINYINT),
	bk_SalesOrderID = SalesOrderID,
	bk_ShipToAddressID = ShipToAddressID,
	bk_BillToAddressID = BillToAddressID,
	id_dim_Date_OrderDate = od.result,
	NetAmount = SubTotal,
	TaxAmount = TaxAmt,
	FreightAmount = Freight,
	TotalAmount = TotalDue
FROM
	stg.Sales__SalesOrderHeader soh
CROSS APPLY
	util.fn_DateToInt(soh.OrderDate) od
GO

IF (OBJECT_ID('etl.vw_fact_OrderDetails') IS NOT NULL) DROP VIEW etl.vw_fact_OrderDetails;
GO

CREATE VIEW etl.vw_fact_OrderDetails
AS
SELECT
	bk_CustomerID = soh.CustomerID,
	bk_OrderStatusID = [Status],
	bk_OnlineOrderFlagID = CAST(OnlineOrderFlag AS TINYINT),
	bk_ProductID = sod.ProductID,
	bk_SalesOrderID = soh.SalesOrderID,
	bk_SalesOrderDetailID = sod.SalesOrderDetailID,
	id_dim_Date_OrderDate = od.result,
	sod.OrderQty,
	sod.LineTotal
FROM
	stg.Sales__SalesOrderHeader soh
INNER JOIN
	stg.Sales__SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
CROSS APPLY
	util.fn_DateToInt(soh.OrderDate) od
GO


IF (OBJECT_ID('etl.vw_factless_OrderReasons') IS NOT NULL) DROP VIEW etl.vw_factless_OrderReasons;
GO

CREATE VIEW etl.vw_factless_OrderReasons
AS
SELECT
	bk_SalesOrderID = soh.SalesOrderID,
	bk_SalesReasonID = SalesReasonID
FROM
	stg.Sales__SalesOrderHeader soh
LEFT JOIN
	stg.Sales__SalesOrderHeaderSalesReason sr ON soh.SalesOrderID = sr.SalesOrderID
GO

IF (OBJECT_ID('etl.vw_dim_SalesReasons') IS NOT NULL) DROP VIEW etl.vw_dim_SalesReasons;
GO

CREATE VIEW etl.vw_dim_SalesReasons
AS
SELECT
	bk_SalesReasonID = SalesReasonID,
	Reason = Name,
	ReasonType
FROM
	stg.Sales__SalesReason
GO

IF (OBJECT_ID('etl.vw_dim_Orders') IS NOT NULL) DROP VIEW etl.vw_dim_Orders;
GO

CREATE VIEW etl.vw_dim_Orders
AS
SELECT DISTINCT
	bk_SalesOrderID = SalesOrderID
FROM
	stg.Sales__SalesOrderHeader
GO

IF (OBJECT_ID('etl.vw_dim_OrdersInfo') IS NOT NULL) DROP VIEW etl.vw_dim_OrdersInfo;
GO

CREATE VIEW etl.vw_dim_OrdersInfo
AS
SELECT
	bk_OnlineOrderFlagID = CAST(OrderType.OnlineOrderFlagID AS TINYINT),
	OrderType.OnlineOrderFlag,
	bk_OrderStatusID = os.OrderStatusID,
	os.OrderStatus
FROM
	(VALUES (0, N'Store Order'), (1, N'Online Order')) AS OrderType (OnlineOrderFlagID, OnlineOrderFlag)
CROSS JOIN
	proxy_cfg.OrderStatus os
GO

IF (OBJECT_ID('etl.vw_dim_Dates') IS NOT NULL) DROP VIEW etl.vw_dim_Dates;
GO

CREATE VIEW etl.vw_dim_Dates
AS
WITH cte AS
(
	SELECT 
		FromDate = CAST(MIN(OrderDate) AS DATE),
		ToDate = CAST(MAX(OrderDate) AS DATE)
	FROM
		stg.Sales__SalesOrderHeader
), 
cteCalendar AS (
	SELECT
		CalendarDate = CAST(DATEADD(DAY, num - 1, FromDate) AS DATE)
	FROM
		util.nums nums
	CROSS JOIN
		cte
	WHERE
		DATEADD(DAY, num - 1, FromDate) <= ToDate
)
SELECT
	id_dim_Dates = d.result,
	CalendarYear = YEAR(CalendarDate),
	CalendarMonth = MONTH(CalendarDate),
	CalendarDate
FROM
	cteCalendar c
CROSS APPLY
	util.fn_DateToInt(c.CalendarDate) d
GO

IF (OBJECT_ID('etl.vw_dim_Addresses') IS NOT NULL) DROP VIEW etl.vw_dim_Addresses;
GO
CREATE VIEW etl.vw_dim_Addresses
AS
SELECT
	AddressID AS bk_AddressID,
	StateProvinceID AS bk_StateProvinceID,
	CountryRegionCode AS bk_CountryRegionCode,
	StateProvince,
	CountryRegion,
	PostalCode,
	City
FROM
	[stg].[Person__Address]