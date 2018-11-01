USE gabby
GO

CREATE OR ALTER VIEW pm.teacher_goal_scaffold AS

WITH teacher_crosswalk AS (
  SELECT sr.df_employee_number
        ,sr.preferred_name        
        ,sr.primary_site
        ,sr.primary_on_site_department
        ,sr.grades_taught
        ,sr.primary_job
        ,sr.legal_entity_name        
        ,sr.is_active
        ,sr.primary_site_schoolid
        ,sr.manager_df_employee_number
        ,sr.manager_name
        ,CASE
          WHEN sr.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
          WHEN sr.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
          WHEN sr.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
         END AS db_name
      
        ,COALESCE(idps.ps_teachernumber, sr.adp_associate_id, CONVERT(VARCHAR(25),sr.df_employee_number)) AS ps_teachernumber

        ,ads.samaccountname AS staff_username

        ,adm.samaccountname AS manager_username
  FROM gabby.dayforce.staff_roster sr
  LEFT JOIN gabby.people.id_crosswalk_powerschool idps
    ON sr.df_employee_number = idps.df_employee_number
   AND idps.is_master = 1
  LEFT JOIN gabby.adsi.user_attributes_static ads
    ON CONVERT(VARCHAR(25),sr.df_employee_number) = ads.employeenumber
  LEFT JOIN gabby.adsi.user_attributes_static adm
    ON CONVERT(VARCHAR(25),sr.manager_df_employee_number) = adm.employeenumber
  WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator')
    AND ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
 )

,ps_section_teacher AS (
  SELECT sec.id AS sectionid
        ,sec.section_number
        ,sec.section_type
        ,sec.course_number_clean AS course_number        
        ,sec.db_name
                
        ,t.teachernumber
  FROM gabby.powerschool.sections sec  
  JOIN gabby.powerschool.sectionteacher st
    ON sec.id = st.sectionid
   AND sec.db_name = st.db_name
  JOIN gabby.powerschool.teachers_static t
    ON st.teacherid = t.id
   AND st.db_name = t.db_name
  WHERE (sec.section_type != 'SC' OR sec.section_type IS NULL)
 )

/* Team/Individual Goals */
SELECT sr.df_employee_number
      ,sr.ps_teachernumber
      ,sr.preferred_name      
      ,sr.primary_site
      ,sr.primary_on_site_department
      ,sr.grades_taught
      ,sr.primary_job
      ,sr.legal_entity_name
      ,sr.is_active
      ,sr.primary_site_schoolid      
      ,sr.manager_df_employee_number
      ,sr.manager_name
      ,sr.staff_username
      ,sr.manager_username
      ,sr.db_name

      ,tg.academic_year      
      ,tg.goal_type
      ,tg.df_primary_on_site_department AS goal_department
      ,tg.grade_level
      ,tg.is_sped_goal
      ,tg.ps_course_number
      ,tg.metric_label
      ,CONVERT(VARCHAR(125),tg.metric_name) AS metric_name
      ,CONVERT(FLOAT,tg.tier_1) AS tier_1
      ,CONVERT(FLOAT,tg.tier_2) AS tier_2
      ,CONVERT(FLOAT,tg.tier_3) AS tier_3
      ,CONVERT(FLOAT,tg.tier_4) AS tier_4
      ,CONVERT(FLOAT,tg.prior_year_outcome) AS prior_year_outcome
      ,tg.data_type

      ,NULL AS sectionid
      ,NULL AS student_number
      ,NULL AS dateenrolled
      ,NULL AS dateleft
      ,NULL AS student_grade_level

      ,tm.metric_term
      ,tm.pm_term
FROM teacher_crosswalk sr
JOIN gabby.pm.teacher_goals tg
  ON sr.primary_site = tg.df_primary_site
 AND sr.grades_taught = tg.grade
 AND tg.goal_type IN ('Team', 'Individual')
JOIN gabby.pm.teacher_goals_term_map tm
  ON tg.academic_year = tm.academic_year
 AND tg.metric_name = tm.metric_name
WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator')

UNION ALL

