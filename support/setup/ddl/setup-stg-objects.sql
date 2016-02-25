/*
#
# Adaptive BI Framework 3.0
#
*/

use [AdaptiveBI30_STG];
go

-- 
-- "nums" Table
--
if ( object_id('[util].[nums]') is not null )
    drop table [util].[nums];
go

create table [util].[nums] 
( 
	[num] int constraint [pk__nums] primary key clustered
);
go

with
	l0 as (select 1 as c union all select 1),
	l1 as (select 1 as c from l0 as a cross join l0 as b),
	l2 as (select 1 as c from l1 as a cross join l1 as b),
	l3 as (select 1 as c from l2 as a cross join l2 as b),
	l4 as (select 1 as c from l3 as a cross join l3 as b),
	l5 as (select 1 as c from l4 as a cross join l4 as b),
	nums as(select row_number() over(order by (select null)) as n from l5)
insert into 
	[util].[nums] 
select 
	top (1000000) n 
from 
	nums order by n;
go

-- 
-- "fn_DateToInt" Function
--
if ( object_id('[util].[fn_DateToInt]') is not null )
    drop function [util].[fn_DateToInt];
go

create function [util].[fn_DateToInt](@sourceValue as date)
returns table 
as
return
	select year(@sourceValue) * 10000 + month(@sourceValue) * 100 + datepart(day, @sourceValue) as result
