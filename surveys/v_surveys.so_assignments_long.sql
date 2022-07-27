USE gabby
GO

CREATE OR ALTER VIEW surveys.so_assignments_long AS

/*Matches data types for unpivot*/
WITH assignments_reformat AS (
  SELECT df_employee_number 
        ,survey_round_status
        ,manager_df_employee_number
        ,CAST([so_1] AS bigint) AS so_1
        ,CAST([so_2] AS bigint) AS so_2
        ,CAST([so_3] AS bigint) AS so_3
        ,CAST([so_4] AS bigint) AS so_4
        ,CAST([so_5] AS bigint) AS so_5
        ,CAST([so_6] AS bigint) AS so_6
        ,CAST([so_7] AS bigint) AS so_7
        ,CAST([so_8] AS bigint) AS so_8
        ,CAST([so_9] AS bigint) AS so_9
        ,CAST([so_10] AS bigint) AS so_10          
  FROM gabby.pm.assignments
)

,assignment_unpivot AS (
  SELECT df_employee_number 
        ,survey_round_status
        ,manager_df_employee_number
        ,u.assignment 
  FROM assignments_reformat
  UNPIVOT(
    assignment
    FOR number IN ([so_1]
                  ,[so_2]
                  ,[so_3]
                  ,[so_4]
                  ,[so_5]
                  ,[so_6]
                  ,[so_7]
                  ,[so_8]
                  ,[so_9]
                  ,[so_10]
                  )                  
    ) u 
)

SELECT a.df_employee_number AS survey_taker_id
      ,a.survey_round_status
      ,CONCAT(c.preferred_name,' - ',c.primary_site,' [',c.df_employee_number,'] ') AS assignment
      ,a.assignment AS assignment_employee_id
      
      ,c.preferred_name AS assignment_preferred_name
      ,c.primary_site AS assignment_location
      ,c.[status] AS assignment_adp_status
      ,'Self & Others - Peer Feedback' AS assignment_type
FROM assignment_unpivot a
JOIN gabby.people.staff_crosswalk_static c
  ON a.assignment = c.df_employee_number
WHERE assignment <> 0

UNION ALL

SELECT c.manager_df_employee_number AS survey_taker_id
      ,m.survey_round_status
      ,CONCAT(c.preferred_name,' - ',c.primary_site,' [',c.df_employee_number,'] ') AS assignment
      ,c.df_employee_number AS assignment_employee_id
      ,c.preferred_name AS assignment_preferred_name
      ,c.primary_site AS assignment_location
      ,c.[status] AS assignment_adp_status
      ,'Self & Others - Manager Feedback' AS assignment_type

FROM gabby.people.staff_crosswalk_static c
JOIN gabby.pm.assignments s
  ON CAST(c.df_employee_number AS bigint) = CAST(s.df_employee_number AS bigint)
JOIN gabby.pm.assignments m
  ON c.manager_df_employee_number = m.df_employee_number
WHERE c.[status] <> 'TERMINATED'
  AND COALESCE(c.rehire_date, c.original_hire_date) < DATEADD(DAY, -30, GETDATE())