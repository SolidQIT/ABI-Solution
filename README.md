# Adaptive BI Framework 3.0
## Reference Solution v 1.0.2

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

### Documentation
Full documentation is available here: [ABI Solution Documentation](http://abi-solution.readthedocs.io/)
