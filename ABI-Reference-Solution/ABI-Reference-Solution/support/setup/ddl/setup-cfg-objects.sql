/*
#
# Adaptive BI Framework 3.0
#
*/

use [AdaptiveBI30_CFG];
go


/*

[cfg].[extract_phase]

*/

if ( object_id('[cfg].[extract_phase]') is not null )
    drop table [cfg].[extract_phase];
go

create table [cfg].[extract_phase]
(
  [source_object_name] sysname not null primary key ,
  [active_for_load] char(1)
);

alter table [cfg].[extract_phase] with check add  constraint [ck__active_for_load] check (([active_for_load]='N' or [active_for_load]='Y'));
go

alter table [cfg].[extract_phase] check constraint [ck__active_for_load];
go
