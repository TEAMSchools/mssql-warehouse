USE gabby
GO

CREATE OR ALTER VIEW surveys.so_assignments_long AS

WITH surveys_unpivoted AS (
  SELECT u.employee_number AS survey_taker_id
        ,u.survey_taker AS survey_round_status
        ,u.assignment
        ,CASE 
          WHEN CHARINDEX('[', u.assignment) = 0 THEN NULL
          ELSE SUBSTRING(u.assignment, CHARINDEX('[', u.assignment) + 1, 6)
         END AS assignment_employee_id
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
      ,u.assignment_employee_id

      ,COALESCE(r.preferred_name, u.assignment) AS assignment_preferred_name
      ,r.primary_site AS assignment_location
      ,r.[status] AS assignment_adp_status
      ,'Self & Others - Peer Feedback' AS assignment_type
FROM surveys_unpivoted u
LEFT JOIN gabby.people.staff_crosswalk_static r
  ON u.assignment_employee_id = r.df_employee_number

UNION ALL

SELECT c.manager_df_employee_number  AS survey_taker_id
      ,'Yes' AS survey_round_status
      ,CONCAT(c.preferred_name,' - ',c.primary_site, ' [', c.df_employee_number, '] ') AS assignment
      ,c.df_employee_number AS assignment_employee_id
      ,c.preferred_name AS assignment_preferred_name
      ,c.primary_site AS assignment_location
      ,c.[status] AS assignment_adp_status
      ,'Self & Others - Manager Feedback' AS assignment_type
FROM gabby.people.staff_crosswalk_static c
JOIN gabby.surveys.so_assignments s
  ON c.df_employee_number = s.employee_number
 AND s.survey_taker = 'Yes'
JOIN gabby.surveys.so_assignments m
  ON c.manager_df_employee_number = m.employee_number
 AND m.survey_taker = 'Yes'
WHERE c.[status] <> 'TERMINATED'
  AND COALESCE(c.rehire_date, c.original_hire_date) < DATEADD(DAY, -30, GETDATE())