/*
#
# Adaptive BI Framework 3.0
# Sample Reference Solution
#
# Last Revision: 2
# Last Date: 2016-02-25
# Last Author: dmauri
#
*/

USE [AdaptiveBI30_CFG]
GO

IF (OBJECT_ID('cfg.StoreSize') IS NOT NULL) DROP TABLE cfg.StoreSize;
GO

CREATE TABLE cfg.StoreSize
(
	StoreSizeID int not null identity primary key,
	FromSquareFeet int not null,
	ToSquareFeet int not null,
	StoreSize nvarchar(100) not null
)
go

INSERT INTO cfg.StoreSize VALUES 
(0, 15000, 'Small'),
(15001, 30000, 'Medium'),
(30001, 50000, 'Big'),
(50001, 99999, 'Huge')
go

IF (OBJECT_ID('cfg.PersonType') IS NOT NULL) DROP TABLE cfg.PersonType;
GO

CREATE TABLE cfg.PersonType
(
	PersonTypeID nchar(2) not null primary key,
	PersonType nvarchar(100) not null
)
go

INSERT INTO cfg.PersonType VALUES
('SC', 'Store Contact'),
('IN', 'Individual (retail) customer'), 
('SP', 'Sales person'),
('EM', 'Employee (non-sales)'),
('VC', 'Vendor contact'),
('GC', 'General contact')
go

IF (OBJECT_ID('cfg.OrderStatus') IS NOT NULL) DROP TABLE cfg.OrderStatus;
GO

CREATE TABLE cfg.OrderStatus
(
	OrderStatusID tinyint not null primary key,
	OrderStatus nvarchar(100) not null
)
go

INSERT INTO cfg.OrderStatus VALUES
(1, 'In process'),
(2, 'Approved'), 
(3, 'Backordered'),
(4, 'Rejected'),
(5, 'Shipped'),
(6, 'Cancelled')
go
