USE gabby
GO

CREATE OR ALTER VIEW tableau.pm_teacher_goals AS

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
  WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher', 'Learning Specialist')
    AND ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
 )

,teacher_goal_scaffold AS (
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
        ,tg.grade
        ,tg.is_sped_goal
        ,tg.ps_course_number
        ,tg.metric_label
        ,tg.metric_name      
        ,tg.tier_1
        ,tg.tier_2
        ,tg.tier_3
        ,tg.tier_4
        ,tg.prior_year_outcome
  FROM teacher_crosswalk sr
  JOIN gabby.pm.teacher_goals tg
    ON sr.primary_site = tg.df_primary_site
   AND sr.grades_taught = tg.grade
   AND tg.goal_type IN ('Team', 'Individual')
  WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher', 'Learning Specialist')

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
        ,tg.grade
        ,tg.is_sped_goal
        ,tg.ps_course_number
        ,tg.metric_label
        ,tg.metric_name      
        ,tg.tier_1
        ,tg.tier_2
        ,tg.tier_3
        ,tg.tier_4
        ,tg.prior_year_outcome
  FROM teacher_crosswalk sr
  JOIN gabby.pm.teacher_goals tg
    ON sr.primary_site = tg.df_primary_site
   AND tg.goal_type = 'Class'
   AND tg.is_sped_goal = 0
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
        ,tg.grade
        ,tg.is_sped_goal
        ,tg.ps_course_number
        ,tg.metric_label
        ,tg.metric_name      
        ,tg.tier_1
        ,tg.tier_2
        ,tg.tier_3
        ,tg.tier_4
        ,tg.prior_year_outcome
  FROM teacher_crosswalk sr
  JOIN gabby.pm.teacher_goals tg
    ON sr.primary_site = tg.df_primary_site
   AND tg.goal_type = 'Class'
   AND tg.is_sped_goal = 1
  WHERE sr.primary_job IN ('Learning Specialist')
 )

,ps_section_teacher AS (
  SELECT sec.id AS sectionid
        ,sec.section_number
        ,sec.section_type
        ,sec.course_number        
        ,sec.db_name
        
        ,c.course_name

        ,MIN(st.start_date) AS start_date_min
        ,MAX(st.end_date) AS end_date_max

        ,t.teachernumber
  FROM gabby.powerschool.sections sec
  JOIN gabby.powerschool.courses c
    ON sec.course_number_clean = c.course_number_clean
  JOIN gabby.powerschool.sectionteacher st
    ON sec.id = st.sectionid
   AND sec.db_name = st.db_name
  JOIN gabby.powerschool.teachers_static t
    ON st.teacherid = t.id
   AND st.db_name = t.db_name
  GROUP BY sec.id
          ,sec.course_number
          ,sec.section_number
          ,sec.section_type
          ,sec.db_name
          ,c.course_name
          ,t.teachernumber
 )

/* Classroom goals -- JOIN to student data by sections */
SELECT tgs.df_employee_number
      ,tgs.preferred_name
      ,tgs.primary_site
      ,tgs.primary_on_site_department
      ,tgs.grades_taught
      ,tgs.primary_job
      ,tgs.legal_entity_name
      ,tgs.is_active
      ,tgs.primary_site_schoolid
      ,tgs.manager_df_employee_number
      ,tgs.manager_name
      ,tgs.staff_username
      ,tgs.manager_username
      ,tgs.academic_year
      ,tgs.goal_type
      ,tgs.goal_department
      ,tgs.grade
      ,tgs.is_sped_goal
      ,tgs.ps_course_number
      ,tgs.metric_label
      ,tgs.metric_name
      ,tgs.tier_1
      ,tgs.tier_2
      ,tgs.tier_3
      ,tgs.tier_4
      ,tgs.prior_year_outcome
      ,tgs.ps_teachernumber
      
      ,st.sectionid      
      ,st.section_number
      ,st.course_name
      ,st.start_date_min
      ,st.end_date_max
FROM teacher_goal_scaffold tgs
JOIN ps_section_teacher st
  ON tgs.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
 AND tgs.ps_course_number = st.course_number COLLATE Latin1_General_BIN
 AND tgs.db_name = st.db_name
WHERE tgs.goal_type = 'Class'

UNION ALL

/* GLT goals -- JOIN to student data by grade-level */
SELECT tgs.df_employee_number
      ,tgs.preferred_name
      ,tgs.primary_site
      ,tgs.primary_on_site_department
      ,tgs.grades_taught
      ,tgs.primary_job
      ,tgs.legal_entity_name
      ,tgs.is_active
      ,tgs.primary_site_schoolid
      ,tgs.manager_df_employee_number
      ,tgs.manager_name
      ,tgs.staff_username
      ,tgs.manager_username
      ,tgs.academic_year
      ,tgs.goal_type
      ,tgs.goal_department
      ,tgs.grade
      ,tgs.is_sped_goal
      ,tgs.ps_course_number
      ,tgs.metric_label
      ,tgs.metric_name
      ,tgs.tier_1
      ,tgs.tier_2
      ,tgs.tier_3
      ,tgs.tier_4
      ,tgs.prior_year_outcome
      ,tgs.ps_teachernumber
      
      ,NULL AS sectionid
      ,NULL AS section_number
      ,NULL AS course_name
      ,NULL AS start_date_min
      ,NULL AS end_date_max
FROM teacher_goal_scaffold tgs
WHERE tgs.goal_type = 'Team'

UNION ALL

/* Individual goals -- JOIN to S&O/ETR data by teacher */
SELECT tgs.df_employee_number
      ,tgs.preferred_name
      ,tgs.primary_site
      ,tgs.primary_on_site_department
      ,tgs.grades_taught
      ,tgs.primary_job
      ,tgs.legal_entity_name
      ,tgs.is_active
      ,tgs.primary_site_schoolid
      ,tgs.manager_df_employee_number
      ,tgs.manager_name
      ,tgs.staff_username
      ,tgs.manager_username
      ,tgs.academic_year
      ,tgs.goal_type
      ,tgs.goal_department
      ,tgs.grade
      ,tgs.is_sped_goal
      ,tgs.ps_course_number
      ,tgs.metric_label
      ,tgs.metric_name
      ,tgs.tier_1
      ,tgs.tier_2
      ,tgs.tier_3
      ,tgs.tier_4
      ,tgs.prior_year_outcome
      ,tgs.ps_teachernumber
      
      ,NULL AS sectionid
      ,NULL AS section_number
      ,NULL AS course_name
      ,NULL AS start_date_min
      ,NULL AS end_date_max
FROM teacher_goal_scaffold tgs
WHERE tgs.goal_type = 'Individual'