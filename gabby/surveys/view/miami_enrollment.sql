CREATE OR ALTER VIEW
  surveys.miami_enrollment AS
WITH
  survey_pivot AS (
    SELECT
      survey_id,
      survey_response_id,
      date_submitted,
      [student_number],
      [region],
      [miami_transport_consent],
      [miami_shirt],
      [miami_plan],
      [miami_phone],
      [miami_not_returning],
      [miami_middle],
      [miami_last],
      [miami_first],
      [miami_email],
      [miami_bus],
      [miami_bus_stop],
      [miami_address]
    FROM
      (
        SELECT
          question_shortname,
          answer,
          survey_id,
          survey_response_id,
          date_submitted
        FROM
          gabby.surveygizmo.survey_detail
        WHERE
          survey_id = 6829997
      ) AS sub PIVOT (
        MAX(answer) FOR question_shortname IN (
          [student_number],
          [region],
          [miami_transport_consent],
          [miami_shirt],
          [miami_plan],
          [miami_phone],
          [miami_not_returning],
          [miami_middle],
          [miami_last],
          [miami_first],
          [miami_email],
          [miami_bus],
          [miami_bus_stop],
          [miami_address]
        )
      ) p
  )
SELECT
  s.region,
  s.miami_plan,
  s.miami_not_returning,
  s.miami_first,
  s.miami_middle,
  s.miami_last,
  s.miami_phone,
  s.miami_email,
  s.miami_address,
  s.miami_bus,
  s.miami_bus_stop,
  s.miami_transport_consent,
  s.miami_shirt,
  s.student_number,
  p.student_number,
  s.survey_id,
  s.survey_response_id,
  s.date_submitted,
  p.first_name AS db_first,
  p.middle_name AS db_middle,
  p.last_name AS db_last,
  p.street AS db_street,
  p.city AS db_city,
  p.zip AS db_zip,
  p.cohort,
  p.grade_level,
  p.school_name,
  p.school_level,
  p.iep_status,
  p.gender,
  p.ethnicity
FROM
  survey_pivot AS s
  /*JOIN to student data for school, cohort, IEP, gender, race, other*/
  LEFT JOIN powerschool.cohort_identifiers_static AS p ON s.student_number = p.student_number
WHERE
  s.region = 'KMS'
  AND p.enroll_status = 0
  AND p.rn_year = 1
  AND p.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
