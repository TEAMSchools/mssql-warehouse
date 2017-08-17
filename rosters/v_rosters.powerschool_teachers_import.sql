USE gabby
GO

ALTER VIEW rosters.powerschool_teachers_import AS

WITH managers AS (
  SELECT DISTINCT reports_to_position_id
  FROM gabby.adp.staff_roster
  WHERE rn_curr = 1
    AND location_description NOT IN ('KIPP NJ', 'Room 9', 'TEAM Schools')    
    AND job_title_description NOT IN ('Custodian', 'Food Service Worker', 'Security', 'Intern')
    AND reports_to_position_id IS NOT NULL
 )

,current_teachers AS (
  SELECT teachernumber
        ,schoolid
        ,CASE WHEN homeschoolid = 999999 THEN 0 ELSE homeschoolid END AS homeschoolid
  FROM gabby.powerschool.teachers
 )

SELECT sub.teachernumber
      ,sub.first_name
      ,sub.last_name
      ,CASE WHEN sub.status = 1 THEN sub.loginid ELSE '' END AS loginid
      ,CASE WHEN sub.status = 1 THEN sub.teacherloginid ELSE '' END AS teacherloginid
      ,sub.email_addr      
      ,CONVERT(INT,COALESCE(t.schoolid,sub.homeschoolid,0)) AS schoolid -- temp fix until we clean up ADP
      ,CONVERT(INT,COALESCE(t.homeschoolid,sub.homeschoolid,0)) AS homeschoolid -- temp fix until we clean up ADP
      ,sub.status      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS ptaccess      
      /* OFF UNTIL WE CLEAN UP ADP
      ,staffstatus      
      ,[group]      
      ,psaccess
      ,CASE WHEN ptaccess = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN psaccess = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN [group] = 8 THEN (SELECT KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT schoolid, '; ') FROM KIPP_NJ..STUDENTS WITH(NOLOCK)) ELSE NULL END AS canchangeschool
      --*/
