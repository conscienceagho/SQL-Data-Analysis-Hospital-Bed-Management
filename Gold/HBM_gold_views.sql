
/*
================================================================
--Gold Layer: Divvy Trips 2025
=================================================================
  Purpose: 
  This layer presents some *views* for healthcare dats logic and reporting
 with the preparation vir data table creation and visualizations
==================================================================
  */


  CREATE VIEW Gold_H.Staffing_Analytics AS
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
                                    CAST((all_staff_in_dept * 100.0) / total_hospital_staff AS DECIMAL(10,2)) AS role_subt_perc_all_dept,
                                    -- F: % Global prevalence of this Role
                                    CAST((total_role_in_hospital * 100.0) / total_hospital_staff AS DECIMAL(10,2)) AS role_perc_all_staff,
    
                                    -- G: Staffing Balance Insight
                                    CASE 
                                        WHEN (role_in_dept_count * 100.0 / all_staff_in_dept) > (total_role_in_hospital * 100.0 / total_hospital_staff) + 15 
                                            THEN 'High Concentration'
                                        WHEN (role_in_dept_count * 100.0 / all_staff_in_dept) < (total_role_in_hospital * 100.0 / total_hospital_staff) - 15 
                                            THEN 'Low Concentration'
                                        ELSE 'Balanced'
                                    END AS staffing_balance_flag
                                FROM base;


CREATE VIEW Gold_H.services_KPI_Analytics AS
                                WITH Total_dept_kpis AS
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


CREATE VIEW Gold_H.department_overview AS
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
                                    COUNT(CASE WHEN sw.event <> 'None' THEN sw.event END) OVER(PARTITION BY sw.department, sw.event, sw.month) AS event_occurrence,
                                    AVG(sw.available_beds) OVER(PARTITION BY sw.department, sw.month) AS avg_beds,
                                    SUM(sw.patients_admitted) OVER(PARTITION BY sw.department, sw.month) AS total_admissions,
                                    AVG(CAST(sw.staff_morale AS FLOAT)) OVER(PARTITION BY sw.department, sw.month) AS avg_morale,
                                    AVG(da.weekly_attendance_rate) OVER(PARTITION BY sw.department, sw.month) AS avg_dept_attendance
                                FROM Silver_H.services_weekly sw
                                LEFT JOIN DeptAttendance da 
                                    ON sw.week = da.week 
                                    AND sw.department = da.department;

CREATE VIEW Gold_H.patients AS
                                SELECT 
                                       patient_id,
                                       age,
                                       CASE WHEN age <= 30 THEN '0-30' WHEN age >30 AND age <= 60 THEN '31-60' ELSE '61+' END AS age_bracket,                        
                                       department,
	                                   DATEDIFF(day, arrival_date,departure_date) AS length_of_stay,
                                       satisfaction,
	                                   CAST(AVG(CAST(satisfaction AS FLOAT)) OVER() AS DECIMAL (10,2)) AS pt_avg_satisfaction,
                                       CAST(AVG(CAST(satisfaction AS FLOAT)) OVER(PARTITION BY department) AS DECIMAL (10,2)) AS dept_avg_satisfaction,
                                       DATENAME(month, arrival_date) AS arrival_month_name,
                                       DATEPART(week, arrival_date) AS arrival_week_num
                                FROM Silver_H.patients;
       
