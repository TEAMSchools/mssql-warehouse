CREATE OR ALTER VIEW
  pm.teacher_goal_scaffold AS
WITH
  ps_section_teacher AS (
    SELECT
      sec.id AS sectionid,
      sec.section_number,
      sec.section_type,
      sec.course_number,
      LEFT(sec.termid, 2) + 1990 AS academic_year,
      sec.[db_name],
      t.teachernumber
    FROM
      gabby.powerschool.sections AS sec
      INNER JOIN gabby.powerschool.sectionteacher AS st ON sec.id = st.sectionid
      AND sec.[db_name] = st.[db_name]
      INNER JOIN gabby.powerschool.roledef AS rd ON st.roleid = rd.id
      AND st.[db_name] = rd.[db_name]
      AND rd.[name] IN ('Lead Teacher', 'Co-teacher')
      INNER JOIN gabby.powerschool.teachers_static AS t ON st.teacherid = t.id
      AND st.[db_name] = t.[db_name]
    WHERE
      (
        sec.section_type != 'SC'
        OR sec.section_type IS NULL
      )
  )
  /* Individual Goals */
SELECT
  sr.df_employee_number,
  sr.ps_teachernumber,
  sr.preferred_name,
  sr.primary_site,
  sr.primary_on_site_department,
  sr.grades_taught,
  sr.primary_job,
  sr.legal_entity_name,
  sr.is_active,
  sr.primary_site_schoolid,
  sr.manager_df_employee_number,
  sr.manager_name,
  sr.staff_username,
  sr.manager_username,
  sr.[db_name],
  tg.academic_year,
  tg.goal_type,
  tg.df_primary_on_site_department AS goal_department,
  tg.grade_level,
  tg.is_sped_goal,
  tg.ps_course_number,
  tg.metric_label,
  CAST(tg.metric_name AS VARCHAR(125)) AS metric_name,
  CAST(tg.tier_1 AS FLOAT) AS tier_1,
  CAST(tg.tier_2 AS FLOAT) AS tier_2,
  CAST(tg.tier_3 AS FLOAT) AS tier_3,
  CAST(tg.tier_4 AS FLOAT) AS tier_4,
  CAST(tg.prior_year_outcome AS FLOAT) AS prior_year_outcome,
  tg.data_type,
  NULL AS sectionid,
  NULL AS student_number,
  NULL AS dateenrolled,
  NULL AS dateleft,
  NULL AS student_grade_level,
  tm.metric_term,
  tm.pm_term
FROM
  gabby.pm.teacher_goals_roster_static AS sr
  INNER JOIN gabby.pm.teacher_goals AS tg ON sr.primary_site = tg.df_primary_site
  AND sr.academic_year = tg.academic_year
  AND tg.goal_type = 'Individual'
  AND tg._fivetran_deleted = 0
  INNER JOIN gabby.pm.teacher_goals_term_map AS tm ON tg.academic_year = tm.academic_year
  AND tg.metric_name = tm.metric_name
  AND tm._fivetran_deleted = 0
  LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static AS ex ON sr.df_employee_number = ex.df_employee_number
  AND tg.academic_year = ex.academic_year
  AND tm.pm_term = ex.pm_term
WHERE
  ex.exemption IS NULL
UNION ALL
/* Team Goals */
SELECT
  sr.df_employee_number,
  sr.ps_teachernumber,
  sr.preferred_name,
  sr.primary_site,
  sr.primary_on_site_department,
  sr.grades_taught,
  sr.primary_job,
  sr.legal_entity_name,
  sr.is_active,
  sr.primary_site_schoolid,
  sr.manager_df_employee_number,
  sr.manager_name,
  sr.staff_username,
  sr.manager_username,
  sr.[db_name],
  tg.academic_year,
  tg.goal_type,
  tg.df_primary_on_site_department AS goal_department,
  tg.grade_level,
  tg.is_sped_goal,
  tg.ps_course_number,
  tg.metric_label,
  CAST(tg.metric_name AS VARCHAR(125)) AS metric_name,
  CAST(tg.tier_1 AS FLOAT) AS tier_1,
  CAST(tg.tier_2 AS FLOAT) AS tier_2,
  CAST(tg.tier_3 AS FLOAT) AS tier_3,
  CAST(tg.tier_4 AS FLOAT) AS tier_4,
  CAST(tg.prior_year_outcome AS FLOAT) AS prior_year_outcome,
  tg.data_type,
  NULL AS sectionid,
  NULL AS student_number,
  NULL AS dateenrolled,
  NULL AS dateleft,
  NULL AS student_grade_level,
  tm.metric_term,
  tm.pm_term
FROM
  gabby.pm.teacher_goals_roster_static AS sr
  INNER JOIN gabby.pm.teacher_goals AS tg ON sr.primary_site = tg.df_primary_site
  AND sr.grades_taught = tg.grade_level
  AND sr.academic_year = tg.academic_year
  AND tg.goal_type = 'Team'
  AND tg._fivetran_deleted = 0
  INNER JOIN gabby.pm.teacher_goals_term_map AS tm ON tg.academic_year = tm.academic_year
  AND tg.metric_name = tm.metric_name
  AND tm._fivetran_deleted = 0
  LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static AS ex ON sr.df_employee_number = ex.df_employee_number
  AND tg.academic_year = ex.academic_year
  AND tm.pm_term = ex.pm_term
WHERE
  ex.exemption IS NULL
