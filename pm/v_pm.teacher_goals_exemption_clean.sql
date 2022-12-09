USE gabby GO
CREATE OR ALTER VIEW
  pm.teacher_goals_exemption_clean AS
SELECT
  u.df_employee_number,
  u.academic_year,
  u.field AS pm_term,
  u.[value] AS exemption
FROM
  (
    SELECT
      CAST(SUBSTRING(name_school_id_, (CHARINDEX('[', name_school_id_) + 1), 6) AS INT) AS df_employee_number,
      academic_year,
      pm_1 AS PM1,
      pm_2 AS PM2,
      pm_3 AS PM3,
      pm_4 AS PM4
    FROM
      gabby.pm.teacher_goals_exemption
    WHERE
      _fivetran_deleted = 0
  ) sub UNPIVOT (VALUE FOR field IN (PM1, PM2, PM3, PM4)) u
