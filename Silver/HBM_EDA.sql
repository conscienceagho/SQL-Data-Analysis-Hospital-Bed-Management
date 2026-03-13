
/*
==================================
Silver Table EDA 
purpose: The purpose of this code discourse is to perform exploratory data analysis
to include some foundational basic statistical analysis
==================================
*/

-- But first, some columns are renamed to ensure readability and easier read

-- change 'present' to 'attendance' in staff_schedule
SELECT * FROM Silver_H.staff_schedule
EXEC sp_rename 'Silver_H.staff_schedule.present', 'attendance', 'COLUMN';

-- change 'service' to 'department' in staff_schedule
EXEC sp_rename 'Silver_H.staff_schedule.service', 'department', 'COLUMN';

-- change 'service' to 'department' in updated_staff 
SELECT * FROM Silver_H.updated_staff
EXEC sp_rename 'Silver_H.updated_staff.service', 'department', 'COLUMN';

-- change 'service' to 'department' in services_weekly 
SELECT * FROM Silver_H.services_weekly
EXEC sp_rename 'Silver_H.services_weekly.service', 'department', 'COLUMN';

-- change 'service' to 'department' in patients
SELECT * FROM Silver_H.patients
EXEC sp_rename 'Silver_H.patients.service', 'department', 'COLUMN';

--------------------------------------------------
--staff schedule
--------------------------------------------------

SELECT staff_id, staff_name, role, department, attendance
FROM SIlver_H.staff_schedule;


--overhead total attendance per department
SELECT department, SUM(attendance) AS total_dept_attendance
FROM SIlver_H.staff_schedule
GROUP BY department
ORDER BY total_dept_attendance DESC;

-- department			total_dept_attendance
-- emergency			1225
-- ICU					1063
-- general_medicine		859
-- surgery				783		


		SELECT department, MIN(attendance) AS lowest_dept_attendance,
				MAX(attendance) AS highest_dept_attendance
		FROM Silver_H.staff_schedule
		WHERE attendance <> 0 AND attendance <> 1
		GROUP BY department;
		--attendance scores are either 0 or 1

--overhead total attendance per role
SELECT 
    role,
    SUM(attendance) AS total_role_attendance,
    COUNT(*) AS staff_count,
    CAST(AVG(CAST(attendance AS DECIMAL(10,4))) 
         AS DECIMAL(10,2)) AS attendance_rate
FROM Silver_H.staff_schedule
GROUP BY role
ORDER BY total_role_attendance DESC;

/*
role				total_role_attendance staff_count  attendance_rate
nurse				2282				  3796		   0.60
nursing_assistant	971					  1612		   0.60
doctor				677					  1144		   0.59
*/
--The averages are same and nearly close at around 60% for all role delineations

--Avg attendance per individual staff and their roles
SELECT 
    staff_id, 
    role,
    attendance,
    CAST(
        AVG(CAST(attendance AS DECIMAL(10,4))) 
        OVER (PARTITION BY staff_id, role)
    AS DECIMAL(10,6)) AS avg_staff_attendance
FROM Silver_H.staff_schedule
ORDER BY role DESC;
/*
staff_id		role				attendance	avg_staff_attendance
STF-03fbeddc	nursing_assistant	1			0.596153
STF-03fbeddc	nursing_assistant	1			0.596153
STF-03fbeddc	nursing_assistant	0			0.596153
STF-03fbeddc	nursing_assistant	1			0.596153
STF-03fbeddc	nursing_assistant	0			0.596153
...
of 6551 unique entries
*/


-----------------------------------------------
--updated_staff
-----------------------------------------------
  -- update staff registry with a column for aggregate staff attendance 
  ---assuming it is required by the stakeholder


/*
INSERT INTO Silver_H.updated_staff
SELECT staff_name, SUM(attendance) AS attendance
FROM Silver_H.staff_schedule
GROUP BY staff_name;

  ...do not push 2 columns into a table that has more columns as it will 
  throw an error. Update instead
  */


UPDATE us
SET us.attendance = totals.total_attendance
FROM Silver_H.updated_staff us --The updated table is the 'from' table
JOIN (
	  SELECT staff_name, SUM(attendance) AS total_attendance
	  FROM Silver_H.staff_schedule
	  GROUP BY staff_name
	  ) totals 
    ON us.staff_name = totals.staff_name;

