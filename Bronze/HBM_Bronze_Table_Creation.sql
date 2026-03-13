/*
==========================================
DDL Bronze Table Creation
==========================================
The use of DDL to create tables along with the datatype specificity pre-defined in Excel
When alterations are needed, in this case, the place setting to alter table is also here
*/

USE Hospital
GO
IF OBJECT_ID ('Bronze_H.patients') IS NULL
CREATE TABLE Bronze_H.patients
	(
		patient_id			NVARCHAR(50),
		name				NVARCHAR(50),
		age					INT,
		arrival_date		DATE,	
		departure_date		DATE,
		service				NVARCHAR(50),
		satisfaction		INT
	);
DROP TABLE IF EXISTS Bronze_H.staff
CREATE TABLE Bronze_H.staff
	(
		staff_id			NVARCHAR(50),	
		staff_name			NVARCHAR(50),
		role				NVARCHAR(50),
		service				NVARCHAR(50)
	);

DROP TABLE IF EXISTS Bronze_H.staff_schedule
CREATE TABLE Bronze_H.staff_schedule
	(
		week				INT,
		staff_id			NVARCHAR(50),
		staff_name			NVARCHAR(50),
		role				NVARCHAR(50),
		service				NVARCHAR(50),
		present				INT
	);

DROP TABLE IF EXISTS Bronze_H.services_weekly
CREATE TABLE Bronze_H.services_weekly
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
		event					NVARCHAR(50)
	);
