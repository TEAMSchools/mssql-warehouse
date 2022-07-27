USE gabby
GO


CREATE OR ALTER VIEW extracts.gsheets_battleboard

WITH elementary_grade AS (
  SELECT employee_number
        ,MAX(student_grade_level) AS student_grade_level
  FROM gabby.pm.teacher_grade_levels
  GROUP BY employee_number
 )

,prior_year_etr_pivot AS (
	 SELECT df_employee_number
	       ,academic_year
	       ,[PM4]
	 FROM
	     (
	      SELECT df_employee_number
	            ,academic_year
	            ,pm_term
	            ,metric_value
	       FROM gabby.pm.teacher_goals_lockbox_wide
	       WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
	     ) sub
	  PIVOT (
	    MAX(metric_value)
	    FOR pm_term IN ([PM4])
	   ) p
	 )
	 
,etr_pivot AS (
	 SELECT df_employee_number
	       ,academic_year
	       ,[PM1]
	       ,[PM2]
	       ,[PM3]
	       ,[PM4]
	 FROM
	     (
	      SELECT df_employee_number
	            ,academic_year
	            ,pm_term
	            ,metric_value
	       FROM gabby.pm.teacher_goals_lockbox_wide
	       WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	     ) sub
	  PIVOT (
	    MAX(metric_value)
	    FOR pm_term IN ([PM1],[PM2],[PM3],[PM4])
	   ) p
	 )

SELECT c.df_employee_number
      ,c.preferred_name
      ,c.primary_site
      ,c.primary_job
      ,c.primary_on_site_department
      ,c.mail
      ,c.google_email
      ,c.status
      ,c.original_hire_date
      ,CASE
       WHEN c.primary_on_site_department = 'Elementary' AND g.student_grade_level IS NOT NULL
       THEN CONCAT(c.primary_on_site_department, ', Grade ', g.student_grade_level)
       ELSE c.primary_on_site_department
       END AS department_grade 

      ,ROUND(p.PM4,2) AS 'Last Year Final PM'
      ,ROUND(e.PM1,2) AS 'PM1'
      ,ROUND(e.PM2,2) AS 'PM2'
      ,ROUND(e.PM3,2) AS 'PM3'
     
      
      ,i.answer AS itr_response
      
     /*AppSheet entry fields*/

      ,'' AS seat_status
      ,'' AS next_year_teammate
      ,'' AS recruiter_sl_notes
      ,'' AS moy_gut_check
      ,'' AS eoy_gut_check

FROM people.staff_crosswalk_static c
LEFT JOIN etr_pivot e
  ON c.df_employee_number = e.df_employee_number
LEFT JOIN prior_year_etr_pivot p
  ON c.df_employee_number = p.df_employee_number
LEFT JOIN elementary_grade g 
  ON c.df_employee_number = g.employee_number
LEFT JOIN gabby.surveys.intent_to_return_survey_detail i
  ON c.df_employee_number = i.respondent_df_employee_number
  AND i.question_shortname = 'intent_to_return'
  AND i.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
WHERE c.[status] IN ('Active','Leave','Prestart')