--Number of staff in the updated staff registry per role and department

SELECT 
	staff_id, role, department, 
    COUNT(*) OVER(PARTITION BY role, department) AS staff_to_dept_count
FROM Silver_H.updated_staff
ORDER BY COUNT(*) OVER(PARTITION BY role, department) DESC

 -- the three highest staff count are:
       /* () nurses in the ICU
          () nurses in emergency_medicine
          () nursing_assistants in the ICU
       */

---------------------------------------------------------------------------

/*
analyzing staff count, further:
Finding the total staff counts: 
	A- per role in department (role_in_department_count) e.g read as 19 'nurses' in general_medicine
	B- regardless of role (all_staff-count_in_dept) e.g. read as 27 'staff' in general_medicine
As well as percent ratio per: 
	C- role in department e.g. read as 70.37% are nurses in general_medicine (like 'A' giving a perspective on the % value of 19 nurses),- but
		in comparison to other staff in same department
	D- department in the entire hospital system regardless of role e.g. read as 21.43% 'staff' in general_medicine (Unlike 'B' which only 
		gives an intra-departmental view) in comparison to other staff counts (no delineation) in other departments in the hospital system view.
*/

WITH base AS (
    SELECT 
        staff_id,
        role, 
        department, 
        COUNT(*) OVER (PARTITION BY role, department) AS role_in_dept_count,
        COUNT(*) OVER (PARTITION BY department) AS all_staff_count_in_dept,
        COUNT(*) OVER () AS total_staff
    FROM Silver_H.updated_staff
)

SELECT 
    staff_id,
    role, 
    department, 
    role_in_dept_count,
    all_staff_count_in_dept,
    CAST(
        (role_in_dept_count * 100.0) / all_staff_count_in_dept
        AS DECIMAL(10,2)
    ) AS role_perc_per_dept,
    CAST(
        (all_staff_count_in_dept * 100.0) / total_staff
        AS DECIMAL(10,2)
    ) AS dept_perc_of_total_staff
FROM base
ORDER BY role_perc_per_dept DESC;

/*
    staff_id	role	department	role_in_dept_count	all_staff_count_in_dept	role_perc_per_dept	dept_perc_of_total_staff
STF-e8857831	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-63b9ca1d	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-727e4277	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-322e1cde	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-e2bbe735	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-2a9c9bdb	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-e0c7759c	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-8b6412dc	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-6c29c37d	nurse	general_medicine		19	    27	                    70.37	            21.43
STF-59afa180	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-55594f66	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-611ad324	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-651ff617	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-26466758	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-4f1df27e	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-ed194945	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-ec102fe1	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-a1420039	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-5157d809	nurse	general_medicine        19	    27	                    70.37	            21.43
STF-3a9a90fd	nurse	emergency               19	    29	                    65.52	            23.02
STF-d114bde8	nurse	emergency               19	    29	                    65.52	            23.02
STF-806b98e6	nurse	emergenc                19	    29	                    65.52	            23.02
STF-7dfe6d32	nurse	emergency               19	    29	                    65.52	            23.02
...of 126 staff
*/
--adding a level up by staff_segmentation, goal view
                                   -- (edit naming convention)

                                CREATE VIEW Silver_H.v_Staffing_Analytics AS
                                WITH base AS (
                                    SELECT 
                                        staff_id,
                                        role, 
                                        department, 
                                        -- A: Role in Dept
                                        COUNT(*) OVER (PARTITION BY department, role) AS role_in_dept_count,
                                        -- B: All staff in Dept
                                        COUNT(*) OVER (PARTITION BY department) AS all_staff_in_dept,
                                        -- E: Total of this Role in entire Hospital
                                        COUNT(*) OVER (PARTITION BY role) AS total_role_in_hospital,
                                        -- Global denominator
                                        COUNT(*) OVER () AS total_hospital_staff
                                    FROM Silver_H.updated_staff
                                )
                                SELECT DISTINCT 
                                    department,
                                    role,
                                    role_in_dept_count, 
                                    all_staff_in_dept,
                                    -- C: % Role weight within its own Dept
                                    CAST((role_in_dept_count * 100.0) / all_staff_in_dept AS DECIMAL(10,2)) AS role_perc_within_dept,
                                    -- D: % Dept size relative to the Hospital
                                    CAST((all_staff_in_dept * 100.0) / total_hospital_staff AS DECIMAL(10,2)) AS dept_perc_of_hospital,
                                    -- F: % Global prevalence of this Role
                                    CAST((total_role_in_hospital * 100.0) / total_hospital_staff AS DECIMAL(10,2)) AS role_global_prevalence,
    
                                    -- G: Staffing Balance Insight
                                    CASE 
                                        WHEN (role_in_dept_count * 100.0 / all_staff_in_dept) > (total_role_in_hospital * 100.0 / total_hospital_staff) + 15 
                                            THEN 'High Concentration'
                                        WHEN (role_in_dept_count * 100.0 / all_staff_in_dept) < (total_role_in_hospital * 100.0 / total_hospital_staff) - 15 
                                            THEN 'Low Concentration'
                                        ELSE 'Balanced'
                                    END AS staffing_balance_flag
                                FROM base;

