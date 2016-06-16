# Adaptive BI Framework 3.0
## Reference Solution v 1.0.1

### Before you begin
If you have download the solution from the web, Windows will block by default the .dll that contains the plugins. In order to unblock the .dll and then be able to use plugin, you just have the right click on the .dll in the plugin folders and select the option "Unblock" in the Properties window.
If you prefer to use PowerShell to do this, you can just run the following command, that you have to run from inside the solution folder:

    Unblock-File -Path .\plugins\SolidQ.ABI.Plugin.Common\SolidQ.ABI.Plugin.Common.dll

If you don't do this, you won't get any specific error, but the plugin won't be simply recognized.

### Introduction
This sample solution can be used to get started using the Adaptive BI (ABI) Framework 3.0 in order to automate the building of your DWH solution.

The aim of the ABI Framework is to bring down to zero the time needed to develop the E and the L part of and ETL solution, so that BI developers can concentrate mostly on the most added value part of the ETL, the Transformation phase.

To do this a metadata-driven, template-based, engineered approach is needed. The ABI Framework allows you to define your own template and your own metadata structure in order to give you as much as freedom you need.

The sample solution creates a simple Data Warehouse using the Microsoft AdventureWorks 2012 sample database as the data source and provides you some standard templates to deal with the some of most common design pattern in BI

- Staging Table Full Load
- Fact Table Full Load
- Slowly Changing Dimension (1, 2 and both) Load

The templates provides both the SQL scripts needed to create the objects in SQL Server and also BIML file in order to create the SSIS Package.

We choose to use BIML as intermediate artifact since it's really easy to generate it and have it turned into a SSIS Package via [BIDS Helper](https://bidshelper.codeplex.com/). We encourage you to discover more about BIML here: http://bimlscript.com/.

Metadata is stored in JSON files for maximum flexibility and happiness of developers.

### Note
Please note this is not a step-by-step instruction document. Some experience in working with SQL Server and BI is needed. For example we give for granted that you know how to create a SSIS Package, to attach a SQL Server database or to install and use a Visual Studio plugin, and so on.

### Getting Started

