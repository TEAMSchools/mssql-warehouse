USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_assignments_and_tracking_scaffold AS

WITH survey_terms AS (
  SELECT c.survey_id
        ,c.[name] AS survey_round_code
        ,c.academic_year
        ,c.reporting_term_code
        ,c.link_open_date AS survey_round_open
        ,c.link_close_date AS survey_round_close
        ,DATEADD(DAY,-15, c.link_open_date) AS survey_round_open_minus_fifteen
        ,JSON_VALUE(links, '$.default') AS survey_default_link
        ,CASE 
          WHEN MAX(c.link_open_date) OVER( PARTITION BY c.survey_id) = c.link_open_date THEN 1
          ELSE NULL
         END AS current_survey_term
  FROM gabby.surveygizmo.survey_campaign_clean_static c
  JOIN gabby.surveygizmo.survey s
    ON c.survey_id = s.id
  WHERE c.link_type = 'email'
  )

SELECT COALESCE(r.employee_number,c.df_employee_number) AS survey_taker_id
      ,COALESCE(r.preferred_name,c.survey_taker_name) AS survey_taker_name
      ,COALESCE(r.[location],c.location_custom) AS survey_taker_location
      ,COALESCE(r.position_status,c.position_status) AS survey_taker_adp_status

      ,s.survey_round_status
      ,COALESCE(s.assignment,c.subject_name) AS assignment
      ,COALESCE(s.assingment_employee_id, 
                CASE 
                 WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
                 ELSE SUBSTRING(c.subject_name, CHARINDEX('[', c.subject_name) + 1, 6)
                END
                ) AS assingment_employee_id
      ,COALESCE(s.assignment_preferred_name,c.subject_name) AS assignment_preferred_name
      ,s.assignment_location
      ,s.assignment_adp_status
      ,s.assignment_type

      ,COALESCE(st.academic_year,c.academic_year) AS academic_year
      ,COALESCE(st.reporting_term_code,c.reporting_term) AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM gabby.surveys.so_assignments_long s
JOIN gabby.people.staff_roster r
  ON s.survey_taker_id = r.employee_number
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 4561325 --S&O Survey Code
FULL JOIN gabby.surveys.survey_completion c  -- full join to pull in completed surveys that had no assignment
  ON CONVERT(nvarchar,assingment_employee_id) = SUBSTRING(c.subject_name,CHARINDEX('[',c.subject_name) + 1,6)
 AND s.survey_taker_id = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
WHERE c.survey_type = 'Self & Others'
  AND c.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT COALESCE(r.employee_number,c.df_employee_number) AS survey_taker_id
      ,COALESCE(r.preferred_name,c.survey_taker_name) AS survey_taker_name
      ,COALESCE(r.[location],c.location_custom) AS survey_taker_location
      ,COALESCE(r.position_status,c.position_status) AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,'Your Manager' AS assignment
      ,NULL AS assingment_employee_id
      ,NULL AS assignment_preferred_name
      ,NULL AS assignment_location
      ,NULL AS assignment_adp_status
      ,'Manager Survey' AS assignment_type

      ,COALESCE(st.academic_year,c.academic_year) AS academic_year
      ,COALESCE(st.reporting_term_code,c.reporting_term) AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM gabby.people.staff_roster r
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 4561288 --MGR Survey Code
FULL JOIN gabby.surveys.survey_completion c -- full join to pull in completed surveys that had no assignment
  ON r.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'Manager'
WHERE r.position_status != 'Terminated'
  AND c.survey_type = 'Manager'
  AND c.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT r.employee_number AS survey_taker_id
      ,r.preferred_name AS survey_taker_name
      ,r.location AS survey_taker_location
      ,r.position_status AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,'Regional & Staff Engagement Survey' AS assignment
      ,NULL AS assingment_employee_id
      ,NULL AS assignment_preferred_name
      ,NULL AS assignment_location
      ,NULL AS assignment_adp_status
      ,'Regional & Staff Engagement Survey' AS assignment_type

      ,st.academic_year
      ,st.reporting_term_code AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM gabby.people.staff_roster r
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 5300913 --R9S Survey Code
LEFT JOIN gabby.surveys.survey_completion c
  ON r.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'R9/Engagement'
WHERE r.position_status != 'Terminated'

UNION ALL

SELECT r.employee_number AS survey_taker_id
      ,r.preferred_name AS survey_taker_name
      ,r.location AS survey_taker_location
      ,r.position_status AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,'Update Your Staff Info' AS assignment
      ,NULL AS assingment_employee_id
      ,NULL AS assignment_preferred_name
      ,NULL AS assignment_location
      ,NULL AS assignment_adp_status
      ,'Staff Update' AS assignment_type

      ,st.academic_year
      ,st.reporting_term_code AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM gabby.people.staff_roster r
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 6330385 --UP Survey Code
LEFT JOIN gabby.surveys.survey_completion c
  ON r.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'Staff Update'
WHERE r.position_status != 'Terminated'

UNION ALL

SELECT r.employee_number AS survey_taker_id
      ,r.preferred_name AS survey_taker_name
      ,r.location AS survey_taker_location
      ,r.position_status AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,'One Off Staff Survey' AS assignment
      ,NULL AS assingment_employee_id
      ,NULL AS assignment_preferred_name
      ,NULL AS assignment_location
      ,NULL AS assignment_adp_status
      ,'One Off Staff Survey' AS assignment_type

      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() academic_year
      ,NULL AS reporting_term
      ,NULL AS survey_round_open_minus_fifteen
      ,NULL AS survey_round_open
      ,NULL AS survey_round_close
      ,NULL AS survey_default_link

      ,'Cannot be tracked' AS completed_survey_subject_name
      ,NULL AS survey_completion_date
      ,0 AS is_manager

FROM gabby.people.staff_roster r
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 6330385 --UP Survey Code
LEFT JOIN gabby.surveys.survey_completion c
  ON r.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'Staff Update'
WHERE r.position_status != 'Terminated'