-------------------------------------------------------------------
--Services weekly
-------------------------------------------------------------------
SELECT week, month, department, available_beds,
	   patients_request, patients_admitted,
	   patients_refused, patient_satisfaction,
	   staff_morale,event
FROM Silver_H.services_weekly;

--Base sums of KPIs per department for each month before interdepartmental analysis
SELECT month, SUM(available_beds) AS bed_availability,
	   SUM(patients_request) AS patient_requests, SUM(patients_admitted) AS patients_admissions,
	   SUM(patients_refused) AS patient_refusals, SUM(patient_satisfaction) AS patient_satisfaction_scores,
	   SUM(staff_morale) AS staff_morale_score
FROM Silver_H.services_weekly
GROUP BY month
ORDER BY bed_availability DESC;
/*
month	bed_availability	patient_requests	patients_admissions	patient_refusals	patient_satisfaction_scores	staff_morale_score
12	    1223	            2570	            1107	            1463	            2597	                    2292
2	    557	                1607	            513	                1094	            1291	                    1224
11	    553	                1040	            508	                532	                1196	                    1258
...snapshot of 3 of 12 months
*/

--How many beds have there been consistently, by average, throughout the months of the year?
SELECT month, AVG(available_beds)AS avg_bed_count
FROM Silver_H.services_weekly
GROUP BY month;

/*
month	avg_bed_count
1	33
2	34
3	26
4	28
5	26
6	24
7	22
8	23
9	29
10	32
11	34
12	38
*/

--pt admissions per department
SELECT SUM(patients_admitted) AS total_patients_per_dept,department
FROM Silver_H.services_weekly
GROUP BY department
ORDER BY total_patients_per_dept DESC;

/*
total_patients_per_dept	department
2332	                general_medicine
1686	                surgery
1185	                emergency
648	                    ICU
*/

--pt admissions per department month
SELECT month, SUM(patients_admitted) AS total_patients_per_dept,department
FROM Silver_H.services_weekly
GROUP BY department, month
ORDER BY total_patients_per_dept DESC;
/* 
the top months and departments with the highest admission rates at a glance
month	total_patients_per_dept	department
12	    431	                    general_medicine
12	    323	                    surgery
2	    229	                    general_medicine
12	    217	                    emergency
11	    216                 	general_medicine
10	    206	                    general_medicine
9	    193	                    general_medicine
4	    172	                    general_medicine
1	    160	                    general_medicine
6	    155	                    general_medicine
...snapshot of 48 rows
*/

--pt request, refusal, satisfaction scores per department
SELECT  department,
       SUM(patients_request) AS total_patient_requests,
	   SUM(patients_refused) AS total_patient_refusals,
	   SUM(patient_satisfaction) AS total_patient_satisfaction
	  
FROM Silver_H.services_weekly
GROUP BY department;

/*
department	        total_patient_requests	total_patient_refusals	total_patient_satisfaction
emergency	        6193	                5008	                4050
general_medicine	4270	                1938	                4224
ICU	                789	                    141	                    4244
surgery	            2241	                555	                    4122
*/

