/*
---------------------------------------------------------------------
Purpose: 
To Check and clean HBM data, remove nulls, perform uniformization, create any 
calculated columns as needed, remove duplicates, assess timelines and correct as necessary,
remove excess spaces.
The ideal would be to always check in with support and stakeholder with necessary changes and question
The intention is to give a snapshot of the data results for readable flow and coherence.
---------------------------------------------------------------------
*/

----------------------------------------------------
--staff_schedule table
----------------------------------------------------
SELECT DISTINCT
weeK, staff_id, staff_name, role, service, present
FROM Bronze_H.staff_schedule;
--all are unique

SELECT 
weeK, staff_id, staff_name, role, service, present
FROM Bronze_H.staff_schedule
WHERE staff_id != TRIM(staff_id)
	OR staff_name !=TRIM(staff_name) OR role !=TRIM(role)
	OR service != TRIM(service);
--none

SELECT COUNT (DISTINCT weeK) AS number_of_weeks, staff_id 
FROM Bronze_H.staff_schedule
GROUP BY staff_id;
--each staff_id hs 52 weeks of data

SELECT DISTINCT staff_name
FROM Bronze_H.staff_schedule;
--126

SELECT DISTINCT role
FROM Bronze_H.staff_schedule;
--doctor, nurse, nursing, assistant, and no nulls

SELECT DISTINCT service
FROM Bronze_H.staff_schedule;
--emergency, surgery, ICU, general_medicine, and no nulls

SELECT staff_name, present
FROM Bronze_H.staff_schedule
WHERE present IS NULL OR present < 0;
--none, no nulls 

SELECT role, service, COUNT(present) AS absences
FROM Bronze_H.staff_schedule
WHERE present = 0
GROUP BY role, service
ORDER BY absences DESC; -- follow up with staff count beside absences in silver
--where 0 means absences

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
		FROM Bronze_H.staff	
	 )t
WHERE unique_num = 1;
--110, no dupes, row_number not needed

SELECT DISTINCT staff_id, staff_name
FROM Bronze_H.staff;

SELECT DISTINCT role
FROM Bronze_H.staff;-- doctor, nurse, nursing_assistant

SELECT DISTINCT service
FROM Bronze_H.staff;-- emergency, general_medicine, ICU, surgery

--(no duplicates or nulls for all 110 rows)

SELECT staff_id, staff_name,role, service
FROM Bronze_H.staff	
WHERE TRIM(staff_id) != staff_id OR 
	  TRIM(staff_name) != staff_name OR
	  TRIM(role) != role OR
	  TRIM(service) != service
--none

----------------------------------------------
--services_weekly
----------------------------------------------

SELECT COUNT(DISTINCT weeK) AS week_per_month, month
FROM Bronze_H.services_weekly 
GROUP BY month
/*
week_per_month	month
5	1
4	2
4	3
4	4
4	5
4	6
4	7
4	8
4	9
4	10
4	11
8	12 */ -- no duplicate months, overflow present in weeks

-- explaining month overflow to a stakeholder

/* 
Since the 12 months of the year do not have an even 
number of weeks to make up 52 exact weekly 'buckets.', 
the 12th month ended up catching the overflow of the
months of the year. This is why Month 12 looks
twice as large as February.
*/

SELECT DISTINCT 
	service, event
FROM Bronze_H.services_weekly 
/*
service				event
emergency			donation 
emergency			flu 
emergency			none 
emergency			strike 
general_medicine	donation 
general_medicine	flu 
general_medicine	none 
general_medicine	strike 
ICU					donation  -- no strike in the ICU
ICU					flu 
ICU					none 
surgery				donation 
surgery				flu 
surgery				none 
surgery				strike 
*/

SELECT DISTINCT 
	service, event
FROM Bronze_H.services_weekly 
WHERE TRIM(service) != service OR TRIM(event) != event
-- none

SELECT 
	month, service
	available_beds, 
	patients_request, patients_admitted, patient_satisfaction, 
	staff_morale
FROM Bronze_H.services_weekly 
WHERE 
	available_beds IS NULL OR patients_request = 0 OR 
	patients_request IS NULL OR patients_admitted = 0 OR
	patients_admitted IS NULL OR patient_satisfaction = 0 OR 
	patient_satisfaction IS NULL OR staff_morale = 0 OR
	staff_morale IS NULL

