/*
===============================================================
Database and schema creation
===============================================================
Purpose: Prepare a database for the hospital bed management case study
using the SQL DDL functions. Post-clarification, this DDL will DELETE 
any prior database with the database name 'Hospital' to avoid errors 
and future mismatch.
This script also creates three schems, 'brone', 'silver', and 'gold' 
within the database
*/

USE MASTER;
GO

--Select and Drop any prior 'Hospital' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Hospital')
BEGIN
	ALTER DATABASE Hospital SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Hospital;
END;

GO

--Create the 'Hospital' database 
CREATE DATABASE Hospital;
GO


--Create schemas in new database
USE Hospital;

CREATE SCHEMA Bronze_H;
GO

CREATE SCHEMA Silver_H;
GO

CREATE SCHEMA Gold_H; 






