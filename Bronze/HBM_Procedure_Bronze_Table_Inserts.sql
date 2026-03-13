/*
Style: A procedure
Purpose: inserting .csv tables into previously created Bronze Tables. Contrary to the prior case study
for cyclista bikeshare ,- this dataset did not require force entry by making all "NVARCHAR" prior to redefining.
The server wa able to recognize the datatype and all tables were inserted for further cleaning, exploration and analysis
*/

CREATE OR ALTER PROCEDURE Bronze_H.load_bronze AS
	BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @rows INT;
--"DECLARE @rows INT" --and series added to count rows that entered each table due to prior empty tables
	BEGIN TRY

	SET @batch_start_time = GETDATE();

PRINT '=======================================================================================';
PRINT 'Loading Bronze Layer'
PRINT '=======================================================================================';


PRINT '=======================================================================================';
PRINT 'Loading patient Tables'
PRINT '=======================================================================================';

	SET @start_time = GETDATE();
PRINT '>>Truncating Table: Bronze_H.patients';
	TRUNCATE TABLE Bronze_H.patients
PRINT '>>Inserting Data Into: Bronze_H.patients';
	BULK INSERT Bronze_H.patients
	FROM 'C:\patients.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0a',
		TABLOCK
		);
	SET @rows = (SELECT COUNT(*) FROM Bronze_H.patients);
PRINT '>> Bronze_H.patients: ' + CAST(@rows AS VARCHAR) + ' rows loaded.';
	SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> ------------------------------------------------------------------------------------';



PRINT '======================================================================================='
PRINT 'Loading staff Table'
PRINT '========================================================================================'


	SET @start_time = GETDATE();
PRINT '>>Truncatng Table: Bronze_H.staff';
	TRUNCATE TABLE Bronze_H.staff
PRINT '>>Inserting Data Into: Bronze_H.staff';
	BULK INSERT Bronze_H.staff
	FROM 'C:\staff.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0a',
		TABLOCK
		);
	SET @rows = (SELECT COUNT(*) FROM Bronze_H.staff);
PRINT '>> Bronze_H.staff: ' + CAST(@rows AS VARCHAR) + ' rows loaded.';
	SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> ------------------------------------------------------------------------------------';


PRINT '=======================================================================================';
PRINT 'Loading staff_schedule Table'
PRINT '=======================================================================================';


	SET @start_time = GETDATE();
PRINT '>>Truncating Table: Bronze_H.staff_schedule';
	TRUNCATE TABLE Bronze_H.staff_schedule
PRINT '>>Inserting Data Into: Bronze_H.staff_schedule'
	BULK INSERT Bronze_H.staff_schedule
	FROM 'C:\staff_schedule.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0a',
		TABLOCK
		);
	SET @rows = (SELECT COUNT(*) FROM Bronze_H.staff_schedule);
PRINT '>> Bronze_H.staff_schedule: ' + CAST(@rows AS VARCHAR) + ' rows loaded.';
	SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> ------------------------------------------------------------------------------------';



PRINT '======================================================================================='
PRINT 'Loading services_weekly Table'
PRINT '========================================================================================'


	SET @start_time = GETDATE();
PRINT '>>Truncating Table:  Bronze_H.services_weekly';
	TRUNCATE TABLE  Bronze_H.services_weekly
PRINT '>>Inserting Data Into:  Bronze_H.services_weekly';
	BULK INSERT  Bronze_H.services_weekly
	FROM 'C:\services_weekly.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0a',
		TABLOCK
		);
	SET @rows = (SELECT COUNT(*) FROM Bronze_H.services_weekly);
PRINT '>> Bronze_H.services_weekly: ' + CAST(@rows AS VARCHAR) + ' rows loaded.';
	SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> ------------------------------------------------------------------------------------';



	SET @batch_end_time = GETDATE();
PRINT '==============================================='
PRINT 'Loading Bronze Layer is Completed';
PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' SECONDS';
PRINT '==============================================='

	END TRY
	BEGIN CATCH
	PRINT '=======================================================================================';
	PRINT 'ERROR OCCURED DURING LOADING OF BRONZE LAYER'
	PRINT 'Error Message' + ERROR_MESSAGE ();
	PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
	PRINT '=======================================================================================';


	END CATCH

	END

-- When due: 
EXEC Bronze_H.load_bronze

