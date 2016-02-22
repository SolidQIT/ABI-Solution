/*
#
# Adaptive BI Framework 3.0
#
*/

use [AdaptiveBI30_LOG];
go

/*

	[log].[etl_table_load_info]

*/

if ( object_id('[log].[etl_table_load_info]') is not null )
    drop table [log].[etl_table_load_info];
go

create table [log].[etl_table_load_info]
(
  [id] [int] identity(1, 1) not null constraint [pk__etl_table_load_info] primary key clustered ,
  [database_name] [sysname] not null ,
  [schema_name] [sysname] not null ,
  [table_name] [sysname] not null ,
  [type] [char](1) not null ,
  [ssis_server_execution_id] bigint not null ,
  [start_date] [datetime2](7) not null ,
  [end_date] [datetime2](7) null ,
  [status] [char](1) null ,
  [loaded_by] [sysname] null constraint [df__loaded_by] default ( suser_sname() ) ,
  [partition_number] [int] sparse null ,
  [rows] [bigint] sparse null ,
  [inserted_rows] int sparse null ,
  [updated_rows] int sparse null ,
  [deleted_rows] int sparse null ,
  [$xcs] [xml] column_set for all_sparse_columns null
);
go

alter table [log].[etl_table_load_info]  with check add  constraint [ck__table_load_info__status] check  (([status]='F' or [status]='S' or [status]='C'));
go

alter table [log].[etl_table_load_info]  with check add  constraint [ck__table_load_info__type] check  (([type]='F' or [type]='I' or [type]='D' or [type]='M'));
go

/*

	[log].[stp_etl_table_load_info_set_start]

*/

if ( object_id('[log].[stp_etl_table_load_info_set_start]') is not null )
    drop procedure [log].[stp_etl_table_load_info_set_start];
go

create procedure [log].[stp_etl_table_load_info_set_start]
    @databaseName as sysname ,
    @schemaName as sysname ,
    @tableName as sysname ,
    @type as char(1) ,
    @serverExecutionId bigint ,
    @partitionNumber int = null
as
	declare @object_name sysname

	set @object_name = @schemaName + '.' + @tableName

	set @tableName = PARSENAME(@object_name, 1)
	set @schemaName = PARSENAME(@object_name, 2)

	insert  into [log].[etl_table_load_info]
			( [database_name] ,
				[schema_name] ,
				[table_name] ,
				[type] ,
				[start_date] ,
				[ssis_server_execution_id] ,
				[partition_number]
			)
	values  ( @databaseName ,
				@schemaName ,
				@tableName ,
				@type ,
				sysdatetime() ,
				@serverExecutionId ,
				@partitionNumber
			);

	return scope_identity();
go

/*

	[log].[stp_etl_table_load_info_set_end_cs]

*/

if ( object_id('[log].[stp_etl_table_load_info_set_end]') is not null )
    drop procedure [log].[stp_etl_table_load_info_set_end];
go

create procedure [log].[stp_etl_table_load_info_set_end]
    @rowId int ,
    @rows bigint = null ,
    @status char(1)
as
    update  [log].[etl_table_load_info]
    set     [rows] = @rows ,
            [end_date] = sysdatetime() ,
            [status] = @status
    where   [id] = @rowId;
go

/*

	[log].[stp_etl_table_load_info_set_end_cs]

*/

if ( object_id('[log].[stp_etl_table_load_info_set_end_cs]') is not null )
    drop procedure [log].[stp_etl_table_load_info_set_end_cs];
go

create procedure [log].[stp_etl_table_load_info_set_end_cs]
    @rowId int ,
    @xcs xml ,
    @status char(1)
as
    update  [log].[etl_table_load_info]
    set     [$xcs] = @xcs ,
            [end_date] = sysdatetime() ,
            [status] = @status
    where   [id] = @rowId;
go

