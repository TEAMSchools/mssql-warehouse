USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_assignments_and_tracking_scaffold AS

WITH survey_term_staff_scaffold AS (
  SELECT sub.survey_id
        ,sub.survey_round_code
        ,sub.academic_year
        ,sub.reporting_term_code
        ,sub.survey_round_open
        ,sub.survey_round_close
        ,sub.survey_round_open_minus_fifteen
        ,sub.survey_default_link
        ,sub.title

        ,r.df_employee_number AS employee_number
        ,r.preferred_name
        ,r.primary_site AS [location]
        ,r.[status] AS position_status
  FROM
      (
       SELECT c.survey_id
             ,c.[name] AS survey_round_code
             ,c.academic_year
             ,c.reporting_term_code
             ,c.link_open_date AS survey_round_open
             ,c.link_close_date AS survey_round_close
             ,DATEADD(DAY, -15, c.link_open_date) AS survey_round_open_minus_fifteen
             ,ROW_NUMBER() OVER(PARTITION BY c.survey_id ORDER BY c.link_open_date DESC) AS rn

             ,s.default_link AS survey_default_link
             ,s.[title]
       FROM gabby.surveygizmo.survey_campaign_clean_static c
       JOIN gabby.surveygizmo.survey_clean s
         ON c.survey_id = s.survey_id
       WHERE c.link_type = 'email'
         AND c.survey_id IN (4561325, 4561288, 5300913, 6330385)
      ) sub
  JOIN gabby.people.staff_crosswalk_static r
    ON r.[status] NOT IN ('Terminated', 'Prestart')
  WHERE rn = 1
 )

,clean_responses AS ( --clean up responses to include only most recent
  SELECT sub.academic_year
        ,sub.reporting_term
        ,sub.survey_type
        ,sub.df_employee_number
        ,sub.survey_taker_name
        ,sub.location_custom
        ,sub.position_status
        ,sub.subject_name
        ,sub.subject_employee_id
        ,sub.is_manager
        ,sub.date_submitted
  FROM (
        SELECT c.academic_year
              ,c.reporting_term
              ,c.survey_type
              ,c.df_employee_number
              ,c.survey_taker_name
              ,c.location_custom
              ,c.position_status
              ,c.subject_name
              ,CASE 
                WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
                ELSE CONVERT(int,SUBSTRING(c.subject_name, CHARINDEX('[', c.subject_name) + 1, 6))
               END AS subject_employee_id
              ,c.is_manager
              ,c.date_submitted
              ,ROW_NUMBER() OVER(PARTITION BY  c.survey_type, c.df_employee_number, CASE 
                                                                                     WHEN CHARINDEX('[', c.subject_name) = 0 THEN c.subject_name
                                                                                     ELSE SUBSTRING(c.subject_name, CHARINDEX('[', c.subject_name) + 1, 6)
                                                                                    END 
                                 ORDER BY c.date_submitted DESC) AS rn
        FROM gabby.surveys.survey_completion c
        WHERE c.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
          AND c.subject_name IS NOT NULL
        ) sub
   WHERE rn = 1
  )

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status

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
JOIN survey_term_staff_scaffold st
  ON st.survey_id = 4561325 --S&O Survey Code
 AND s.survey_taker_id = st.employee_number
LEFT JOIN clean_responses c
  ON s.assingment_employee_id = c.subject_employee_id
 AND s.survey_taker_id = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'Self & Others'

 UNION ALL

 SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,c.subject_name AS assignment
      ,CASE 
        WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
        ELSE SUBSTRING(c.subject_name, CHARINDEX('[', c.subject_name) + 1, 6)
       END AS assingment_employee_id
      ,c.subject_name AS assignment_preferred_name
      ,c.location_custom AS assignment_location
      ,NULL AS assignment_adp_status
      ,CASE 
        WHEN c.is_manager = 1 THEN 'Self & Others - Manager Feedback' 
        ELSE 'Self & Others - Peer Feedback' 
       END AS assignment_type

      ,COALESCE(st.academic_year,c.academic_year) AS academic_year
      ,COALESCE(st.reporting_term_code,c.reporting_term) AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM clean_responses c
JOIN survey_term_staff_scaffold st
  ON st.survey_id = 4561325 --S&O Survey Code
 AND st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
LEFT JOIN gabby.surveys.so_assignments_long s
  ON s.assingment_employee_id = c.subject_employee_id
 AND s.survey_taker_id = c.df_employee_number
WHERE c.survey_type = 'Self & Others'
  AND s.assignment IS NULL

UNION ALL

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status

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
FROM survey_term_staff_scaffold st
LEFT JOIN clean_responses c -- full join to pull in completed surveys that had no assignment
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'Manager'
WHERE st.survey_id = 4561288 --MGR Survey Code

UNION

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status

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
FROM clean_responses c
LEFT JOIN survey_term_staff_scaffold st
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'Manager'
WHERE st.survey_id = 4561288 --MGR Survey Code

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.[location] AS survey_taker_location
      ,st.position_status AS survey_taker_adp_status

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
FROM survey_term_staff_scaffold st
LEFT JOIN clean_responses c
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'R9/Engagement'
WHERE st.survey_id = 5300913 --R9S Survey Code

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.[location] AS survey_taker_location
      ,st.position_status AS survey_taker_adp_status

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
FROM survey_term_staff_scaffold st
LEFT JOIN clean_responses c
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'Staff Update'
WHERE st.survey_id = 6330385 --UP Survey Code

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.[location] AS survey_taker_location
      ,st.[position_status] AS survey_taker_adp_status

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
FROM survey_term_staff_scaffold st  
LEFT JOIN clean_responses c
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND c.survey_type = 'Staff Update'
WHERE st.survey_id = 6330385 --UP Survey Code