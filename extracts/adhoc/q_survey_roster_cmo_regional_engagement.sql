SELECT df_employee_number
      ,userprincipalname
      ,preferred_first_name
      ,preferred_last_name
      ,CASE 
        WHEN legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
        WHEN legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
        WHEN legal_entity_name = 'KIPP New Jersey' THEN 'KIPP New Jersey'
        WHEN legal_entity_name = 'KIPP Miami' THEN 'Miami'
       END AS entity
      ,CASE 
        WHEN primary_site IN ('Room 9 - 60 Park Pl', 'Room 10 - 121 Market St', 'Room 11 - 1951 NW 7th Ave') THEN 'Not School Based'
        ELSE 'school-based'
       END AS school_based
      ,CASE 
        WHEN primary_job = 'Head of Schools' THEN 'Head of Schools'
        WHEN primary_job = 'Assistant Superintendent' THEN 'Head of Schools'
        WHEN primary_job IN ('Teacher', 'Teacher in Residence', 'Learning Specialist', 'Learning Specialist Coordinator', 'Teacher, ESL') THEN 'Teacher'
        WHEN primary_job = 'Executive Director' THEN 'Executive Director'
        WHEN primary_job IN ('Associate Director of School Operations') THEN 'ADSO'
        WHEN primary_job IN ('Director Campus Operations', 'Director School Operations', 'Director of Campus Operations', 'Fellow School Operations Director') THEN 'DSO'
        WHEN primary_job = 'Managing Director of Operations' THEN 'MDO'
        WHEN primary_job = 'Managing Director of School Operations' THEN 'MDSO'
        WHEN primary_job = 'School Leader' THEN 'School Leader'
        WHEN primary_job IN ('Assistant School Leader', 'Assistant School Leader, SPED', 'School Leader in Residence') THEN 'AP'
        ELSE 'Other'
       END AS usergroup
FROM gabby.people.staff_crosswalk_static
WHERE [status] NOT IN ('Terminated', 'Prestart')
