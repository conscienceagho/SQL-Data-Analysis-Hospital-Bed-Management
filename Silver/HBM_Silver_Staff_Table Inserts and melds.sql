

/*
==================================================
Title: Inserting Data into the silver 'staff' tables. 

Purpose: To insert data into staff tables. In the process, two problems:
incomplete staff names in the 'staff' table and discordant (not the same) staff_ids between
the 'staff' table and 'staff schedule',- solved along the process. 
The staff table will be maintained (in the assumption and ideal of checking with
stakeholders) and an updated_staff_table will include data about staff schedule and uniform patient ids
Column for 'week' as noted in the Bronze phase where the 12th month had for example, 8 weeks, will not be included
deferred for 'month' instead

==================================================
*/
---------------------------------
--INSERTING staff and staff_schedule into silver
---------------------------------
INSERT INTO Silver_H.staff_schedule (weeK, staff_id, staff_name, role, service, present)
(SELECT weeK, staff_id, staff_name, role, service, present
FROM Silver_H.staff_schedule)

INSERT INTO Silver_H.staff (staff_id, staff_name, role, service)
(SELECT staff_id, staff_name, role, service
FROM Silver_H.staff)

/*
==================================================
Data quality Checks for staff_schedule and staff
==================================================
*/

----------------------------------------------------
--staff_schedule table
----------------------------------------------------
	SELECT DISTINCT
	weeK, staff_id, staff_name, role, service, present
	FROM Silver_H.staff_schedule;
	--all are unique, 6552 people

	SELECT 
	weeK, staff_id, staff_name, role, service, present
	FROM Silver_H.staff_schedule
	WHERE staff_id != TRIM(staff_id)
		OR staff_name !=TRIM(staff_name) OR role !=TRIM(role)
		OR service != TRIM(service);
	--none

	SELECT COUNT (DISTINCT weeK) AS number_of_weeks, staff_id 
	FROM Silver_H.staff_schedule
	GROUP BY staff_id;
	--each 126 staff_id hs 52 weeks of data

	SELECT DISTINCT staff_name
	FROM Silver_H.staff_schedule;
	--126 staff_names as expected

	SELECT DISTINCT role
	FROM Silver_H.staff_schedule;
	--doctor, nurse, nursing, assistant, and no nulls

	SELECT DISTINCT service
	FROM Silver_H.staff_schedule;
	--emergency, surgery, ICU, general_medicine, and no nulls

	SELECT staff_name, present
	FROM Silver_H.staff_schedule
	WHERE present IS NULL OR present < 0;
	--none, no nulls 

	SELECT role, service, COUNT(present) AS absences
	FROM Silver_H.staff_schedule
	WHERE present = 0
	GROUP BY role, service
	ORDER BY absences DESC; -- follow up with staff count beside absences

	/*
	role				service				absences
	nurse				emergency			449
	nurse				ICU					391
	nurse				general_medicine	343
	nurse				surgery				331
	nursing_assistant	ICU					187
	nursing_assistant	emergency			183
	doctor				emergency			171
	nursing_assistant	general_medicine	145
	doctor				ICU					127
	nursing_assistant	surgery				126
	doctor				general_medicine	109
	doctor				surgery				60
	*/