SELECT  department,
       MAX(patients_request) AS MAX_patient_requests,
       MIN(patients_request) AS MIN_patient_requests,
	   MAX(patients_refused) AS MAX_patient_refusals,
       MIN(patients_refused) AS MIN_patient_refusals,
	   MAX(patient_satisfaction) AS MAX_patient_satisfaction,
       MIN(patient_satisfaction) AS MIN_patient_satisfaction
FROM Silver_H.services_weekly
GROUP BY department;

/*
department	        MAX_patient_requests	MIN_patient_requests	MAX_patient_refusals	MIN_patient_refusals	MAX_patient_satisfaction	MIN_patient_satisfaction
emergency	        388	                    31	                    363	                    10	                    99                      	62
general_medicine	285	                    25	                    211	                    0	                    99	                        60
ICU	                47	                    5	                    26	                    0	                    98	                        61
surgery         	130	                    15	                    93	                    0	                    99	                        61
*/

--pt request, refusal, satisfaction scores per department month
SELECT TOP(10)
       month,
       department,
       AVG(patients_request) AS total_patient_requests,
	   AVG(patients_refused) AS total_patient_refusals,
	   AVG(patient_satisfaction) AS total_patient_satisfaction	   
FROM Silver_H.services_weekly
GROUP BY department, month
ORDER BY total_patient_satisfaction	DESC
/*
month	department	        total_patient_requests	total_patient_refusals	total_patient_satisfaction
6	    general_medicine	63	                    24	                    92
9	    surgery	            42	                    11	                    91
2	    surgery	            48	                    21	                    89
5	    emergency	        87	                    68	                    89
5	    surgery	            35	                    2	                    88
10	    ICU	                17	                    3	                    88
4	    ICU	                13	                    1	                    87
12	    general_medicine	115                 	61	                    87
7	    ICU               	8	                    0	                    85
6	    ICU             	9	                    0	                    84
*/ -- OF 48,ordered by highest patient satisfaction scores

--grouping events (flu, donation, strike, none) by department month 
SELECT month,event, department 
FROM Silver_H.services_weekly;

--interest-specific event exploration
SELECT month,event, department 
FROM Silver_H.services_weekly
WHERE event LIKE '%donation%' -- when event = 'donation' was blank; solution below:
                    -- error fixing
                    UPDATE Silver_H.services_weekly
                    SET event = LTRIM(RTRIM(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(event, CHAR(9), ''),   -- Remove Tabs
                                        CHAR(10), ''),                     -- Remove Line Feeds
                                    CHAR(13), '')                          -- Remove Carriage Returns
                                ));

                    -- Verify the fix
                    SELECT '*' + event + '*' as boxed_event
                    FROM Silver_H.services_weekly
                    WHERE event LIKE '%donation%'; -- 14 places fixed +

                    UPDATE Silver_H.services_weekly
                    SET event = REPLACE(event, CHAR(160), '')
SELECT month,event, department 
FROM Silver_H.services_weekly
WHERE event = 'donation'
/*
1	donation	ICU
2	donation	surgery
2	donation	surgery
2	donation	general_medicine
3	donation	emergency
3	donation	ICU
5	donation	emergency
6	donation	surgery
6	donation	general_medicine
6	donation	general_medicine
7	donation	emergency
8	donation	surgery
9	donation	emergency
11	donation	surgery
*/

--Prepping a general department view
WITH DeptAttendance AS (
    SELECT 
        week, 
        department, 
        CAST(AVG(CAST(attendance AS FLOAT)) AS DECIMAL(10,2)) AS weekly_attendance_rate
    FROM Silver_H.staff_schedule
    GROUP BY week, department
)
SELECT DISTINCT
    sw.month,
    sw.department, 
    sw.event,
    COUNT(sw.event) OVER(PARTITION BY sw.department, sw.event, sw.month) AS event_occurrence,
    AVG(sw.available_beds) OVER(PARTITION BY sw.department, sw.month) AS avg_beds,
    SUM(sw.patients_admitted) OVER(PARTITION BY sw.department, sw.month) AS total_admissions,
    AVG(CAST(sw.staff_morale AS FLOAT)) OVER(PARTITION BY sw.department, sw.month) AS avg_morale,
    AVG(da.weekly_attendance_rate) OVER(PARTITION BY sw.department, sw.month) AS avg_dept_attendance