--no nulls, no '0's
----------------------------------------------
-- patients
----------------------------------------------

SELECT DISTINCT patient_id, name
FROM Bronze_H.patients;
--All 1000 rows are distinct

SELECT patient_id, name, age, arrival_date,departure_date, service, satisfaction
FROM Bronze_H.patients
WHERE age <= 0 OR age IS NULL OR service IS NULL 
-- 12 patients that are most likely newborn or age = 0

SELECT arrival_date, departure_date
FROM Bronze_H.patients
WHERE 
    arrival_date < '2020-01-01' OR arrival_date > '2030-12-31' 
	OR arrival_date IS NULL OR departure_date < '2020-01-01' 
	OR departure_date > '2030-12-31' OR departure_date IS NULL
-- none

SELECT arrival_date, departure_date
FROM Bronze_H.patients
WHERE arrival_date > departure_date
--none

SELECT LEN(CAST(arrival_date AS NVARCHAR)) AS a_date_length, 
		LEN(CAST(departure_date AS NVARCHAR)) AS d_date_length   
FROM Bronze_H.patients
WHERE LEN(CAST(arrival_date AS NVARCHAR)) > 10 OR LEN(CAST(arrival_date AS NVARCHAR)) < 10
      OR LEN(CAST(departure_date AS NVARCHAR)) < 0 OR LEN(CAST(departure_date AS NVARCHAR)) > 10
--none
---------------------------------------------------------
/* 
	Cross-table checks for staff_name and staff_id in 
	tables: staff_schedule and staff
*/ 
---------------------------------------------------------

SELECT *
FROM Bronze_H.staff_schedule 
WHERE LEN(staff_id) > 12 or LEN(staff_id) < 12;  -- none

SELECT *
FROM Bronze_H.staff  
WHERE LEN(staff_id) > 12 or LEN(staff_id) < 12;  -- none

SELECT staff_id, COUNT(DISTINCT staff_name) as id_count
FROM Bronze_H.staff_schedule
GROUP BY staff_id
HAVING COUNT(DISTINCT staff_name) > 1; -- none

SELECT staff_name, COUNT(DISTINCT staff_id) as id_count
FROM Bronze_H.staff_schedule
GROUP BY staff_name
HAVING COUNT(DISTINCT staff_id) > 1;
--none
--the staff_schedule does have multiple natural staff_name entries for staff attendance
---------------------------
--staff_id
---------------------------
SELECT DISTINCT sc.staff_id, sc.staff_name
FROM Bronze_H.staff_schedule AS sc
LEFT JOIN Bronze_H.staff AS s
ON sc.staff_id = s.staff_id
WHERE s.staff_id IS NULL
--126 persons marked present or absent and scheduled are not registered as staff

SELECT staff_id 
FROM Bronze_H.staff
WHERE staff_id = 'STF-038ff4c9'
--unique check for scheduled staff_id: STF-038ff4c9 = none i.e not in staff table

SELECT DISTINCT sc.staff_id, sc.staff_name, s.staff_id as directory_id
FROM Bronze_H.staff_schedule AS sc
LEFT JOIN Bronze_H.staff AS s 
    ON TRIM(UPPER(sc.staff_id)) = TRIM(UPPER(s.staff_id))
WHERE s.staff_id IS NOT NULL; 
-- 0 i.e no staff_id is the reflective of the staff_names

--------------------------------
--staff_name
--------------------------------

SELECT DISTINCT sc.staff_id, sc.staff_name, sc.role, sc.service
FROM Bronze_H.staff_schedule AS sc
LEFT JOIN Bronze_H.staff AS s
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
...are not present in the staff registry but are on the schedule
								
*/

SELECT DISTINCT s.staff_id, s.staff_name
FROM Bronze_H.staff_schedule AS sc
LEFT JOIN Bronze_H.staff AS s
ON sc.staff_name = s. staff_name
WHERE sc.staff_name IS NULL;
--0, all persons in the staff table are, in contrast, present in the staff_schedule

/*
plan:
	In silver table, after checking with the stakeholder for the correct ids...
	In this case, plan to keep a distinct staff_id for staff present in those
	tables and update staff registry with missing names found in staff_schedule
	once clarified
*/