/* Class Goals - Non-SpEd */
SELECT sr.df_employee_number
      ,sr.ps_teachernumber
      ,sr.preferred_name
      ,sr.primary_site
      ,sr.primary_on_site_department
      ,sr.grades_taught
      ,sr.primary_job
      ,sr.legal_entity_name
      ,sr.is_active
      ,sr.primary_site_schoolid      
      ,sr.manager_df_employee_number
      ,sr.manager_name
      ,sr.staff_username
      ,sr.manager_username
      ,sr.db_name

      ,tg.academic_year      
      ,tg.goal_type
      ,tg.df_primary_on_site_department AS goal_department
      ,tg.grade_level
      ,tg.is_sped_goal
      ,tg.ps_course_number
      ,tg.metric_label
      ,CONVERT(VARCHAR(125),tg.metric_name) AS metric_name
      ,CONVERT(FLOAT,tg.tier_1) AS tier_1
      ,CONVERT(FLOAT,tg.tier_2) AS tier_2
      ,CONVERT(FLOAT,tg.tier_3) AS tier_3
      ,CONVERT(FLOAT,tg.tier_4) AS tier_4
      ,CONVERT(FLOAT,tg.prior_year_outcome) AS prior_year_outcome
      ,tg.data_type

      ,st.sectionid

      ,enr.student_number
      ,enr.dateenrolled
      ,enr.dateleft

      ,co.grade_level AS student_grade_level

      ,tm.metric_term
      ,tm.pm_term
FROM teacher_crosswalk sr
JOIN gabby.pm.teacher_goals tg
  ON sr.primary_site = tg.df_primary_site
 AND tg.goal_type = 'Class'
 AND tg.is_sped_goal = 0
JOIN ps_section_teacher st
  ON sr.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
 AND sr.db_name = st.db_name
 AND tg.ps_course_number = st.course_number COLLATE Latin1_General_BIN 
JOIN gabby.powerschool.course_enrollments_static enr
  ON st.sectionid = enr.abs_sectionid
 AND st.db_name = enr.db_name
JOIN gabby.powerschool.cohort_identifiers_static co
  ON enr.student_number = co.student_number
 AND enr.academic_year = co.academic_year
 AND enr.db_name = co.db_name
 AND co.rn_year = 1
JOIN gabby.pm.teacher_goals_term_map tm
  ON tg.academic_year = tm.academic_year
 AND tg.metric_name = tm.metric_name
WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher')

UNION ALL

/* Class Goals - SpEd */
SELECT sr.df_employee_number
      ,sr.ps_teachernumber
      ,sr.preferred_name      
      ,sr.primary_site
      ,sr.primary_on_site_department
      ,sr.grades_taught
      ,sr.primary_job
      ,sr.legal_entity_name
      ,sr.is_active
      ,sr.primary_site_schoolid      
      ,sr.manager_df_employee_number
      ,sr.manager_name
      ,sr.staff_username
      ,sr.manager_username
      ,sr.db_name

      ,tg.academic_year      
      ,tg.goal_type
      ,tg.df_primary_on_site_department AS goal_department
      ,tg.grade_level
      ,tg.is_sped_goal
      ,tg.ps_course_number
      ,tg.metric_label
      ,CONVERT(VARCHAR(125),tg.metric_name) AS metric_name
      ,CONVERT(FLOAT,tg.tier_1) AS tier_1
      ,CONVERT(FLOAT,tg.tier_2) AS tier_2
      ,CONVERT(FLOAT,tg.tier_3) AS tier_3
      ,CONVERT(FLOAT,tg.tier_4) AS tier_4
      ,CONVERT(FLOAT,tg.prior_year_outcome) AS prior_year_outcome
      ,tg.data_type

      ,st.sectionid

      ,enr.student_number
      ,enr.dateenrolled
      ,enr.dateleft

      ,co.grade_level AS student_grade_level

      ,tm.metric_term
      ,tm.pm_term
FROM teacher_crosswalk sr
JOIN gabby.pm.teacher_goals tg
  ON sr.primary_site = tg.df_primary_site
 AND tg.goal_type = 'Class'
 AND tg.is_sped_goal = 1
JOIN ps_section_teacher st
  ON sr.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
 AND sr.db_name = st.db_name
 AND tg.ps_course_number = st.course_number COLLATE Latin1_General_BIN 
JOIN gabby.powerschool.course_enrollments_static enr
  ON st.sectionid = enr.abs_sectionid
 AND st.db_name = enr.db_name
JOIN gabby.powerschool.cohort_identifiers_static co
  ON enr.student_number = co.student_number
 AND enr.academic_year = co.academic_year
 AND enr.db_name = co.db_name
 AND co.rn_year = 1
JOIN gabby.pm.teacher_goals_term_map tm
  ON tg.academic_year = tm.academic_year
 AND tg.metric_name = tm.metric_name
WHERE sr.primary_job IN ('Learning Specialist', 'Learning Specialist Coordinator')