# SQL-Data-Analysis-Hospital-Bed-Management

## This dataset is provided by Kaggle at the link: https://www.kaggle.com/datasets/jaderz/hospital-beds-management/data

# Purpose- Mirrors the 'Ask' Phase:
-- To observe all stages of the analysis process, explore and analyze hospital data in replica of a real life scenario. Some questions these dataset can be reasoned with (along with the 5 whys which may or may not fell tangibly  beyond the dataset) include:
-- What is the most common age-group in the hospital? What service do they usually seek?
-- For the average duration of stay for patients, what is their satisfaction scores
-- Are they enough beds more than the average number of beds in the hospital
-- Is staff morale, buy score,  directly affected by patient satisfaction score, present or absent resources versus an external factor
-- Is staff attendance regular or is it more in one department more than the other?
-- Of the three "events" in this dataset *none*, *donation*, and *flu*, are there any peculiarities across departments and/or over time
-- Where service differential may exist between patients requests (perceived to be service rendered) and patient's refusals ( perceived to be service not rendered), what does the data reflect across departments next to patient satisfaction scores and staff morale scores.


# Prepare Phase
## Patients table: This dataset is patients centered, hence, the name. It tracks patients individual journeys, 
 clinical service and satisfaction
## Schema:

age
age-group (new Column)
arrival_date
departure_date 
duration_of_stay (new column)
service
satisfaction 

# Staff Attendance: This dataset is staff-cenntered on the basis of staff attendance days across departments
## Schema:

staff_id
staff_name
role
service
attendance

# Services Weekly: This dataset is inclusive of hospital , patient, staff, and department activity. This
includes bed availability, patient requests, staff morale and others:
## Schema:

week
month
service
available_beds
patients_request
patients_admitted
patients_refused
patient_satisfaction
staff_morale
event

# Analyse

# Share/ACt Phase

