USE gabby 
GO

CREATE OR ALTER VIEW surveys.survey_roster_cmo_regional_engagement AS

SELECT df_employee_number
      ,userprincipalname
      ,preferred_first
      ,preferred_last
      ,CASE WHEN legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
            WHEN legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
            WHEN legal_entity_name = 'KIPP New Jersey' THEN 'KIPP New Jersey'
            WHEN legal_entity_name = 'KIPP Miami' THEN 'Miami'
       END AS entity
      ,CASE WHEN location_description IN ('Room 9 - 60 Park Pl', 'Room 10 - 740 Chestnut St', 'Room 11 - 6745 NW 23rd Ave') THEN 'Not School Based'
            ELSE 'school-based'
       END AS 'school_based'
      ,CASE WHEN job_title_description IN ('Teacher', 'Teacher in Residence', 'Learning Specialist', 'Learning Specialist Coordinator', 'Teacher, ESL') THEN 'Teacher'
            WHEN job_title_description = 'Executive Director' THEN 'Executive Director'
            WHEN job_title_description IN ('Associate Director of School Operations') THEN 'ADSO'
            WHEN job_title_description IN ('Director Campus Operations', 'Director School Operations', 'Director of Campus Operations') THEN 'DSO'
            WHEN job_title_description = 'Managing Director of Operations' THEN 'MDO'
            WHEN job_title_description = 'Managing Director of School Operations' THEN 'MDSO'
            WHEN df_employee_number IN (100074, 100394, 100968, 102091) THEN 'Head of Schools'
            WHEN job_title_description = 'School Leader' THEN 'School Leader'
            WHEN job_title_description IN ('Assistant School Leader', 'Assistant School Leader, SPED', 'School Leader in Residence') THEN 'AP'
            ELSE 'Other'
       END AS usergroup
FROM tableau.staff_roster
WHERE position_status NOT IN ('Terminated', 'Prestart')