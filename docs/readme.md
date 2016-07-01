# Getting Started

## Environment Setup
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

## The Solution
For convenience all the needed files has been included in a Visual Studio 2015 Project. If you don't have Visual Studio 2015, you can download the free Community edition from here: [Visual Studio 2015 Community Download](https://www.visualstudio.com/products/visual-studio-community-vs). If you prefer an alternative lightweight IDE you can also use [Atom](https://atom.io/), than don't even need a solution/project file.

## Creating support ABI Framework databases
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

# Setting up the sample data source
In this example you'll use the AdventureWorks2012 database as the data source for the Data Warehouse. In the ABI framework data is exposed through views in order to create a simple abstraction layer.  To create such views you have to execute the ``setup-views-1.ps1`` from the ``support\sample\setup`` folder. You can configure your target SQL Server instance by setting the correct value in ``$targetServer``. Its value must be the same value used before while setting up the environment.
Once the script has finished the execution, you'll find the following views in the "HLP" database:

    bi.vw_Person__Address
    bi.vw_Person__Person
    bi.vw_Production__Product
    [...]
    bi.vw_Sales__SalesOrderHeaderSalesReason
    bi.vw_Sales__SalesReason
    bi.vw_Sales__Store

# Creating the Data Warehouse
The ABI Framework allows you to automate the generation of the "E" and "L" phase of the ETL process, by applying well-known design patterns, in the form of *templates* that allows you to make sure that the best practices and well-known solutions to common problems are automatically applied and used.

The templates provided with the reference solution are the following ones

- Staging Table Full Load
- [Transactional Fact Table Full Load](docs/transaction-fact-table-full-load.md)
- Slowly Changing Dimension Type 1
- Slowly Changing Dimension Type 2

## Extract Phase
In this first phase you will extract the data needed for loading the Data Warehouse into the Staging database. No complex transformation will happen here, since the main goal of this phase is to transfer as quickly as possible that source data into the staging area. The pattern that will be used to load such staging area will be the *Full Load*.

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

You now have to execute the SQL Script to create database objects and copy-and-paste the BIML file into your Visual Studio SSIS solution in order to use the BIML plugin (BIDS Helper or BIML Express) to expand BIML into a working package. In order to keep the DWH solution you're building clean and tidy, it's better to create a specific SSIS Solution to hold objects created in this Phase.

## Transform Phase
The transformation phase is where custom transformation logic is written and applied, and thus, in general, cannot be automated. For this sample, a very simple transformation logic, that only uses views, is provided. To create such views you have to execute the ``setup-views-2.ps1`` from the ``support\sample\setup`` folder. You can configure your target SQL Server instance by setting the correct value in ``$targetServer``. Its value must be the same value used before while setting up the environment.
Once the script has finished the execution, you'll find (in addition to the ones created in the previous section) the following views in the "STG" database:

    etl.vw_dim_Addresses
    etl.vw_dim_Customers
    etl.vw_dim_Dates
    etl.vw_dim_Orders
    [...]
    etl.vw_fact_Orders
    etl.vw_fact_OrderDetails
    etl.vw_factless_OrderReasons

The views are used to expose data to the next step where data will be loaded into dimensions and fact/factless table. All transformations should be done before, using custom stored procedures, integration services packages, or anything you may want to use to transform your data into something near to dimension and fact tables. Once such transformation is done, the only transformation that remain to be performed is the creation and/or the lookup of the surrogate keys. As said before, for this example, the transformation phase is very simple and can be directly encapsulated into the aforementioned views.  

## Load Phase
The load phase is where the Data Warehouse is finally loaded. No business-specific transformation are done here: the dimension and the fact tables are loaded and the only one transformation that happen is the one that turns business keys into surrogate keys. Dimension are always loaded incrementally while, in this example, the fact and factless table are loaded applying a full load pattern. Here the views created in the Transform Phase will be used to load the appropriate object. For each object the provided template will:

- create the SQL Server objects in the DWH
- create the SQL Server objects used in the SSIS packages
- create the SSIS Package

You can find the metadata files that describes each dimension in the ``metadata\load\`` subfolders. Take a look at the ``dimension\Products.json`` and at the order files. Similarly to the metadata file used in the Extract phase you can find the ``ABI3`` header section where you specify which pattern you want to use and then specific metadata needed by the chosen template. Take a look at dimension and fact metadata files so that you can start to get confident with the sample metadata and also take a look at the ``templates\load\`` folder to see how such metadata is used in the various templates.

To compile the metadata into SQL and BIML files, as already did for the Extract phase, you have to use the following command:

    cd C:\Work\GitHub\ABI-Solution
    SolidQ.ABI.exe compile load/*

At the end of the compilation process you will find the generated artifacts in the ``output\load\`` folder. You now have to execute the SQL scripts in order to created SQL Server objects and use the .biml files to generate the SSIS Packages to load the DWH. Again, in order to keep the DWH solution you're building clean and tidy, it's better to create a specific SSIS Solution to hold objects created in this Phase.

That's it you can now load your DWH. Well done!
