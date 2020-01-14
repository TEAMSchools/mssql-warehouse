USE gabby;
GO

CREATE OR ALTER VIEW extracts.survey_roster_self_and_others AS

SELECT df_employee_number
      ,preferred_first_name
      ,preferred_last_name
      ,userprincipalname
      ,primary_site
      ,primary_job
FROM gabby.people.staff_crosswalk_static
WHERE [status] != 'Terminated'
  AND ((primary_job IN ('Dean', 'Dean of Students', 'Dean of Students and Families') AND is_manager = 'No')
         OR (primary_on_site_department = 'KTC' AND primary_site = 'KIPP Newark Collegiate Academy')
         OR (primary_job IN ('Learning Specialist', 'Learning Specialist Coordinator', 'Teacher', 'Teacher in Residence'
                       ,'Teacher, ESL', 'Social Worker', 'Paraprofessional', 'Behavior Analyst', 'Behavior Specialist'
                       ,'Speech Therapist', 'Speech Language Pathologist', 'Occupational Therapist'
                       ,'School Psychologist', 'Learning Disabilities Teacher Consultant', 'Assistant Dean'
                       ,'Aide (instructional)', 'School Leader', 'Assistant School Leader'
                       ,'Assistant School Leader, SPED', 'School Leader', 'School Leader in Residence', 'Director'
                       ,'Director Campus Operations', 'Director School Operations', 'Director of Campus Operations'
                       ,'Associate Director of School Operations', 'Fellow School Operations Director'
                       ,'Academic Operations Manager', 'School Operations Manager', 'Receptionist', 'Custodian'
                       ,'Senior Custodian', 'Nurse', 'Student Support Advocate')))