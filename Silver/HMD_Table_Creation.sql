/*
==========================================
DDL Silver Table Creation
==========================================
The use of DDL to create silver tables along with the
datatype specificity. 
When alterations are needed, in this case,
the place setting to alter table is also here.

Key Note: The difference between the bronze and silver tables is 
the trancendence of data from extracting, cleaning and aligning data in the bronze phase
and into data exploration and analysis in the silver phase
*/

USE Hospital
GO
IF OBJECT_ID ('Silver_H.patients') IS NULL
CREATE TABLE Silver_H.patients
	(
		patient_id			NVARCHAR(50),
		name				NVARCHAR(50),
		age					INT,
		arrival_date		DATE,	
		departure_date		DATE,
		service				NVARCHAR(50),
		satisfaction		INT,
		db_create_date		DATETIME2(0) DEFAULT GETDATE(),
		db_source			NVARCHAR(50) DEFAULT 'Bronze_H.staff'
	);
DROP TABLE IF EXISTS Silver_H.staff
CREATE TABLE Silver_H.staff
	(
		staff_id			NVARCHAR(50),	
		staff_name			NVARCHAR(50),
		role				NVARCHAR(50),
		service				NVARCHAR(50),
		db_create_date		DATETIME2(0) DEFAULT GETDATE(),
		db_source			NVARCHAR(50) DEFAULT 'Bronze_H.staff'
	);

DROP TABLE IF EXISTS Silver_H.staff_schedule
CREATE TABLE Silver_H.staff_schedule
	(
		week				INT,
		staff_id			NVARCHAR(50),
		staff_name			NVARCHAR(50),
		role				NVARCHAR(50),
		service				NVARCHAR(50),
		present				INT,
		db_create_date		DATETIME2(0) DEFAULT GETDATE(),
		db_source			NVARCHAR(50) DEFAULT 'Bronze_H.staff'

	);

DROP TABLE IF EXISTS Silver_H.services_weekly
CREATE TABLE Silver_H.services_weekly
	(
		week				INT,
		month				INT,
		service				NVARCHAR(50),
		available_beds		INT,
		patients_request	INT,
		patients_admitted	INT,
		patients_refused	INT,
		patient_satisfaction	INT,
		staff_morale			INT,
		event					NVARCHAR(50),
		db_create_date		DATETIME2(0) DEFAULT GETDATE(),
		db_source			NVARCHAR(50) DEFAULT 'Bronze_H.staff'
	);

		
