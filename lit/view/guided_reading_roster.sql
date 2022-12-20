CREATE OR ALTER VIEW
  lit.guided_reading_roster AS
SELECT
  CAST(
    SUBSTRING(
      student_name,
      (
        CHARINDEX('[', student_name) + 1
      ),
      (
        CHARINDEX(']', student_name)
      ) - (
        CHARINDEX('[', student_name) + 1
      )
    ) AS INT
  ) AS student_number,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
  CAST(
    CONCAT(
      'LIT',
      SUBSTRING(
        field,
        PATINDEX('%[0-9]%', field),
        1
      )
    ) AS VARCHAR(5)
  ) AS reporting_term_name,
  CAST(
    CONCAT(
      'Q',
      SUBSTRING(
        field,
        PATINDEX('%[0-9]%', field),
        1
      )
    ) AS VARCHAR(5)
  ) AS test_round,
  CAST(
    SUBSTRING(
      field,
      PATINDEX('%[0-9]%', field),
      1
    ) AS INT
  ) AS round_num,
  CAST(
    gr_teacher AS VARCHAR(125)
  ) AS gr_teacher
FROM
  gabby.lit.guided_reading_groups UNPIVOT (
    gr_teacher FOR field IN (
      round_1_gr_teacher,
      round_2_gr_teacher,
      round_3_gr_teacher,
      round_4_gr_teacher
    )
  ) AS u
WHERE
  _fivetran_deleted IS NULL
