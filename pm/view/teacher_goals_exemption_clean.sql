CREATE OR ALTER VIEW
  pm.teacher_goals_exemption_clean AS
SELECT
  df_employee_number,
  academic_year,
  UPPER(REPLACE(field, '_', '')) AS pm_term,
  [value] AS exemption
FROM
  (
    SELECT
      CAST(
        SUBSTRING(
          name_school_id_,
          (
            CHARINDEX('[', name_school_id_) + 1
          ),
          6
        ) AS INT
      ) AS df_employee_number,
      academic_year,
      pm_1,
      pm_2,
      pm_3,
      pm_4
    FROM
      gabby.pm.teacher_goals_exemption
  ) AS sub UNPIVOT (
    [value] FOR field IN (pm_1, pm_2, pm_3, pm_4)
  ) AS u
