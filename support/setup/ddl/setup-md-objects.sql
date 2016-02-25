/*
#
# Adaptive BI Framework 3.0
#
# Last Revision: 2
# Last Date: 2016-02-25
# Last Author: dmauri
#
*/

use [AdaptiveBI30_MD];
go


/*

[md].[extract_phase]

*/

if ( object_id('[md].[extract_phase]') is not null )
    drop table [md].[extract_phase];
go

create table [md].[extract_phase]
(
  [source_object_name] sysname not null primary key ,
  [active_for_load] char(1)
);

alter table [md].[extract_phase] with check add  constraint [ck__active_for_load] check (([active_for_load]='N' or [active_for_load]='Y'));
go

alter table [md].[extract_phase] check constraint [ck__active_for_load];
go
