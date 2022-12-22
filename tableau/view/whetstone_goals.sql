CREATE OR ALTER VIEW
  tableau.whetstone_goals AS
SELECT
  t._id AS tag_id,
  t.[name] AS tag_name,
  wa.assignment_id,
  wa.[name] AS assignment_name,
  wa.[type] AS assignment_type,
  CAST(wa.created AS DATETIME2) AS assignment_date,
  NULL AS assignment_status,
  NULL AS [exclude_from_bank],
  NULL AS [mastered_date],
  wa.[user_id],
  NULL AS user_email,
  wa.[user_name],
  wa.creator_id,
  NULL AS creator_email,
  wa.creator_name,
  scw.primary_site AS user_default_school_name,
  scw.primary_on_site_department AS user_default_course_name,
  scw.grades_taught AS user_default_gradelevel_name,
  scw.primary_job,
  scw.primary_on_site_department,
  rt.academic_year,
  rt.alt_name AS reporting_term_name
FROM
  gabby.whetstone.tags AS t
  LEFT JOIN gabby.whetstone.assignment_tags AS wt ON (
    t._id = wt.tag_id
    AND wt.assignment_type = 'goal'
  )
  LEFT JOIN gabby.whetstone.assignments_clean AS wa ON (
    wt.assignment_id = wa.assignment_id
  )
  LEFT JOIN gabby.whetstone.users_clean AS wu ON (wa.[user_id] = wu.[user_id])
  LEFT JOIN gabby.people.staff_crosswalk_static AS scw ON (
    wu.internal_id = scw.df_employee_number
  )
  INNER JOIN gabby.reporting.reporting_terms AS rt ON (
    (
      CAST(wa.created AS DATE) BETWEEN rt.[start_date] AND rt.end_date
    )
    AND rt.identifier = 'RT'
    AND rt.schoolid = 0
    AND rt._fivetran_deleted = 0
  )
