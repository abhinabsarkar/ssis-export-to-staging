# Create Tables Dynamically from Flat Files and load Data using SSIS package

Problem statement: You received flat files or text files or csv files in one of the source folder. You need to write an SSIS Package that should read the file columns and create table and load the data from file. Once data is loading move the file to archive folder.
The table will be created with name of file. If already exists, we would like to drop the table and created.

Solution: Use Script Task to create table dynamically for each flat file and load it.

Used the following variables so that they can be added in a configuration file to pass the values.

ArchiveFolder: Provide the folder path where you would like to move files after loading. Datetime part will be added to file name.
ColumnsDataType : Provide the data type you would like to use for newly created table/s.
SchemaName : Provide the schema name in which you would like to create your table/s.
FileDelimiter : Provide the delimiter which is used in your txt or csv files.
FileExtension : Provide the Extension of files you would like to load from folder.
LogFolder : Provide the folder path where you would like to create log file in case of error in script task
SourceFolder: Provide the source folder path where text files or csv files are places for import process.

The complete source code is available in [src](/src/ssis-code/)

## Reference
[How to Create Tables Dynamically from Flat Files and load Data in SSIS Package](https://www.techbrothersit.com/2016/03/how-to-create-tables-dynamically-from.html)