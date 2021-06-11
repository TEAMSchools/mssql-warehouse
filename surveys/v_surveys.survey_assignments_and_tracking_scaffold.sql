USE gabby
GO

--CREATE OR ALTER VIEW surveys.survey_assignments_and_tracking_scaffold AS

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
  LEFT JOIN gabby.surveygizmo.survey s
    ON c.survey_id = s.id
  WHERE c.link_type = 'email'
  )

,surveys_unpivoted AS ( --replace this shit with surveys.so_assignments_long once it's pulled into gabby
  SELECT u.employee_number AS survey_taker_id
        ,u.survey_taker AS survey_round_status
        ,u.assignment
        ,CASE WHEN CHARINDEX('[',u.assignment) = 0 THEN NULL
              ELSE SUBSTRING(u.assignment,CHARINDEX('[',u.assignment) + 1,6)
         END AS assingment_employee_id
  FROM gabby.surveys.so_assignments
  UNPIVOT(
    assignment
    FOR number IN (so_assignment_1
                  ,so_assignment_2
                  ,so_assignment_3
                  ,so_assignment_4
                  ,so_assignment_5
                  ,so_assignment_6
                  ,so_assignment_7
                  ,so_assignment_8
                  ,so_assignment_9
                  ,so_assignment_10)
   ) u
 )

,so_survey_on_pr AS (
  SELECT u.survey_taker_id
        ,u.survey_round_status
        ,u.assignment
        ,u.assingment_employee_id
        ,COALESCE(r.preferred_name,assignment) AS assignment_preferred_name
        ,r.location AS assignment_location
        ,r.position_status AS assignment_adp_status
        ,'Self & Others - Peer Feedback' AS assignment_type
  FROM surveys_unpivoted u
  LEFT JOIN gabby.people.staff_roster r
    ON u.assingment_employee_id = r.employee_number

  UNION ALL

  SELECT manager_employee_number  AS survey_taker_id
        ,'Yes' AS survey_round_status
        ,preferred_name + '[' + CONVERT(varchar(6),employee_number) + ']' AS assignment
        ,employee_number AS assignment_employee_id
        ,preferred_name AS assignment_preferred_name
        ,location AS assignment_location
        ,position_status AS assignment_adp_status
        ,'Self & Others - Manager Feedback' AS assignment_type
  FROM gabby.people.staff_roster
  WHERE position_status != 'Terminated'
    AND COALESCE(rehire_date,original_hire_date) < DATEADD(DAY,-30,GETDATE())
  )


SELECT r.employee_number AS survey_taker_id
      ,r.preferred_name AS survey_taker_name
      ,r.location AS survey_taker_location
      ,r.position_status AS survey_taker_adp_status

      ,s.survey_round_status
      ,s.assignment
      ,s.assingment_employee_id
      ,s.assignment_preferred_name
      ,s.assignment_location
      ,s.assignment_adp_status
      ,s.assignment_type

      ,st.academic_year
      ,st.reporting_term_code AS reporting_term
      ,st.survey_round_open_minus_fifteen
      ,st.survey_round_open
      ,st.survey_round_close
      ,st.survey_default_link

      ,c.subject_name AS completed_survey_subject_name
      ,c.date_submitted AS survey_completion_date
      ,c.is_manager

FROM so_survey_on_pr s
JOIN gabby.people.staff_roster r
  ON s.survey_taker_id = r.employee_number
 AND r.position_status != 'Terminated'
JOIN survey_terms st
  ON st.current_survey_term = 1
 AND st.survey_id = 4561325 --S&O Survey Code
LEFT JOIN gabby.surveys.survey_completion c
  ON CONVERT(nvarchar,assingment_employee_id) = SUBSTRING(c.subject_name,CHARINDEX('[',c.subject_name) + 1,6)
 AND s.survey_taker_id = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'Self & Others'

UNION ALL

SELECT r.employee_number AS survey_taker_id
      ,r.preferred_name AS survey_taker_name
      ,r.location AS survey_taker_location
      ,r.position_status AS survey_taker_adp_status

      ,'Yes' AS survey_round_status
      ,'Your Manager' AS assignment
      ,NULL AS assingment_employee_id
      ,NULL AS assignment_preferred_name
      ,NULL AS assignment_location
      ,NULL AS assignment_adp_status
      ,'Manager Survey' AS assignment_type

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
 AND st.survey_id = 4561288 --MGR Survey Code
LEFT JOIN gabby.surveys.survey_completion c
  ON r.employee_number = c.df_employee_number
 AND st.academic_year = c.academic_year
 AND st.reporting_term_code = c.reporting_term
 AND survey_type = 'Manager'
WHERE r.position_status != 'Terminated'

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


--One thing that's kind of missing - how do we address surveys that folks complete that aren't necessarily assigned (eg: i give s&o feedback to someone who I'm not assigned to)