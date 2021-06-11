USE gabby
GO

CREATE OR ALTER VIEW surveys.so_assignments_long AS

WITH surveys_unpivoted AS (
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

SELECT u.survey_taker_id
      ,u.survey_round_status
      ,u.assignment
      ,u.assingment_employee_id
      ,COALESCE(r.preferred_name,assignment) AS assignment_preferred_name
      ,r.location AS assignment_location
      ,r.position_status AS assignment_adp_status
      ,'Assigned to you' AS assignment_type
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
      ,'ADP Manager' AS assignment_type
FROM gabby.people.staff_roster
WHERE position_status != 'Terminated'
  AND COALESCE(rehire_date,original_hire_date) < DATEADD(DAY,-30,GETDATE())