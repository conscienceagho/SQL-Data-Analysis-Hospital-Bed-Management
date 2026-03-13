/*
==============================================
Title: Inserting Services Weekly into Silver
Purpose: To move the services weekly table from the bronze phase into the silver
phase after clearance from data quality checks
==============================================
*/

INSERT INTO Silver_H.services_weekly 
	(
	week, month, service, 
	available_beds, 
	patients_request, 
	patients_admitted,
	patients_refused,
	patient_satisfaction, 
	staff_morale,
	event
	)

SELECT 
	week, month, service, 
	available_beds, 
	patients_request, 
	patients_admitted,
	patients_refused,
	patient_satisfaction, 
	staff_morale,
	event
FROM Bronze_H.services_weekly 



/*
=================================================
Data Quality Checks)
=================================================
*/
SELECT COUNT(DISTINCT weeK) AS week_per_month, month
FROM Silver_H.services_weekly 
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
FROM Silver_H.services_weekly 
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
FROM Silver_H.services_weekly 
WHERE TRIM(service) != service OR TRIM(event) != event
-- none

SELECT 
	month, service
	available_beds, 
	patients_request, patients_admitted, patient_satisfaction, 
	staff_morale
FROM Silver_H.services_weekly 
WHERE 
	available_beds IS NULL OR patients_request = 0 OR 
	patients_request IS NULL OR patients_admitted = 0 OR
	patients_admitted IS NULL OR patient_satisfaction = 0 OR 
	patient_satisfaction IS NULL OR staff_morale = 0 OR
	staff_morale IS NULL

--no nulls, no '0's

SELECT * FROM Bronze_H.services_weekly