-------------------------------------------
--staff table
-------------------------------------------

	SELECT *
	FROM (
			SELECT staff_id, staff_name,role, service,
			ROW_NUMBER () OVER (PARTITION BY staff_name ORDER BY staff_name) AS unique_num
			FROM Silver_H.staff	
		 )t
	WHERE unique_num = 1;
	-- 110 unique staff in staff table, no duplicates. Where did 26 go?

	SELECT DISTINCT role
	FROM Silver_H.staff;-- doctor, nurse, nursing_assistant, no nulls

	SELECT DISTINCT service
	FROM Silver_H.staff;-- emergency, general_medicine, ICU, surgery, no nulls

	SELECT staff_id, staff_name,role, service
	FROM Silver_H.staff	
	WHERE TRIM(staff_id) != staff_id OR 
		  TRIM(staff_name) != staff_name OR
		  TRIM(role) != role OR
		  TRIM(service) != service
	--none
	
	---------------------------------------------------------
	/* 
		Cross-table checks for staff_name and staff_id in 
		tables: staff_schedule and staff
	*/ 
	---------------------------------------------------------

	SELECT *
	FROM Silver_H.staff_schedule 
	WHERE LEN(staff_id) > 12 or LEN(staff_id) < 12;  -- none

	SELECT *
	FROM Silver_H.staff  
	WHERE LEN(staff_id) > 12 or LEN(staff_id) < 12;  -- none

	SELECT staff_id, COUNT(DISTINCT staff_name) as id_count
	FROM Silver_H.staff_schedule
	GROUP BY staff_id
	HAVING COUNT(DISTINCT staff_name) > 1; -- none

	SELECT staff_name, COUNT(DISTINCT staff_id) as id_count
	FROM Silver_H.staff_schedule
	GROUP BY staff_name
	HAVING COUNT(DISTINCT staff_id) > 1;
	--none
	--the staff_schedule does have multiple natural staff_name entries for staff attendance
	
	---------------------------
	--staff_id
	---------------------------
	SELECT DISTINCT sc.staff_id, sc.staff_name
	FROM Silver_H.staff_schedule AS sc
	LEFT JOIN Silver_H.staff AS s
	ON sc.staff_id = s.staff_id
	WHERE s.staff_id IS NULL
	--126 persons marked present or absent and scheduled are not registered as staff <- problem solve 1

	SELECT staff_id 
	FROM Silver_H.staff
	WHERE staff_id = 'STF-038ff4c9'
	--unique check for scheduled staff_id: STF-038ff4c9 = none i.e not in staff table

	SELECT DISTINCT sc.staff_id, sc.staff_name, s.staff_id as directory_id
	FROM Silver_H.staff_schedule AS sc
	LEFT JOIN Silver_H.staff AS s 
		ON TRIM(UPPER(sc.staff_id)) = TRIM(UPPER(s.staff_id))
	WHERE s.staff_id IS NOT NULL; 
	-- '0' i.e no staff_id is the reflective of the staff_names <- problem-solve 2

	--------------------------------
	--staff_name
	--------------------------------

	SELECT DISTINCT sc.staff_id, sc.staff_name, sc.role, sc.service
	FROM Silver_H.staff_schedule AS sc
	LEFT JOIN Silver_H.staff AS s
	ON sc.staff_name = s.staff_name
	WHERE s.staff_name IS NULL;

	/* 

	STF-052894a3	Richard Rodriguez		nurse				ICU
	STF-05591498	William Herrera			nurse				ICU
	STF-302eb752	Erin Edwards			nursing_assistant	ICU
	STF-4740993e	Ashley Waller			nursing_assistant	ICU
	STF-4daae752	Jeffrey Chandler		nursing_assistant	ICU
	STF-669a95d5	Helen Jones				nursing_assistant	ICU
	STF-6a7114cb	April Frost				nursing_assistant	ICU
	STF-836e90d0	Diana May				nurse				ICU
	STF-97ee23c3	Julia Torres			nurse				ICU
	STF-9da1bed5	Michelle Harmon			nursing_assistant	ICU
	STF-abfdc900	Garrett Lin				nurse				ICU
	STF-b00ed3e2	Larry Dixon				nursing_assistant	ICU
	STF-cf9225db	Crystal Johnson			nurse				ICU
	STF-ddd99f9e	Victor Baker			nursing_assistant	ICU
	STF-e573be71	Shannon Walker			nurse				ICU
	STF-e983db1d	Kenneth Scott			nursing_assistant	ICU
								
	*/

	SELECT DISTINCT s.staff_id, s.staff_name
	FROM Silver_H.staff_schedule AS sc
	LEFT JOIN Silver_H.staff AS s
	ON sc.staff_name = s. staff_name
	WHERE sc.staff_name IS NULL;
	--0, clarified that all persons in the staff table are, in contrast, present in the staff_schedule


/*
==============================================================================
Problem solve 1: Updating the staff table with the entities in the staff_schedule 
===============================================================================
*/


INSERT INTO Silver_H.staff
(staff_id, staff_name, role, service)

						--creating the abrupt table for the missing 16 persons in the 'staff' table
						Use Hospital
						GO

						IF OBJECT_ID ('Silver_H.staffplus') IS NULL
						CREATE TABLE Silver_H.staffplus
							(
								staff_id			NVARCHAR(50),	
								staff_name			NVARCHAR(50),
								role				NVARCHAR(50),
								service				NVARCHAR(50),
							);

						--Truncinsert: Inserting the prior results pre-transferred into a csv file

						TRUNCATE TABLE  Silver_H.staffplus
						BULK INSERT Silver_H.staffplus
						FROM 'C:\staff plus_table.csv'
						WITH (
								firstrow = 2,
								rowterminator = '0x0a',
								fieldterminator = ',',
								TABLOCK
								);
--------------------------------------------
-- making a new staff_table with pending updates from 
-- the stakeholder about the ideal staff_id between both tables.
-- For now, the staff table is updated
--------------------------------------------
SELECT staff_id, staff_name, role, service
INTO Silver_H.updated_staff
FROM Silver_H.staff
UNION
SELECT staff_id, staff_name, role, service
FROM Silver_H.staffplus;

/*
========================================================================
Assumption: updating the new staff table with stakeholder request 
that the staff schedule id(s) be dominant in the staff table.
=======================================================================
*/
UPDATE u
SET u.staff_id = sc.staff_id
FROM Silver_H.updated_staff u
JOIN(
	SELECT DISTINCT staff_name, staff_id
	FROM Silver_H.staff_schedule
	) sc
ON u.staff_name = sc.staff_name	

-- The new table has been successfully updated with the correct staff ids and prior missing staff names

/*
==============================
Data Quality Checks
==============================
*/
-- Count of staff names in original tables
SELECT COUNT(*) AS original_staff_count FROM Silver_H.staff; --110
SELECT COUNT(*) AS staffplus_count FROM Silver_H.staffplus; --16

-- Count in updated table
SELECT COUNT(*) AS updated_count FROM Silver_H.updated_staff; --12

-- Any missing names?
SELECT s.staff_name
FROM Silver_H.staff s
WHERE s.staff_name NOT IN (SELECT staff_name FROM Silver_H.updated_staff); --0

SELECT p.staff_name
FROM Silver_H.staffplus p
WHERE p.staff_name NOT IN (SELECT staff_name FROM Silver_H.updated_staff); --0