FROM
    (
     SELECT COALESCE(LTRIM(RTRIM(STR(link.TEACHERNUMBER))), adp.[associate_id]) AS teachernumber           
           ,adp.preferred_first AS first_name
           ,adp.preferred_last AS last_name
           ,ISNULL(LOWER(dir.sAMAccountName),'') AS loginid
           ,ISNULL(LOWER(dir.sAMAccountName),'') AS teacherloginid
           ,ISNULL(LOWER(dir.mail),'') AS email_addr      
           ,CASE
             WHEN adp.location_code IS NULL THEN 0
             WHEN adp.location_code = 1 THEN 133570965
             WHEN adp.location_code = 2 THEN 0
             WHEN adp.location_code = 4 THEN 73254
             WHEN adp.location_code = 5 THEN 73252
             WHEN adp.location_code = 7 THEN 73253
             WHEN adp.location_code = 8 THEN 73255
             WHEN adp.location_code = 9 THEN 73256
             WHEN adp.location_code = 10 THEN 73257
             WHEN adp.location_code = 11 THEN 73257
             WHEN adp.location_code = 12 THEN 179901
             WHEN adp.location_code = 13 THEN 0
             WHEN adp.location_code = 14 THEN 0
             WHEN adp.location_code = 15 THEN 73258
             WHEN adp.location_code = 16 THEN 179902
             WHEN adp.location_code = 17 THEN 179903
             WHEN adp.location_code = 18 THEN 179901
            END AS homeschoolid      
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 1
             WHEN link.is_master = 0 THEN 1
             --WHEN adp.employee_type = 'Intern' OR adp.job_title_description = 'Intern' THEN 12
             WHEN adp.home_department_code IN ('DATAAN') THEN 8 -- data team
             WHEN adp.home_department_description = 'R9 IT' THEN 8 -- tech team
             WHEN adp.job_title_description IN ('Registrar') THEN 4  
             WHEN adp.job_title_description IN ('Case Manager Assistant',	'Social Worker') THEN 11
             WHEN adp.job_title_description LIKE '%Nurse%' THEN 14
             -- ops roles
             WHEN adp.job_title_description IN ('Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students','Director of School Operations','Office Manager'
                                   ,'Regional Literacy Coach','School Leader')              
               OR adp.home_department_description IN ('R9 School Ops','College Placement','Enrollment')
               OR adp.home_department_description LIKE '%Alumni Support%'
               OR adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 9
             /* instructional staff */
             WHEN adp.job_title_description IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') 
               OR adp.benefits_eligibility_class_description NOT LIKE '%Non-Instructional%' THEN 5
             ELSE 1
            END AS [group]
           ,CASE
             WHEN adp.termination_date < CONVERT(DATE,GETDATE()) THEN 2
             --WHEN adp.position_status = 'Terminated' THEN 2
             WHEN link.is_master = 0 THEN 2
             WHEN adp.job_title_description = 'Intern' THEN 2 --OR adp.employee_type = 'Intern'
             WHEN adp.position_status IN ('Active','Leave') OR adp.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
             /* OFF UNTIL ADP GETS CLEANED UP             
             WHEN adp.job_title_description IN ('Registrar','Case Manager Assistant','Social Worker','Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students'
                                   ,'Director of School Operations','Office Manager','Regional Literacy Coach','School Leader','Paraprofessional','Aide - Instructional'
                                   ,'Fellow','Learning Specialist','Teacher')
                  OR adp.job_title_description LIKE '%Nurse%'
                  OR adp.home_department_description LIKE '%Alumni Support%'                   
                  OR adp.home_department_code IN ('DATAAN') 
                  OR adp.home_department_description IN ('R9 School Ops','College Placement','Enrollment','R9 IT')
                  OR adp.benefits_elig_class NOT LIKE '%Non-Instructional%' 
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers)
                  THEN 1        
             */
             ELSE 2
            END AS [status]
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 0
             WHEN link.is_master = 0 THEN 0
             WHEN adp.job_title_description IN ('Registrar','Case Manager Assistant','Social Worker','Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students'
                                   ,'Director of School Operations','Office Manager','Regional Literacy Coach','School Leader','Intern','Paraprofessional','Aide - Instructional')
                  OR adp.job_title_description LIKE '%Nurse%'
                  OR adp.home_department_description LIKE '%Alumni Support%' 
                  --OR adp.employee_type = 'Intern'
                  OR adp.home_department_code IN ('DATAAN') 
                  OR adp.home_department_description IN ('R9 School Ops','College Placement','Enrollment','R9 IT')                  
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers)
                  THEN 2             
             WHEN adp.job_title_description IN ('Fellow',	'Learning Specialist',	'Teacher') OR adp.benefits_eligibility_class_description NOT LIKE '%Non-Instructional%' THEN 1
             ELSE 0
            END AS staffstatus
           ,CASE
             WHEN adp.position_status = 'Terminated' THEN 0
             WHEN link.is_master = 0 THEN 0
             WHEN adp.job_title_description = 'Intern' --OR adp.employee_type = 'Intern'
                    THEN 0
             WHEN adp.home_department_code IN ('DATAAN') THEN 1 -- data team
             WHEN adp.home_department_description = 'R9 IT' THEN 1 -- tech team
             WHEN adp.job_title_description IN ('Registrar') THEN 0
             WHEN adp.job_title_description IN ('Case Manager Assistant',	'Social Worker') THEN 1
             WHEN adp.job_title_description LIKE '%Nurse%' THEN 0
             /* ops roles */
             WHEN adp.home_department_description IN ('R9 School Ops','College Placement','Enrollment') THEN 1
             WHEN adp.job_title_description IN ('Aide - Non-Instructional','Assistant School Leader','Dean of Instruction','Dean of Students','Director of School Operations','Office Manager'
                                   ,'Regional Literacy Coach','School Leader')              
                  OR adp.home_department_description LIKE '%Alumni Support%'
                  OR adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 0
             /* instructional staff */
             WHEN adp.job_title_description IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') OR adp.benefits_eligibility_class_description NOT LIKE '%Non-Instructional%' THEN 1
             ELSE 0
            END AS ptaccess
           ,CASE
             /* allow */
             WHEN adp.home_department_code IN ('DATAAN','002004','COLPLC','ENROLL','002003','ALUSPT','002008') THEN 1 /* data, tech, R9 ops, enrollment, KTC */
             WHEN adp.position_id IN (SELECT reports_to_position_id FROM managers) THEN 1 /* managers */
             WHEN adp.job_title_description IN ('Registrar' /* specific positions */
                                   ,'Case Manager Assistant'
                                   ,'Social Worker'
                                   ,'Aide - Non-Instructional'
                                   ,'Assistant School Leader'
                                   ,'Dean of Instruction'
                                   ,'Dean of Students'
                                   ,'Director of School Operations'
                                   ,'Office Manager'
                                   ,'Regional Literacy Coach'
                                   ,'School Leader'
                                   ,'Nurse'
                                   ,'School Nurse Coordinator')
                                   THEN 1
             /* deny */
             WHEN adp.position_status = 'Terminated' /* terminated */
                  OR link.is_master = 0 /* dupes */
                  OR adp.job_title_description = 'Intern' --OR adp.employee_type = 'Intern' /* interns */
                  OR adp.job_title_description IN ('Paraprofessional',	'Aide - Instructional',	'Fellow',	'Learning Specialist',	'Teacher') /* instructional staff */ 
                  THEN 0
             ELSE 0
            END AS psaccess
           /* -- auditing 
           ,link.is_master
           ,adp.position_status
           ,adp.[home_department_description]      
           ,adp.[job_title_description]            
           --,adp.[employee_type]
           ,adp.[benefits_elig_class]                  
           -- */           
     FROM gabby.adp.staff_roster adp
     JOIN gabby.adsi.user_attributes dir
       ON adp.position_id = dir.employeenumber
      AND dir.is_active = 1
     LEFT OUTER JOIN gabby.people.adp_ps_id_link link
       ON adp.associate_id = link.associate_id
     WHERE adp.rn_curr = 1     
       AND adp.associate_id NOT IN ('OJOCGAWIL','B8IZPXIOF','CLB53DM3M') /* data team */       
    ) sub
LEFT OUTER JOIN current_teachers t
  ON sub.teachernumber = t.teachernumber