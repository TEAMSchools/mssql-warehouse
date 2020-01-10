USE gabby 
GO

CREATE OR ALTER VIEW surveys.survey_roster_self_and_others AS


SELECT df_employee_number
,preferred_name
,userprincipalname
,location_description
,job_title_description
FROM tableau.staff_roster
WHERE position_status != 'Terminated'
AND
(job_title_custom IN ('Learning Specialist'
                     ,'Learning Specialist Coordinator'
                     ,'Teacher'
                     ,'Teacher in Residence'
                     ,'Teacher, ESL'
                     ,'Social Worker'
                     ,'Paraprofessional'
                     ,'Behavior Analyst'
                     ,'Behavior Specialist'
                     ,'Speech Therapist'
                     ,'Speech Language Pathologist'
                     ,'Occupational Therapist'
                     ,'School Psychologist'
                     ,'Learning Disabilities Teacher Consultant'
                     ,'Assistant Dean'
                     ,'Aide (instructional)'
                     ,'School Leader'
                     ,'Assistant School Leader'
                     ,'Assistant School Leader, SPED'
                     ,'School Leader'
                     ,'School Leader in Residence'
                     ,'Director'
                     ,'Director Campus Operations'
                     ,'Director School Operations'
                     ,'Director of Campus Operations'
                     ,'Associate Director of School Operations'
                     ,'Fellow School Operations Director'
                     ,'Academic Operations Manager'
                     ,'School Operations Manager'
                     ,'Receptionist' 
                     ,'Custodian'
                     ,'Senior Custodian' 
                     ,'Nurse' 
                     ,'Student Support Advocate'
                     )
  OR (
      job_title_custom IN ('Dean'
                          ,'Dean of Students'
                          ,'Dean of Students and Families')
      AND is_management = 'No'
  )
  OR (
      home_department_description = 'KTC'
      AND location_description = 'KIPP Newark Collegiate Academy'
   )
  )