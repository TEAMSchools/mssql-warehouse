CREATE OR ALTER VIEW
  surveys.so_assignments_long AS
  /*Matches data types for unpivot*/
WITH
  assignments_reformat AS (
    SELECT
      df_employee_number,
      survey_round_status,
      manager_df_employee_number,
      CAST([so_1] AS BIGINT) AS so_1,
      CAST([so_2] AS BIGINT) AS so_2,
      CAST([so_3] AS BIGINT) AS so_3,
      CAST([so_4] AS BIGINT) AS so_4,
      CAST([so_5] AS BIGINT) AS so_5,
      CAST([so_6] AS BIGINT) AS so_6,
      CAST([so_7] AS BIGINT) AS so_7,
      CAST([so_8] AS BIGINT) AS so_8,
      CAST([so_9] AS BIGINT) AS so_9,
      CAST([so_10] AS BIGINT) AS so_10
    FROM
      pm.assignments
  ),
  assignment_unpivot AS (
    SELECT
      df_employee_number,
      survey_round_status,
      manager_df_employee_number,
      assignment
    FROM
      assignments_reformat UNPIVOT (
        assignment FOR number IN (
          [so_1],
          [so_2],
          [so_3],
          [so_4],
          [so_5],
          [so_6],
          [so_7],
          [so_8],
          [so_9],
          [so_10]
        )
      ) AS u
  )
SELECT
  a.df_employee_number AS survey_taker_id,
  a.survey_round_status,
  CONCAT(
    c.preferred_name,
    ' - ',
    c.primary_site,
    ' [',
    c.df_employee_number,
    '] '
  ) AS assignment,
  a.assignment AS assignment_employee_id,
  c.preferred_name AS assignment_preferred_name,
  c.primary_site AS assignment_location,
  c.[status] AS assignment_adp_status,
  'Self & Others - Peer Feedback' AS assignment_type
FROM
  assignment_unpivot AS a
  INNER JOIN people.staff_crosswalk_static AS c ON (
    a.assignment = c.df_employee_number
  )
WHERE
  a.assignment != 0
  AND a.survey_round_status = 'Yes'
  AND c.[status] != 'Terminated'
UNION ALL
SELECT
  c.manager_df_employee_number AS survey_taker_id,
  m.survey_round_status,
  CONCAT(
    c.preferred_name,
    ' - ',
    c.primary_site,
    ' [',
    c.df_employee_number,
    '] '
  ) AS assignment,
  c.df_employee_number AS assignment_employee_id,
  c.preferred_name AS assignment_preferred_name,
  c.primary_site AS assignment_location,
  c.[status] AS assignment_adp_status,
  'Self & Others - Manager Feedback' AS assignment_type
FROM
  people.staff_crosswalk_static AS c
  INNER JOIN pm.assignments AS s ON (
    c.df_employee_number = s.df_employee_number
  )
  INNER JOIN pm.assignments AS m ON (
    c.manager_df_employee_number = m.df_employee_number
  )
WHERE
  c.[status] != 'TERMINATED'
  AND COALESCE(
    c.rehire_date,
    c.original_hire_date
  ) < DATEADD(DAY, -30, CURRENT_TIMESTAMP)
