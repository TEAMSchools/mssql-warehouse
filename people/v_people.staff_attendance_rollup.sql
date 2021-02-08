USE gabby
GO

CREATE OR ALTER VIEW people.staff_attendance_rollup AS

WITH attendance_pivot AS (
  SELECT df_number
        ,gabby.utilities.DATE_TO_SY(attendance_date) AS academic_year
        ,SUM(CASE WHEN approved=1 THEN sick_day ELSE 0 END) + SUM(CASE WHEN approved=1 THEN personal_day ELSE 0 END) + SUM(CASE WHEN approved=1 THEN absent_other ELSE 0 END) AS absenses_approved
        ,SUM(CASE WHEN approved=0 THEN sick_day ELSE 0 END) + SUM(CASE WHEN approved=0 THEN personal_day ELSE 0 END) + SUM(CASE WHEN approved=0 THEN absent_other ELSE 0 END) AS absenses_unapproved
        ,SUM(CASE WHEN approved=1 THEN late_tardy ELSE 0 END) AS late_tardy_approved
        ,SUM(CASE WHEN approved=0 THEN late_tardy ELSE 0 END) AS late_tardy_unapproved
        ,SUM(CASE WHEN approved=1 THEN left_early ELSE 0 END) AS left_early_approved
        ,SUM(CASE WHEN approved=0 THEN left_early ELSE 0 END) AS left_early_unapproved
  FROM people.staff_attendance_clean
  WHERE rn_curr = 1
  GROUP BY df_number, gabby.utilities.DATE_TO_SY(attendance_date)
  )

,years AS (
  SELECT n AS academic_year
  FROM gabby.utilities.row_generator rg
  WHERE rg.n BETWEEN 2020 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR() /* 2018 = first year of Teacher Goals */
  )

SELECT r.df_employee_number
      ,r.adp_associate_id
      ,r.first_name
      ,r.last_name
      ,r.gender
      ,r.primary_ethnicity
      ,r.original_hire_date
      ,r.status
      ,r.legal_entity_name
      ,r.primary_site
      ,r.primary_on_site_department
      ,r.primary_job
      ,y.academic_year
      ,COALESCE(a.absenses_approved,0) AS absenses_approved
      ,COALESCE(a.absenses_unapproved,0) AS absenses_unapproved
      ,COALESCE(a.late_tardy_approved,0) AS late_tardy_approved
      ,COALESCE(a.late_tardy_unapproved,0) AS late_tardy_unapproved
      ,COALESCE(a.left_early_approved,0) AS left_early_approved
      ,COALESCE(a.left_early_unapproved,0) AS left_early_unapproved
FROM gabby.people.staff_crosswalk_static r
LEFT JOIN years y
  ON gabby.utilities.DATE_TO_SY(original_hire_date) < y.academic_year
LEFT JOIN attendance_pivot a
  ON r.df_employee_number = a.df_number
 AND y.academic_year = a.academic_year