#### Environment Setup
Download the project via GitHub, by clicking on the "Download Zip" icon. Unzip it into the folder you prefer. The solution contains the templates, sample metadata and the [ABI Framework compiler](https://github.com/SolidQIT/ABI-Compiler), the tool that will merge metadata and templates into SQL and BIML files. In addition to that, you need to have installed on your development machine SQL Server and its development tools:

[SQL Server 2014](https://www.microsoft.com/en-us/evalcenter/evaluate-sql-server-2014)
[SQL Server Data Tools and SQL Server Data Tools - BI](https://msdn.microsoft.com/en-us/library/mt674919.aspx)

and also the AdventureWorks 2012 sample database:

[AdventureWorks2012_Database.zip](http://msftdbprodsamples.codeplex.com/releases/view/93587)

You have to attach the AdventureWorks2012 database to your SQL Server instance. You then need some additional Visual Studio add-in in order to make sure you can turn the generated BIML files into a .DTSX package:

[BIDS Helper](https://bidshelper.codeplex.com/) (older, supports up to SQL Server 2014)
[BIML Express](https://www.varigence.com/BimlExpress) (newer with support for SQL Server 2016)

and the last component you need is an additional component for Integration Services, needed to calculate hash values, that it used in the Slowly Changing Dimension template

[SSIS Multiple Hash](https://ssismhash.codeplex.com/)

####Creating support ABI Framework databases

In the ``support`` folder, you will find all the files needed to create the environment to run the sample. The ABI framework relies on a some standard database ecosystem. To create the basic database to allow such ecosystem to exists, you have to execute the ``setup-db.ps1`` in the ``setup`` subfolder.

Before executing the file, please configure the correct values for the following variables:

- ``$targetServer``
- ``$dataPath``
- ``$logPath``

for the sake of the example, leave the database name set to "Adaptive30" so that for this first time all scripts will work without having you to specify a different database name. Once you have set the correct values for your machine, run the PowerShell script. And the end of the script, five database will be available in your SQL Server instance:

``AdaptiveBI30_CFG``
``AdaptiveBI30_DWH``
``AdaptiveBI30_HLP``
``AdaptiveBI30_MD``
``AdaptiveBI30_STG``

Once this is done, you have to execute the ``setup-objects.ps1`` script (again, before make sure that the correct ``$targetServer`` value is set in this script) so that the above database get populated with some standard objects that the ABI Framework expect have. If you're curious about what these objects are, you can find the scripts in the ``ddl`` subfolder.

The ABI Framework environment is now set up and ready to be used.

### Setting up the sample data source

In this example you'll use the AdventureWorks2012 database as the data source for the Data Warehouse. In the ABI framework data is exposed through views in order to create a simple abstraction layer.  To create such views you have to execute the ``setup-views-1.ps1`` from the ``support\sample\setup`` folder. You can configure your target SQL Server instance by setting the correct value in ``$targetServer``. Its value must be the same value used before while setting up the environment.
Once the script has finished the execution, you'll find the following views in the "HLP" database:

    bi.vw_Person__Person
    bi.vw_Production__Product
    bi.vw_Production__ProductCategory
    bi.vw_Production__ProductSubCategory
    bi.vw_Sales__CreditCard
    bi.vw_Sales__Customer
    bi.vw_Sales__SalesOrderDetail
    bi.vw_Sales__SalesOrderHeader
    bi.vw_Sales__SalesOrderHeaderSalesReason
    bi.vw_Sales__SalesReason
    bi.vw_Sales__Store

### Creating the Data Warehouse

The ABI Framework allows you to automate the generation of the "E" and "L" phase of the ETL process, by applying well-known design patterns, in the form of *templates* that allows you to make sure that the best practices and well-known solutions to common problems are automatically applied and used.

The templates provided with the reference solution are the following ones

- Staging Table Full Load
- [Transactional Fact Table Full Load](docs/transaction-fact-table-full-load.md)
- Slowly Changing Dimension Type 1
- Slowly Changing Dimension Type 2

#### Extract Phase
In this first phase you will extract the data needed for loading the Data Warehouse into the Staging database. No complex transformation will happen here, since the main goal of this phase is to transfer as quickly as possible that source data into the staging area. The pattern that will be used to load such staging area will the the *Full Load*.

The data to be loaded in the Staging area is exposed by the views mentioned before. All you have to do right now, for each view, is to

 - create the target destination table
 - create a SSIS package to load such table

Both points should be done applying the best practices and your standards. For this example the standard requires that we log in the "LOG" database how many rows has been loaded.

The "Staging Full Load Pattern" is implemented following best practices and logging requirements in the provided sample templates. All you need to do is to fill the metadata for the engine to do its magic and use the provided metadata to apply the template.

Pre-compiled metadata files for the sample are available in the ``metadata`` folder. More specifically, since you're working on the Extract phase the metadata are places in the ``metadata\extract`` folder.

Take a look at the ``Person__Person.json`` file the see how the metadata is organized. The only mandatory section is the ``ABI3`` section. All the other elements are dependent on the template you're going to use. You tell the compiler which template you want to use by specifying the correct values in the ``ABI3`` section. All the information provided will be used by the compiler to correctly identify the template to apply by looking in correct place in the file system under the ``templates`` folder. To gain a deeper understanding on how the compiler resolves the metadata and looks for template you can read more here:  [How the ABI Compiler Works](docs/how-the-abi-compiler-works.md).

To compile the ``Person__Person.json`` file into something usable you just have to open a command prompt, go to the solution folder and execute the compiler:

    cd C:\Work\GitHub\ABI-Solution
    SolidQ.ABI.exe compile extract/Person__Person.json

If no errors are reported you will find two *artifacts* in the output folder, under the ``Person__Person`` directory, that are the result of the compilation process. The used template generates two artifacts: one .sql file and one .biml file:

    Person__Person.sql
    Person__Person.biml

The first one contains the T-SQL code to create the destination table and, for this sample, also to update the "MD" database. The file is **not** executed automatically but you have to execute it yourself for maximum safety and security. The .biml file has to be loaded into Visual Studio and using the BIDS Helper or BIML Express, turned into a SSIS Package.

If you want to compile all the metadata at once - in the sample metadata for all views in the HLP databases is provided - you can use this command:

	SolidQ.ABI.exe compile extract/*

And voilà: all the SQL and BIML file will be created for you in a couple of seconds.

#### Transform Phase
TDB

#### Load Phase
TDB
