USE gabby
GO

ALTER VIEW renaissance.ar_goals AS

WITH roster AS (
  SELECT student_number
        ,academic_year
        ,grade_level
        ,enroll_status
        ,reporting_term
        ,MAX(is_enrolled) AS is_enrolled
  FROM
      (
       SELECT co.student_number        
             ,co.academic_year             
             ,co.grade_level             
             ,co.enroll_status
             ,CASE 
               WHEN co.exitdate <= CONVERT(DATE,dts.start_date) THEN 0
               WHEN co.entrydate <= CONVERT(DATE,dts.end_date) THEN 1 
               ELSE 0 
              END AS is_enrolled
             
             ,dts.time_per_name AS reporting_term                          
       FROM gabby.powerschool.cohort_identifiers_static co
       JOIN gabby.reporting.reporting_terms dts
         ON co.schoolid = dts.schoolid
        AND co.academic_year = dts.academic_year
        AND dts.identifier = 'AR'          
        AND dts.time_per_name != 'ARY'  
       WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       ) sub
  GROUP BY student_number
          ,academic_year
          ,grade_level
          ,enroll_status
          ,reporting_term
 )

,ms_goals AS (
  SELECT sub.student_number
        ,sub.term      
        ,tiers.words_goal
  FROM
      (
       SELECT achv.student_number           
             ,COALESCE(boy.time_per_name, moy.time_per_name) AS term
             ,COALESCE(
                 COALESCE(achv.indep_lvl_num, achv.lvl_num)
                ,LAG(COALESCE(achv.indep_lvl_num, achv.lvl_num), 2) OVER(PARTITION BY achv.student_number, achv.academic_year ORDER BY achv.start_date)
               ) AS indep_lvl_num /* Q1 & Q2 are set by BOY, carry them forward for setting goals at beginning of year */
       FROM gabby.lit.achieved_by_round_static achv
       LEFT OUTER JOIN (
             SELECT 'AR1' AS time_per_name
             UNION
             SELECT 'AR2'             
            ) boy
         ON achv.test_round = 'Q1'
       LEFT OUTER JOIN (
             SELECT 'AR3' AS time_per_name
             UNION
             SELECT 'AR4'             
            ) moy
         ON achv.test_round = 'Q3'
       WHERE achv.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
         AND achv.test_round IN ('Q1','Q3')
      ) sub
  LEFT OUTER JOIN gabby.renaissance.ar_goal_criteria goal
    ON sub.indep_lvl_num BETWEEN goal.min AND goal.max
   AND goal.criteria = 'lvl_num'
  LEFT OUTER JOIN gabby.renaissance.ar_tier_goals tiers
    ON goal.tier = tiers.tier
 )

,indiv_goals AS (
  SELECT student_number
        ,REPLACE(reporting_term, 'q_', 'AR') AS reporting_term
        ,adjusted_goal
  FROM gabby.renaissance.ar_individualized_goals
  UNPIVOT(
    adjusted_goal
    FOR reporting_term IN (q_1, q_2, q_3, q_4)
   ) u
 )

,term_goals AS (
  SELECT student_number
        ,academic_year
        ,reporting_term
        ,words_goal
        ,points_goal
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year, reporting_term
             ORDER BY words_goal DESC, points_goal DESC) AS rn_dupe
  FROM
      (
       SELECT r.student_number
             ,r.academic_year
             ,r.reporting_term             
             ,CASE
               WHEN r.is_enrolled = 0 THEN NULL
               WHEN r.grade_level >= 9 THEN NULL
               WHEN r.enroll_status != 0 THEN -1
               ELSE COALESCE(g.adjusted_goal, ms.words_goal, df.words_goal) 
              END AS words_goal
             ,CASE
               WHEN r.is_enrolled = 0 THEN NULL
               WHEN r.grade_level <= 8 THEN NULL
               WHEN r.enroll_status != 0 THEN -1
               ELSE COALESCE(g.adjusted_goal, df.points_goal)
              END AS points_goal             
       FROM roster r
       LEFT OUTER JOIN ms_goals ms
         ON r.student_number = ms.student_number
        AND r.reporting_term = ms.term
       LEFT OUTER JOIN gabby.renaissance.ar_default_goals df
         ON r.grade_level = df.grade_level
        AND r.reporting_term = df.time_period_name
       LEFT OUTER JOIN indiv_goals g
         ON r.student_number = g.student_number
        AND r.reporting_term = g.reporting_term
      ) sub
 )

SELECT student_number
      ,academic_year
      ,reporting_term
      ,CASE WHEN words_goal < 0 THEN -1 ELSE words_goal END AS words_goal
      ,CASE WHEN points_goal < 0 THEN -1 ELSE points_goal END AS points_goal

FROM
    (
     SELECT student_number           
           ,academic_year
           ,reporting_term
           ,words_goal
           ,points_goal
     FROM term_goals
     WHERE rn_dupe = 1

     UNION ALL

     SELECT student_number           
           ,academic_year
           ,'ARY' AS reporting_term
           ,SUM(words_goal) AS words_goal
           ,SUM(points_goal) AS points_goal
     FROM term_goals
     WHERE rn_dupe = 1
     GROUP BY student_number
             ,academic_year
    ) sub

UNION ALL

SELECT student_number
      ,academic_year
      ,reporting_term
      ,words_goal
      ,points_goal
FROM gabby.renaissance.ar_goals_archive