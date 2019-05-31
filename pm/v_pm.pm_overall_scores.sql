USE gabby
GO

CREATE OR ALTER VIEW pm.pm_overall_scores AS

SELECT p.df_employee_number
      ,p.preferred_name
      ,p.primary_job
      ,p.primary_site
      ,[Excellent Teaching Rubric] AS etr_score
      ,[Self & Others] AS so_score
      ,COALESCE([Excellent Teaching Rubric] * .8 + [Self & Others] * .2,[Self & Others],[Excellent Teaching Rubric]) AS overall_score
      ,CASE WHEN [Excellent Teaching Rubric] >= 3.5 THEN 4
            WHEN [Excellent Teaching Rubric] >= 2.75 THEN 3
            WHEN [Excellent Teaching Rubric] >= 1.75 THEN 2
            WHEN [Excellent Teaching Rubric] < 1.75 THEN 1
            ELSE NULL
       END AS etr_tier
      ,CASE WHEN [Self & Others] >= 3.5 THEN 4
            WHEN [Self & Others] >= 3.0 THEN 3
            WHEN [Self & Others] >= 2.0 THEN 2
            WHEN [Self & Others] < 2.0 THEN 1
            ELSE NULL
       END AS so_tier
      ,CASE WHEN COALESCE([Excellent Teaching Rubric] * .8 + [Self & Others] * .2,[Self & Others],[Excellent Teaching Rubric]) >= 3.5 THEN 4
            WHEN COALESCE([Excellent Teaching Rubric] * .8 + [Self & Others] * .2,[Self & Others],[Excellent Teaching Rubric]) >= 2.75 THEN 3
            WHEN COALESCE([Excellent Teaching Rubric] * .8 + [Self & Others] * .2,[Self & Others],[Excellent Teaching Rubric]) >= 1.75 THEN 2
            WHEN COALESCE([Excellent Teaching Rubric] * .8 + [Self & Others] * .2,[Self & Others],[Excellent Teaching Rubric]) < 1.75 THEN 1
            ELSE NULL
       END AS overall_tier
      ,pm_term
      ,academic_year
      ,r.hire_date
      ,r.legal_entity_name
FROM (

  SELECT df_employee_number
        ,preferred_name
        ,primary_job
        ,primary_site
        ,metric_label
        ,metric_value_stored
        ,pm_term
        ,academic_year
  FROM tableau.pm_teacher_goals
  WHERE metric_label IN ('Excellent Teaching Rubric', 'Self & Others')
    AND metric_value_stored IS NOT NULL 
    ) sub
PIVOT( MAX(metric_value_stored) FOR metric_label IN ([Excellent Teaching Rubric],[Self & Others])) p
 
LEFT OUTER JOIN tableau.staff_roster r
ON p.df_employee_number = r.df_employee_number