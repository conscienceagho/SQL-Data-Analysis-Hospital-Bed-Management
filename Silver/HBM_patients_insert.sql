/*
==============================================
Title: Inserting  patients into silver 
Purpose: To move the patients table from the bronze phase into the silver
phase after clearance from data quality checks
==============================================
*/

INSERT INTO Silver_H.patients
(
		patient_id,
		name,
		age,
		arrival_date,	
		departure_date,
		service,
		satisfaction
)
SELECT
		patient_id,
		name,
		age,
		arrival_date,	
		departure_date,
		service,
		satisfaction
FROM Bronze_H.patients

--checking data insert
SELECT * FROM Silver_H.patients


-------------------------------------------
--patients table data quality checks
------------------------------------------

SELECT DISTINCT patient_id, name
FROM Silver_H.patients;
--All 1000 rows are distinct

SELECT patient_id, name, age, arrival_date,departure_date, service, satisfaction
FROM Silver_H.patients
WHERE age <= 0 OR age IS NULL OR service IS NULL 
-- 12 patients that are most likely newborn or age = 0; no nulls

SELECT arrival_date, departure_date
FROM Silver_H.patients
WHERE 
    arrival_date < '2020-01-01' OR arrival_date > '2030-12-31' 
	OR arrival_date IS NULL OR departure_date < '2020-01-01' 
	OR departure_date > '2030-12-31' OR departure_date IS NULL
-- none

SELECT arrival_date, departure_date
FROM Silver_H.patients
WHERE arrival_date > departure_date
--none

SELECT LEN(CAST(arrival_date AS NVARCHAR)) AS a_date_length, 
		LEN(CAST(departure_date AS NVARCHAR)) AS d_date_length   
FROM Silver_H.patients
WHERE LEN(CAST(arrival_date AS NVARCHAR)) > 10 OR LEN(CAST(arrival_date AS NVARCHAR)) < 10
      OR LEN(CAST(departure_date AS NVARCHAR)) < 0 OR LEN(CAST(departure_date AS NVARCHAR)) > 10
--none