UNION ALL
/* Class Goals - Non-SpEd */
SELECT
  sr.df_employee_number,
  sr.ps_teachernumber,
  sr.preferred_name,
  sr.primary_site,
  sr.primary_on_site_department,
  sr.grades_taught,
  sr.primary_job,
  sr.legal_entity_name,
  sr.is_active,
  sr.primary_site_schoolid,
  sr.manager_df_employee_number,
  sr.manager_name,
  sr.staff_username,
  sr.manager_username,
  sr.[db_name],
  tg.academic_year,
  tg.goal_type,
  tg.df_primary_on_site_department AS goal_department,
  tg.grade_level,
  tg.is_sped_goal,
  tg.ps_course_number,
  tg.metric_label,
  CAST(tg.metric_name AS VARCHAR(125)) AS metric_name,
  CAST(tg.tier_1 AS FLOAT) AS tier_1,
  CAST(tg.tier_2 AS FLOAT) AS tier_2,
  CAST(tg.tier_3 AS FLOAT) AS tier_3,
  CAST(tg.tier_4 AS FLOAT) AS tier_4,
  CAST(tg.prior_year_outcome AS FLOAT) AS prior_year_outcome,
  tg.data_type,
  st.sectionid,
  enr.student_number,
  enr.dateenrolled,
  enr.dateleft,
  co.grade_level AS student_grade_level,
  tm.metric_term,
  tm.pm_term
FROM
  gabby.pm.teacher_goals_roster_static AS sr
  INNER JOIN gabby.pm.teacher_goals AS tg ON sr.primary_site = tg.df_primary_site
  AND sr.academic_year = tg.academic_year
  AND tg.goal_type = 'Class'
  AND tg.is_sped_goal = 0
  AND tg._fivetran_deleted = 0
  INNER JOIN ps_section_teacher AS st ON sr.ps_teachernumber = st.teachernumber
COLLATE Latin1_General_BIN
AND sr.academic_year = st.academic_year
AND sr.[db_name] = st.[db_name]
AND tg.ps_course_number = st.course_number
COLLATE Latin1_General_BIN
INNER JOIN gabby.powerschool.course_enrollments AS enr ON st.sectionid = enr.abs_sectionid
AND st.[db_name] = enr.[db_name]
INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON enr.student_number = co.student_number
AND enr.academic_year = co.academic_year
AND enr.[db_name] = co.[db_name]
AND tg.grade_level = co.grade_level
AND co.rn_year = 1
INNER JOIN gabby.pm.teacher_goals_term_map AS tm ON tg.academic_year = tm.academic_year
AND tg.metric_name = tm.metric_name
AND tm._fivetran_deleted = 0
LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static AS ex ON sr.df_employee_number = ex.df_employee_number
AND tg.academic_year = ex.academic_year
AND tm.pm_term = ex.pm_term
WHERE
  sr.is_sped_teacher = 0
  AND ex.exemption IS NULL
UNION ALL
/* Class Goals - SpEd */
SELECT
  sr.df_employee_number,
  sr.ps_teachernumber,
  sr.preferred_name,
  sr.primary_site,
  sr.primary_on_site_department,
  sr.grades_taught,
  sr.primary_job,
  sr.legal_entity_name,
  sr.is_active,
  sr.primary_site_schoolid,
  sr.manager_df_employee_number,
  sr.manager_name,
  sr.staff_username,
  sr.manager_username,
  sr.[db_name],
  tg.academic_year,
  tg.goal_type,
  tg.df_primary_on_site_department AS goal_department,
  tg.grade_level,
  tg.is_sped_goal,
  tg.ps_course_number,
  tg.metric_label,
  CAST(tg.metric_name AS VARCHAR(125)) AS metric_name,
  CAST(tg.tier_1 AS FLOAT) AS tier_1,
  CAST(tg.tier_2 AS FLOAT) AS tier_2,
  CAST(tg.tier_3 AS FLOAT) AS tier_3,
  CAST(tg.tier_4 AS FLOAT) AS tier_4,
  CAST(tg.prior_year_outcome AS FLOAT) AS prior_year_outcome,
  tg.data_type,
  st.sectionid,
  enr.student_number,
  enr.dateenrolled,
  enr.dateleft,
  co.grade_level AS student_grade_level,
  tm.metric_term,
  tm.pm_term
FROM
  gabby.pm.teacher_goals_roster_static AS sr
  INNER JOIN gabby.pm.teacher_goals AS tg ON sr.primary_site = tg.df_primary_site
  AND sr.academic_year = tg.academic_year
  AND tg.goal_type = 'Class'
  AND tg.is_sped_goal = 1
  AND tg._fivetran_deleted = 0
  INNER JOIN ps_section_teacher AS st ON sr.ps_teachernumber = st.teachernumber
COLLATE Latin1_General_BIN
AND sr.academic_year = st.academic_year
AND sr.[db_name] = st.[db_name]
AND tg.ps_course_number = st.course_number
COLLATE Latin1_General_BIN
INNER JOIN gabby.powerschool.course_enrollments AS enr ON st.sectionid = enr.abs_sectionid
AND st.[db_name] = enr.[db_name]
INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON enr.student_number = co.student_number
AND enr.academic_year = co.academic_year
AND enr.[db_name] = co.[db_name]
AND tg.grade_level = co.grade_level
AND co.rn_year = 1
AND co.iep_status = 'SPED'
INNER JOIN gabby.pm.teacher_goals_term_map AS tm ON tg.academic_year = tm.academic_year
AND tg.metric_name = tm.metric_name
AND tm._fivetran_deleted = 0
LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static AS ex ON sr.df_employee_number = ex.df_employee_number
AND tg.academic_year = ex.academic_year
AND tm.pm_term = ex.pm_term
WHERE
  sr.is_sped_teacher = 1
  AND ex.exemption IS NULL
