USE gabby
GO

CREATE OR ALTER VIEW naviance.sat_act_conversion AS

SELECT student_number      
      ,academic_year
      ,test_date         
      ,'Composite' AS act_subject
      ,CASE WHEN total_score < 560 THEN 11 ELSE act_composite_score END AS scale_score /* concordance data does not exist for < 560 */
FROM
    (
     SELECT sat.student_number
           ,gabby.utilities.DATE_TO_SY(sat.test_date) AS academic_year
           ,sat.test_date
      
           ,COALESCE(onc.new_sat_total_score, sat.all_tests_total) AS total_score
     FROM gabby.naviance.sat_scores_clean sat
     LEFT OUTER JOIN gabby.collegeboard.sat_old_new_concordance onc
       ON sat.sat_scale = onc.old_sat_scale
      AND sat.all_tests_total = onc.old_sat_total_score
      AND sat.is_old_sat = 1     
    ) sub
LEFT OUTER JOIN gabby.collegeboard.sat_act_concordance sac
  ON sub.total_score = sac.sat_total_score