FROM Silver_H.services_weekly sw
LEFT JOIN DeptAttendance da 
    ON sw.week = da.week 
    AND sw.department = da.department;




--pedaling back to analyzing pt satisfaction, staff morale and service differential KPIs per department
WITH 
Total_dept_kpis AS
		(
		SELECT
		department,
		AVG(CAST(patient_satisfaction AS FLOAT)) OVER(PARTITION BY department) AS avg_pt_satisfaction_per_dept,
		AVG(CAST(staff_morale AS FLOAT)) OVER(PARTITION BY department) AS avg_staff_morale_per_dept,
		SUM(patients_request) OVER(PARTITION BY department) AS total_requests,
		SUM(patients_refused) OVER(PARTITION BY department) AS total_refusals
		FROM Silver_H.services_weekly 
		)
SELECT DISTINCT department, 
				-- These are now "Performance Scores" out of 100 or your max scale
                CAST(avg_pt_satisfaction_per_dept AS DECIMAL(10,2)) AS pt_satisfaction_score, 
                CAST(avg_staff_morale_per_dept AS DECIMAL(10,2)) AS staff_morale_score,
                total_requests,
                total_refusals,
                -- Service Rendered (Total volume)
                 total_requests - total_refusals AS total_services_differential,
    
                -- Efficiency Ratio (Percent of requests actually fulfilled)
                CAST(((total_requests - total_refusals) * 100.0) / NULLIF(total_requests, 0) AS DECIMAL(10,2)) AS fulfillment_rate_perc
FROM Total_dept_kpis;
-----------------------------------------------------
--patients
-----------------------------------------------------

        -- Diagnostic to see if CHAR(160) is hiding in your department names
        UPDATE Silver_H.patients
        SET age = LTRIM(RTRIM(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(CAST(age AS NVARCHAR(max)), CHAR(9), ''),   -- Remove Tabs
                            CHAR(10), ''),                                          -- Remove Line Feeds
                        CHAR(13), ''),                                              -- Remove Carriage Returns
                    CHAR(160), '')
                    ));

SELECT age,
       NTILE(3) OVER(ORDER BY age) AS age_group, 
	   DATEDIFF(day, arrival_date,departure_date) AS length_of_stay,
       satisfaction,
	   AVG(CAST(satisfaction AS FLOAT)) OVER() AS overall_avg_satisfaction
FROM Silver_H.patients

/*
age	age_group	length_of_stay	satisfaction	overall_avg_satisfaction
0	1	        14	            82	            79.597
0	1	        8	            71	            79.597
0	1	        6	            79	            79.597
0	1	        13          	91	            79.597
...0f 1000
*/
---patient view preparation
SELECT 
       patient_id,
       age,
       department,
       NTILE(3) OVER(ORDER BY age) AS age_group, 
	   DATEDIFF(day, arrival_date,departure_date) AS length_of_stay,
       satisfaction,
	   CAST(AVG(CAST(satisfaction AS FLOAT)) OVER() AS DECIMAL (10,2)) AS pt_avg_satisfaction,
       CAST(AVG(CAST(satisfaction AS FLOAT)) OVER(PARTITION BY department) AS DECIMAL (10,2)) dept_avg_satisfaction,
       DATENAME(month, arrival_date) AS arrival_month_name,
       DATEPART(week, arrival_date) AS arrival_week_num
FROM Silver_H.patients


--Is the sum satisfaction per dept in the patients table perimetric or equal to the
----sum satisfaction is the services_weekly patient_satisfaction per dept

SELECT department, AVG(patient_satisfaction) AS dept_satisfaction
FROM Silver_H.services_weekly
GROUP BY department
ORDER BY dept_satisfaction;
/*
department	        dept_satisfaction
emergency	        77
surgery	            79
general_medicine	81
ICU	                81
*/

SELECT department, AVG(satisfaction) AS patient_dept_satisfaction
FROM Silver_H.patients
GROUP BY department
ORDER BY patient_dept_satisfaction;
/*
department	        patient_dept_satisfaction
general_medicine	78
ICU	                79
emergency	        79
surgery         	80
*/
--there is a point or 2 differences in satisfaction points from the former frame per department
--and the latter by individual patient satisfaction in the patients table

