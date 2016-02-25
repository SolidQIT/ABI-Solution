/*
#
# Adaptive BI Framework 3.0
# Sample Reference Solution
#
# Last Revision: 1
# Last Date: 2016-02-25
# Last Author: dmauri
#
# Notes:
# The script must be executed *after* having created and executed the ETL-STG SSIS solution
#
*/

use [AdaptiveBI30_STG]
go

if (object_id('[proxy_cfg].PersonType') is not null) drop synonym [proxy_cfg].PersonType;
go
create synonym [proxy_cfg].PersonType for AdaptiveBI30_CFG.cfg.PersonType

if (object_id('[proxy_cfg].StoreSize') is not null) drop synonym [proxy_cfg].StoreSize;
go
create synonym [proxy_cfg].StoreSize for AdaptiveBI30_CFG.cfg.StoreSize

if (object_id('[proxy_cfg].OrderStatus') is not null) drop synonym [proxy_cfg].OrderStatus;
go
create synonym [proxy_cfg].OrderStatus for AdaptiveBI30_CFG.cfg.OrderStatus
go

if (object_id('etl.vw_dim_Products') is not null) drop view etl.vw_dim_Products;
go
create view etl.vw_dim_Products
as
select 
	bk_ProductID = ProductID,
	bk_ProductSubcategoryID = sc.ProductSubcategoryID,
	bk_ProductCategoryID = c.ProductCategoryID,
	p.ProductNumber,
	ProductName = ISNULL(p.Name, 'N/A'),
	SubcategoryName = ISNULL(sc.Name, 'N/A'),
	CategoryName = ISNULL(c.Name, 'N/A')
from 
	stg.Production__Product p
left join
	stg.Production__ProductSubCategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
left join
	stg.Production__ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
go

if (object_id('etl.vw_dim_Customers') is not null) drop view etl.vw_dim_Customers;
go
create view etl.vw_dim_Customers
as
select
	bk_CustomerID = c.CustomerID,
	bk_PersonID = p.BusinessEntityID,
	bk_PersonTypeID = pt.PersonTypeID,
	bk_StoreID = s.BusinessEntityID,
	bk_StoreSizeID = ss.StoreSizeID,
	PersonFullName = ISNULL(p.FirstName + ' ' + p.LastName, 'N/A'),
	PersonType = ISNULL(pt.PersonType, 'N/A') ,
	StoreName = ISNULL(s.Name, 'N/A'),
	ss.StoreSize,
	s.SquareFeet
from
	stg.Sales__Customer c
left join
	stg.Person__Person p on c.PersonID = p.BusinessEntityID
left join
	proxy_cfg.PersonType pt on p.PersonType = pt.PersonTypeID
left join
	stg.Sales__Store s on c.StoreID = s.BusinessEntityID
left join
	proxy_cfg.StoreSize ss on s.SquareFeet between ss.FromSquareFeet and ss.ToSquareFeet
go


if (object_id('etl.vw_fact_Orders') is not null) drop view etl.vw_fact_Orders;
go

create view etl.vw_fact_Orders
as
select
	bk_CustomerID = CustomerID,
	bk_OrderStatusID = [Status],
	bk_OnlineOrderFlagID = cast(OnlineOrderFlag as tinyint),
	bk_SalesOrderID = SalesOrderID,
	id_dim_Date_OrderDate = od.result,
	NetAmount = SubTotal,
	TaxAmount = TaxAmt,
	FreightAmount = Freight,
	TotalAmount = TotalDue
from
	stg.Sales__SalesOrderHeader soh
cross apply
	util.fn_DateToInt(soh.OrderDate) od
go

if (object_id('etl.vw_fact_OrderDetails') is not null) drop view etl.vw_fact_OrderDetails;
go

create view etl.vw_fact_OrderDetails
as
select
	bk_CustomerID = soh.CustomerID,
	bk_OrderStatusID = [Status],
	bk_OnlineOrderFlagID = cast(OnlineOrderFlag as tinyint),
	bk_ProductID = sod.ProductID,
	bk_SalesOrderID = soh.SalesOrderID,
	bk_SalesOrderDetailID = sod.SalesOrderDetailID,
	id_dim_Date_OrderDate = od.result,
	sod.OrderQty,
	sod.LineTotal
from
	stg.Sales__SalesOrderHeader soh
inner join
	stg.Sales__SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
cross apply
	util.fn_DateToInt(soh.OrderDate) od
go


if (object_id('etl.vw_factless_OrderReasons') is not null) drop view etl.vw_factless_OrderReasons;
go

create view etl.vw_factless_OrderReasons
as
select
	bk_SalesOrderID = soh.SalesOrderID,
	bk_SalesReasonID = SalesReasonID
from
	stg.Sales__SalesOrderHeader soh
left join
	stg.Sales__SalesOrderHeaderSalesReason sr on soh.SalesOrderID = sr.SalesOrderID
go

if (object_id('etl.vw_dim_SalesReasons') is not null) drop view etl.vw_dim_SalesReasons;
go

create view etl.vw_dim_SalesReasons
as
select
	bk_SalesReasonID = SalesReasonID,
	Reason = Name,
	ReasonType
from
	stg.Sales__SalesReason
go

if (object_id('etl.vw_dim_Orders') is not null) drop view etl.vw_dim_Orders;
go

create view etl.vw_dim_Orders
as
select distinct
	bk_SalesOrderID = SalesOrderID
from
	stg.Sales__SalesOrderHeader
go

if (object_id('etl.vw_dim_OrdersInfo') is not null) drop view etl.vw_dim_OrdersInfo;
go

create view etl.vw_dim_OrdersInfo
as
select
	bk_OnlineOrderFlagID = cast(OrderType.OnlineOrderFlagID as tinyint),
	OrderType.OnlineOrderFlag,
	bk_OrderStatusID = os.OrderStatusID,
	os.OrderStatus
from
	(values (0, N'Store Order'), (1, N'Online Order')) as OrderType (OnlineOrderFlagID, OnlineOrderFlag)
cross join
	proxy_cfg.OrderStatus os
go

if (object_id('etl.vw_dim_Dates') is not null) drop view etl.vw_dim_Dates;
go

create view etl.vw_dim_Dates
as
with cte as
(
	select 
		FromDate = cast(min(OrderDate) as date),
		ToDate = cast(max(OrderDate) as date)
	from
		stg.Sales__SalesOrderHeader
), 
cteCalendar as (
	select
		CalendarDate = cast(dateadd(DAY, num - 1, FromDate) as date)
	from
		util.Nums nums
	cross join
		cte
	where
		dateadd(DAY, num - 1, FromDate) <= ToDate
)
select
	id_dim_Dates = d.result,
	CalendarYear = YEAR(CalendarDate),
	CalendarMonth = MONTH(CalendarDate),
	CalendarDate
from
	cteCalendar c
cross apply
	util.fn_DateToInt(c.CalendarDate) d
	