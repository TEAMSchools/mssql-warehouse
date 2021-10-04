USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_tracking AS

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
        ,r.legal_entity_name AS survey_taker_legal_entity_name
        ,r.primary_on_site_department AS survey_taker_department
        ,r.primary_job AS survey_taker_primary_job
        ,r.primary_site AS [location]
        ,r.[status] AS position_status
        ,LOWER(r.samaccountname) AS survey_taker_samaccount
        ,r.manager_df_employee_number
        ,r.manager_name
        ,m.legal_entity_name AS manager_legal_entity_name
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
  LEFT JOIN gabby.people.staff_crosswalk_static m
    ON r.manager_df_employee_number = m.df_employee_number
  WHERE sub.rn = 1
 )

,clean_responses AS (
  SELECT c.survey_id
        ,c.academic_year
        ,CASE
          WHEN c.survey_id = 4561325 THEN 'Self & Others'
          WHEN c.survey_id = 4561288 THEN 'Manager'
          WHEN c.survey_id = 5300913 THEN 'R9/Engagement' 
          WHEN c.survey_id = 6330385 THEN 'Staff Update'
         END AS survey_type
        ,SUBSTRING(c.[name], CHARINDEX(' ', c.[name])+1, LEN(c.[name])) AS reporting_term

        ,i.date_submitted
        ,i.respondent_df_employee_number AS df_employee_number
        ,i.respondent_preferred_name AS survey_taker_name
        ,i.respondent_primary_site AS location_custom
        ,i.is_manager
        ,i.subject_preferred_name AS subject_name
        ,i.subject_df_employee_number AS subject_employee_id

        ,sc.[status] AS position_status
        ,sc.primary_on_site_department AS survey_taker_department
        ,sc.primary_job AS survey_taker_primary_job
        ,LOWER(sc.samaccountname) AS survey_taker_samaccount
  FROM gabby.surveygizmo.survey_campaign_clean_static c
  JOIN gabby.surveygizmo.survey_response_identifiers_static i
    ON c.survey_id = i.survey_id
   AND i.date_started BETWEEN c.link_open_date AND c.link_close_date
   AND i.rn_respondent_subject = 1
  JOIN gabby.people.staff_crosswalk_static sc
    ON i.respondent_df_employee_number = sc.df_employee_number
  WHERE c.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND c.survey_id IN (4561325, 4561288, 5300913, 6330385)
 )

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.survey_taker_department, c.survey_taker_department) AS survey_taker_department
      ,COALESCE(st.survey_taker_primary_job, c.survey_taker_primary_job) AS survey_taker_primary_job
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status
      ,COALESCE(st.survey_taker_samaccount,c.survey_taker_samaccount) AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

      ,s.survey_round_status
      ,COALESCE(s.assignment,c.subject_name) AS assignment
      ,COALESCE(
          s.assignment_employee_id
         ,CASE 
           WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
           ELSE SUBSTRING(c.subject_name, CHARINDEX('[', c.subject_name) + 1, 6)
          END
        ) AS assignment_employee_id
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

FROM survey_term_staff_scaffold st
JOIN gabby.surveys.so_assignments_long s
  ON st.employee_number = s.survey_taker_id
 AND s.survey_round_status = 'Yes'
LEFT JOIN clean_responses c
  ON s.assignment_employee_id = c.subject_employee_id
 AND s.survey_taker_id = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND st.survey_id = c.survey_id
WHERE st.survey_id = 4561325 /* S&O Survey Code */

UNION ALL

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.survey_taker_department, c.survey_taker_department) AS survey_taker_department
      ,COALESCE(st.survey_taker_primary_job, c.survey_taker_primary_job) AS survey_taker_primary_job
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status
      ,COALESCE(st.survey_taker_samaccount,c.survey_taker_samaccount) AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

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
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND st.survey_id = c.survey_id
LEFT JOIN gabby.surveys.so_assignments_long s
  ON c.subject_employee_id = s.assignment_employee_id
 AND c.df_employee_number = s.survey_taker_id
WHERE c.survey_id = 4561325 /* S&O Survey Code */
  AND s.assignment IS NULL

UNION ALL

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.survey_taker_department, c.survey_taker_department) AS survey_taker_department
      ,COALESCE(st.survey_taker_primary_job, c.survey_taker_primary_job) AS survey_taker_primary_job
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status
      ,COALESCE(st.survey_taker_samaccount,c.survey_taker_samaccount) AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

      ,s.survey_taker AS survey_round_status
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
LEFT JOIN clean_responses c
  ON st.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND st.survey_id = c.survey_id
JOIN gabby.surveys.so_assignments s
  ON st.employee_number = s.employee_number
 AND s.survey_taker IN ('Yes', 'Yes - Should take manager survey only')
WHERE st.survey_id = 4561288 /* MGR Survey Code */

UNION

SELECT COALESCE(st.employee_number, c.df_employee_number) AS survey_taker_id
      ,COALESCE(st.preferred_name, c.survey_taker_name) AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,COALESCE(st.[location], c.location_custom) AS survey_taker_location
      ,COALESCE(st.survey_taker_department, c.survey_taker_department) AS survey_taker_department
      ,COALESCE(st.survey_taker_primary_job, c.survey_taker_primary_job) AS survey_taker_primary_job
      ,COALESCE(st.position_status, c.position_status) AS survey_taker_adp_status
      ,COALESCE(st.survey_taker_samaccount,c.survey_taker_samaccount) AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

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
  ON c.df_employee_number = st.employee_number
 AND c.academic_year = st.academic_year
 AND c.reporting_term = st.reporting_term_code
 AND c.survey_id = st.survey_id
WHERE st.survey_id = 4561288 /* MGR Survey Code */

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,st.[location] AS survey_taker_location
      ,st.survey_taker_department
      ,st.survey_taker_primary_job
      ,st.position_status AS survey_taker_adp_status
      ,st.survey_taker_samaccount AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

      ,'Yes' AS survey_round_status
      ,sa.engagement_survey_assignment AS assignment
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
 AND st.survey_id = c.survey_id
LEFT JOIN gabby.surveys.so_assignments sa
  ON st.employee_number = sa.employee_number
WHERE st.survey_id = 5300913 /* R9S Survey Code */

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,st.[location] AS survey_taker_location
      ,st.survey_taker_department
      ,st.survey_taker_primary_job
      ,st.position_status AS survey_taker_adp_status
      ,st.survey_taker_samaccount AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

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
 AND st.survey_id = c.survey_id
WHERE st.survey_id = 6330385 /* UP Survey Code */

UNION ALL

SELECT st.employee_number AS survey_taker_id
      ,st.preferred_name AS survey_taker_name
      ,st.survey_taker_legal_entity_name
      ,st.[location] AS survey_taker_location
      ,st.survey_taker_department
      ,st.survey_taker_primary_job
      ,st.[position_status] AS survey_taker_adp_status
      ,st.survey_taker_samaccount AS survey_taker_samaccount
      ,st.manager_df_employee_number
      ,st.manager_name
      ,st.manager_legal_entity_name

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
 AND st.survey_id = c.survey_id
WHERE st.survey_id = 6330385 /* UP Survey Code */
