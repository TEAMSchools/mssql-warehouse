USE gabby
GO

CREATE OR ALTER VIEW tableau.promo_tracker AS 

WITH roster AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.academic_year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor_name   
        ,co.iep_status
        ,co.enroll_status
        ,co.db_name

        ,CONVERT(VARCHAR,dt.alt_name) AS term_name
        ,CONVERT(VARCHAR,dt.time_per_name) AS reporting_term
        ,dt.start_date AS term_start_date
        ,dt.end_date AS term_end_date
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms dt
    ON co.academic_year = dt.academic_year
   AND co.schoolid = dt.schoolid
   AND dt.identifier = 'RT'
   AND dt.alt_name != 'Summer School'
  WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND co.reporting_schoolid NOT IN (999999, 5173)
    AND co.rn_year = 1    
  
  UNION ALL

  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.academic_year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor_name           
        ,co.iep_status
        ,co.enroll_status
        ,co.db_name

        ,'Y1' AS term
        ,CONVERT(VARCHAR,dt.time_per_name) AS reporting_term
        ,dt.start_date AS term_start_date
        ,dt.end_date AS term_end_date
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms dt
    ON co.academic_year = dt.academic_year   
   AND dt.schoolid = 0
   AND dt.identifier = 'SY'   
  WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND co.reporting_schoolid NOT IN (999999, 5173)
    AND co.rn_year = 1
 )

,contact AS (
  SELECT student_number
        ,contact_type AS person
        ,phone_type AS type
        ,phone AS value      
  FROM gabby.powerschool.student_contacts_static  
 )

,grades AS (
  /* term grades */
  SELECT gr.student_number
        ,gr.academic_year            
        ,gr.reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,gr.term_grade_percent_adjusted        
        ,'TERM' AS subdomain
        ,'Term' AS finalgradename
  FROM gabby.powerschool.final_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND gr.excludefromgpa = 0

  UNION ALL

  SELECT gr.student_number        
        ,gr.academic_year      
        ,'SY1' AS reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted        
        ,'TERM' AS subdomain
        ,'Y1' AS finalgradename
  FROM gabby.powerschool.final_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND gr.is_curterm = 1
    AND gr.excludefromgpa = 0

  UNION ALL
  
  /* category grades */
  SELECT gr.student_number        
        ,gr.academic_year            
        ,'SY1' AS reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,ROUND(AVG(gr.grade_category_pct), 0) AS term_grade_percent_adjusted        
        ,'CATEGORY' AS subdomain
        ,gr.grade_category AS finalgradename
  FROM gabby.powerschool.category_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)    
  GROUP BY gr.student_number
          ,gr.academic_year
          ,gr.grade_category
          ,gr.credittype
          ,gr.course_name
 )

,attendance AS (
  SELECT studentid
        ,db_name
        ,academic_year
        ,reporting_term
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS att_code
        ,value AS att_counts        
        ,CASE
          WHEN field = 'presentpct_term' THEN 'ABSENT'
          WHEN field = 'ontimepct_term' THEN 'TARDY'
          WHEN field IN ('attpts_term', 'attptspct_term') THEN 'PROMO'
          WHEN field LIKE 'A%' THEN 'ABSENT'
          WHEN field LIKE 'T%' THEN 'TARDY'
          WHEN field LIKE '%SS%' THEN 'SUSPENSION'
         END AS subdomain        
  FROM 
      (
       SELECT att.studentid
             ,att.db_name
             ,att.academic_year
             ,att.reporting_term           
             ,att.a_count_term
             ,att.ad_count_term
             ,att.ae_count_term
             ,att.iss_count_term
             ,att.oss_count_term
             ,att.t_count_term
             ,att.t10_count_term
             ,att.abs_unexcused_count_term
             ,att.tdy_all_count_term
             ,att.abs_unexcused_count_term + ROUND((att.TDY_all_count_term / 3), 1, 1) AS attpts_term
             ,ROUND(
                ((att.mem_count_term - att.abs_unexcused_count_term) 
                 / CASE WHEN att.mem_count_term = 0 THEN NULL ELSE att.mem_count_term END) 
                 * 100, 0) AS presentpct_term
             ,ROUND(
                ((att.mem_count_term - att.abs_unexcused_count_term - att.TDY_all_count_term) 
                 / CASE WHEN (att.mem_count_term - att.abs_unexcused_count_term) = 0 THEN NULL ELSE (att.mem_count_term - att.abs_unexcused_count_term) END)
                 * 100, 0) AS ontimepct_term             
             ,ROUND(
                ((att.mem_count_term - (att.abs_unexcused_count_term + ROUND((att.TDY_all_count_term / 3), 1, 1))) 
                 / CASE WHEN att.mem_count_term = 0 THEN NULL ELSE att.mem_count_term END) 
                 * 100, 0) AS attptspct_term
       FROM gabby.powerschool.attendance_counts_static att
       WHERE att.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND att.mem_count_term > 0
         AND att.mem_count_term != att.abs_unexcused_count_term

       UNION ALL

       SELECT att.studentid
             ,att.db_name
             ,att.academic_year
             ,'SY1' AS reporting_term
             ,att.a_count_y1
             ,att.ad_count_y1
             ,att.ae_count_y1
             ,att.iss_count_y1
             ,att.oss_count_y1
             ,att.t_count_y1
             ,att.t10_count_y1      
             ,att.abs_unexcused_count_y1
             ,att.tdy_all_count_y1
             ,att.abs_unexcused_count_y1 + ROUND((att.TDY_all_count_y1 / 3), 1, 1) AS attpts_y1             
             ,ROUND(
                ((att.MEM_count_y1 - (att.abs_unexcused_count_y1 + ROUND((att.TDY_all_count_y1 / 3), 1, 1))) 
                 / CASE WHEN att.MEM_count_y1 = 0 THEN NULL ELSE att.MEM_count_y1 END) 
                 * 100, 0) AS attptspct_y1
             ,ROUND(
                ((att.MEM_count_y1 - att.abs_unexcused_count_y1) 
                 / CASE WHEN att.MEM_count_y1 = 0 THEN NULL ELSE att.MEM_count_y1 END) 
                 * 100, 0) AS presentpct_y1
             ,ROUND(
                ((att.MEM_count_y1 - att.abs_unexcused_count_y1 - att.TDY_all_count_y1) 
                 / CASE WHEN (att.MEM_count_y1 - att.abs_unexcused_count_y1) = 0 THEN NULL ELSE (att.mem_count_y1 - att.abs_unexcused_count_y1) END) 
                 * 100, 0) AS ontimepct_y1             
       FROM gabby.powerschool.attendance_counts_static att 
       WHERE att.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND att.mem_count_y1 > 0
         AND att.mem_count_y1 != att.abs_unexcused_count_y1
         AND att.is_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (a_count_term       
                 ,ad_count_term
                 ,ae_count_term
                 ,abs_unexcused_count_term
                 ,t_count_term
                 ,t10_count_term    
                 ,tdy_all_count_term
                 ,iss_count_term
                 ,oss_count_term
                 ,presentpct_term
                 ,ontimepct_term
                 ,attpts_term
                 ,attptspct_term)
   ) u
 )

,modules AS (
  SELECT a.subject_area
        ,a.title
        ,a.academic_year
        ,a.local_student_id AS student_number
        ,a.assessment_id
        ,a.scope        
        ,a.date_taken AS measure_date
        ,CONVERT(VARCHAR(250),CASE 
          WHEN a.subject_area = 'Writing' THEN a.standard_description
          ELSE a.standard_code 
         END) AS standards
        ,CASE
          WHEN a.subject_area = 'Writing' THEN a.points
          ELSE a.percent_correct        
         END AS percent_correct
        ,CASE
          WHEN a.performance_band_number = 5 THEN 'Above'
          WHEN a.performance_band_number = 4 THEN 'Target'
          WHEN a.performance_band_number = 3 THEN 'Near'
          WHEN a.performance_band_number = 2 THEN 'Below'
          WHEN a.performance_band_number = 1 THEN 'Far Below'
         END AS proficiency_label
        ,CASE
          WHEN a.subject_area = 'Writing' THEN 'WRITING RUBRIC'
          WHEN a.response_type = 'O' THEN 'OVERALL' 
          WHEN a.response_type = 'S' THEN 'STANDARDS' 
         END AS subdomain        
  FROM gabby.illuminate_dna_assessments.agg_student_responses_all a  
  WHERE a.subject_area IN ('Text Study','Mathematics','Writing')
    AND a.scope IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
    AND a.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND a.response_type IN ('O','S')
    AND a.is_replacement = 0
 )

,gpa AS (
  SELECT student_number        
        ,academic_year      
        ,reporting_term
        ,schoolid
        ,gpa_y1 AS gpa
        ,'GPA Y1 - TERM' AS subdomain
  FROM gabby.powerschool.gpa_detail
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)

  UNION ALL

  SELECT student_number        
        ,academic_year      
        ,'SY1' AS reporting_term
        ,schoolid
        ,gpa_y1 AS GPA
        ,'GPA Y1' AS subdomain
  FROM gabby.powerschool.gpa_detail
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND is_curterm = 1

  UNION ALL

  SELECT CONVERT(INT,s.student_number) AS student_number
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR()  AS academic_year
        ,'SY1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.cumulative_Y1_gpa AS gpa
        ,'GPA CUMULATIVE' AS subdomain
  FROM gabby.powerschool.gpa_cumulative gpa
  JOIN gabby.powerschool.students s
    ON gpa.studentid = s.id
   AND gpa.db_name = s.db_name

  UNION ALL

  SELECT CONVERT(INT,s.student_number) AS student_number
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
        ,'SY1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.earned_credits_cum AS gpa
        ,'CREDITS EARNED' AS subdomain
  FROM gabby.powerschool.gpa_cumulative gpa
  JOIN gabby.powerschool.students s
    ON gpa.studentid = s.id
   AND gpa.db_name = s.db_name
  WHERE gpa.schoolid = 73253
 )

,lit AS (
  /* STEP/F&P */
  SELECT student_number        
        ,academic_year        
        ,test_round      
        ,read_lvl
        ,lvl_num               
        ,'ACHIEVED' AS subdomain 
  FROM gabby.lit.achieved_by_round_static
  WHERE read_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())

  UNION ALL

  SELECT student_number        
        ,academic_year        
        ,test_round      
        ,goal_lvl
        ,goal_num
        ,'GOAL' AS subdomain
  FROM gabby.lit.achieved_by_round_static
  WHERE goal_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())
  
  UNION ALL

  /* Lexile */
  SELECT student_id        
        ,academic_year        
        ,term AS test_round        
        ,CONCAT(ritto_reading_score,'L') AS read_lvl
        ,CASE
          WHEN ritto_reading_score = 0 THEN -1
          WHEN ritto_reading_score BETWEEN 0 AND 100 THEN 1
          WHEN ritto_reading_score BETWEEN 100 AND 200 THEN 5
          WHEN ritto_reading_score BETWEEN 200 AND 300 THEN 10
          WHEN ritto_reading_score BETWEEN 300 AND 400 THEN 14
          WHEN ritto_reading_score BETWEEN 400 AND 500 THEN 17
          WHEN ritto_reading_score BETWEEN 500 AND 600 THEN 20
          WHEN ritto_reading_score BETWEEN 600 AND 700 THEN 22
          WHEN ritto_reading_score BETWEEN 700 AND 800 THEN 25
          WHEN ritto_reading_score BETWEEN 800 AND 900 THEN 27
          WHEN ritto_reading_score BETWEEN 900 AND 1000 THEN 28
          WHEN ritto_reading_score BETWEEN 1000 AND 1100 THEN 29
          WHEN ritto_reading_score BETWEEN 1100 AND 1200 THEN 30
          WHEN ritto_reading_score >= 1200 THEN 31
         END AS lvl_num        
        ,'ACHIEVED' AS subdomain
  FROM gabby.nwea.assessment_result_identifiers
  WHERE measurement_scale = 'Reading'
    AND school_name = 'Newark Collegiate Academy'
    AND rn_term_subj = 1

  UNION ALL

  SELECT map.student_id        
        ,map.academic_year        
        ,map.term AS test_round        
        ,CASE
          WHEN s.grade_level = 9 THEN '900L'
          WHEN s.grade_level = 10 THEN '1000L'
          WHEN s.grade_level = 11 THEN '1100L'
          WHEN s.grade_level = 12 THEN '1200L'
         END AS goal_lvl
        ,CASE
          WHEN s.grade_level = 9 THEN 28
          WHEN s.grade_level = 10 THEN 29
          WHEN s.grade_level = 11 THEN 30
          WHEN s.grade_level = 12 THEN 31
         END AS goal_num
        ,'GOAL' AS subdomain
  FROM gabby.nwea.assessment_result_identifiers map
  JOIN gabby.powerschool.students s
    ON map.student_id = s.student_number
   AND s.schoolid = 73253
  WHERE map.measurement_scale = 'Reading'    
    AND map.school_name = 'Newark Collegiate Academy'
    AND map.rn_term_subj = 1
 )

,map AS (
  SELECT student_id AS student_number        
        ,academic_year
        ,test_year
        ,term
        ,measurement_scale
        ,test_ritscore
        ,percentile_2015_norms AS testpercentile
        ,NULL AS subdomain                        
  FROM gabby.nwea.assessment_result_identifiers
  WHERE rn_term_subj = 1
 )

,standardized_tests AS (
  /* PARCC */
  SELECT local_student_identifier AS student_number        
        ,academic_year
        ,NULL AS test_date
        ,'PARCC' AS test_name
        ,subject COLLATE SQL_Latin1_General_CP1_CI_AS AS subject
        ,test_scale_score
        ,test_performance_level
        ,CASE
          WHEN test_performance_level = 5 THEN 'Exceeded'
          WHEN test_performance_level = 4 THEN 'Met'
          WHEN test_performance_level = 3 THEN 'Approached'
          WHEN test_performance_level = 2 THEN 'Partially Met'
          WHEN test_performance_level = 1 THEN 'Did Not Meet'
         END AS performance_level_label       
  FROM gabby.parcc.summative_record_file

  UNION ALL

  /* NJASK & HSPA */
  SELECT local_student_id AS student_number        
        ,academic_year
        ,NULL AS test_date
        ,test_type
        ,subject      
        ,scaled_score      
        ,CASE
          WHEN performance_level = 'Advanced Proficient' THEN 5
          WHEN performance_level = 'Proficient' THEN 4
          WHEN performance_level = 'Partially Proficient' THEN 1
         END AS performance_level
        ,performance_level AS performance_level_label
  FROM gabby.njsmart.all_state_assessments

  UNION ALL

  /* ACT */
  SELECT student_number        
        ,academic_year
        ,test_date
        ,test_name
        ,CONVERT(VARCHAR(25),subject) AS subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM
      (
       SELECT student_number             
             ,academic_year
             ,test_date
             ,test_type AS test_name
             ,CONVERT(INT,composite) AS composite
             ,CONVERT(INT,english) AS english
             ,CONVERT(INT,math) AS math
             ,CONVERT(INT,reading) AS reading
             ,CONVERT(INT,science) AS science             
       FROM gabby.naviance.act_scores_clean
      ) sub
  UNPIVOT(
    scale_score
    FOR subject IN (composite
                   ,english
                   ,math
                   ,reading
                   ,science)
   ) u

  UNION ALL

  /* ACT Prep */
  SELECT student_number        
        ,academic_year
        ,administered_at AS test_date
        ,'ACT Prep' AS test_name
        ,CASE WHEN subject_area = 'Mathematics' THEN 'Math' ELSE subject_area END AS subject
        ,scale_score
        ,overall_performance_band AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.act.test_prep_scores 
  WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND rn_dupe = 1

  UNION ALL
  
  /* SAT */
  SELECT student_number
        ,academic_year
        ,test_date      
        ,'SAT' AS test_name
        ,CONVERT(VARCHAR(25),subject) AS subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.sat_scores_clean
  UNPIVOT(
    scale_score
    FOR subject IN (all_tests_total
                   ,math
                   ,verbal
                   ,writing)
   ) u

  UNION ALL

  /* SAT II */
  SELECT student_number
        ,academic_year
        ,test_date
        ,'SAT II' test_name      
        ,test_name AS subject
        ,score AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.sat_2_scores_clean

  UNION ALL  

  /* AP */
  SELECT CONVERT(INT,hs_student_id) AS student_number        
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date     
        ,'AP' AS test_name      
        ,CONVERT(VARCHAR(125),test_name) AS subject
        ,CONVERT(INT,score) AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.ap_scores 

  UNION ALL

  /* EXPLORE */
  SELECT CONVERT(INT,hs_student_id) AS hs_student_id
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date     
        ,'EXPLORE' AS test_name
        ,CONVERT(VARCHAR(25),subject) AS subject
        ,CONVERT(INT,scale_score) AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.explore_scores
  UNPIVOT(
    scale_score
    FOR subject IN (english	
                   ,math
                   ,reading
                   ,science
                   ,composite)
   ) u

  UNION ALL

  SELECT CONVERT(INT,hs_student_id) AS student_number
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date 
        ,'PSAT' AS test_name
        ,CONVERT(VARCHAR(25),subject) AS subject
        ,CONVERT(INT,scale_score) AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.psat_scores
  UNPIVOT(
    scale_score
    FOR subject IN (critical_reading
                   ,math
                   ,writing
                   ,total)
   ) u
 )

,collegeapps AS (
  SELECT sub.student_number
        ,sub.collegename
        ,sub.level
        ,sub.result_code
        ,sub.value        
        ,ROW_NUMBER() OVER(                                
           PARTITION BY sub.student_number
             ORDER BY sub.competitiveness_ranking_int DESC) AS competitiveness_ranking 
  FROM
      ( 
       SELECT CONVERT(INT,app.hs_student_id) AS student_number
             ,CONVERT(VARCHAR(125),app.collegename) AS collegename
             ,CONVERT(VARCHAR(25),app.level) AS level
             ,CONVERT(VARCHAR(125),CASE 
               WHEN app.result_code IN ('unknown') 
                 OR app.result_code IS NULL 
                      THEN app.stage 
               ELSE app.result_code 
              END) AS result_code
             ,CONVERT(VARCHAR(250),
                CONCAT('Type:', CHAR(9), REPLACE(app.inst_control,'p','P'), CHAR(10)
                      ,'Attending:', CHAR(9), app.attending, CHAR(10)               
                      ,app.comments)) AS value
        
             ,CASE
               WHEN a.competitiveness_ranking_c = 'Most Competitive+' THEN 7
               WHEN a.competitiveness_ranking_c = 'Most Competitive' THEN 6
               WHEN a.competitiveness_ranking_c = 'Highly Competitive' THEN 5
               WHEN a.competitiveness_ranking_c = 'Very Competitive' THEN 4
               WHEN a.competitiveness_ranking_c = 'Noncompetitive' THEN 1
               WHEN a.competitiveness_ranking_c = 'Competitive' THEN 3
               WHEN a.competitiveness_ranking_c = 'Less Competitive' THEN 2
              END competitiveness_ranking_int
       FROM gabby.naviance.college_applications app
       LEFT OUTER JOIN gabby.alumni.account a
         ON app.ceeb_code = CONVERT(VARCHAR,a.ceeb_code_c)
        AND a.record_type_id = '01280000000BQEkAAO'
        AND a.competitiveness_ranking_c IS NOT NULL
      ) sub
 )

,promo_status AS (
  SELECT student_number
        ,academic_year
        ,CONVERT(VARCHAR,field) AS subdomain
        ,CASE WHEN field LIKE '%status%' THEN value ELSE NULL END AS text_value
        ,CASE WHEN field LIKE '%status%' THEN NULL ELSE CONVERT(FLOAT,value) END AS numeric_value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,schoolid             

             /* overall */
             ,CONVERT(VARCHAR,promo_status_overall) AS promo_status_overall             
             
             /* attendance */
             ,CONVERT(VARCHAR,promo_status_attendance) AS promo_status_att
             ,CONVERT(VARCHAR,att_pts) AS att_pts
             ,CONVERT(VARCHAR,att_pts_pct) AS att_pts_pct
             ,CONVERT(VARCHAR,days_to_90_pts) AS days_to_90
             ,CONVERT(VARCHAR,days_to_90_abs_only) AS days_to_90_abs_only
             
             /* lit */
             ,CONVERT(VARCHAR,promo_status_lit) AS lit_ARFR_status                   
             ,CONVERT(VARCHAR,cur_read_lvl) AS read_lvl_status
             ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl_status      
             
             /* grades */
             ,CONVERT(VARCHAR,promo_status_grades) AS promo_status_grades /* # failing */                          
             ,CONVERT(VARCHAR,N_below_60) AS n_failing       
             ,CONVERT(VARCHAR,gpa_y1) AS gpa_y1_promo                   

             /* credits */
             ,CONVERT(VARCHAR,promo_status_credits) AS promo_status_credits
             ,CONVERT(VARCHAR,credits_enrolled_y1) AS credits_enrolled
             ,CONVERT(VARCHAR,projected_credits_earned_cum) AS projected_credits_earned
             ,CONVERT(VARCHAR,earned_credits_cum) AS earned_credits_cum
             ,CONVERT(VARCHAR,credits_needed) AS credits_needed
       FROM gabby.reporting.promotional_status
       WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND is_curterm = 1       
      ) sub
  UNPIVOT(
    value
    FOR field IN (days_to_90
                 ,days_to_90_abs_only
                 ,att_pts
                 ,att_pts_pct                 
                 ,n_failing
                 ,promo_status_overall
                 ,promo_status_grades
                 ,promo_status_att
                 ,read_lvl_status
                 ,goal_lvl_status          
                 ,lit_ARFR_status
                 ,promo_status_credits
                 ,credits_needed
                 ,credits_enrolled
                 ,projected_credits_earned
                 ,earned_credits_cum
                 ,gpa_y1_promo)
   ) u
 )

,instructional_tech AS (
  SELECT student_number
        ,academic_year        
        ,words AS progress
        ,words_goal AS goal
        ,stu_status_words AS goal_status
        ,CASE WHEN reporting_term = 'ARY' THEN 'Y1' ELSE REPLACE(reporting_term, 'AR', 'Q') END AS term_name
        ,'AR' AS subdomain      
  FROM gabby.renaissance.ar_progress_to_goals
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
 )

--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'GRADES' AS domain
      ,gr.subdomain      
      ,gr.credittype AS subject
      ,gr.course_name
      ,gr.finalgradename AS measure_name
      ,gr.term_grade_percent_adjusted AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN grades gr
  ON r.student_number = gr.student_number
 AND r.academic_year = gr.academic_year
 AND r.reporting_term COLLATE Latin1_General_BIN = gr.reporting_term

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'ATTENDANCE' AS domain
      ,att.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,att.att_code COLLATE Latin1_General_BIN AS measure_name
      ,att.att_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN attendance att
  ON r.studentid = att.studentid
 AND r.db_name = att.db_name
 AND r.academic_year = att.academic_year
 AND r.reporting_term COLLATE Latin1_General_BIN = att.reporting_term

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,cma.scope AS term
      ,r.reporting_term      
      ,'MODULES' AS domain
      ,cma.subdomain      
      ,cma.subject_area COLLATE Latin1_General_BIN AS subject
      ,cma.title COLLATE Latin1_General_BIN AS course_name
      ,cma.standards COLLATE Latin1_General_BIN AS measure_name
      ,cma.percent_correct AS measure_value
      ,cma.measure_date
      ,cma.assessment_id AS performance_level
      ,cma.proficiency_label AS performance_level_label
FROM roster r
LEFT OUTER JOIN modules cma
  ON r.student_number = cma.student_number
 AND r.academic_year = cma.academic_year
WHERE r.term_name = 'Y1' 

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,gpa.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'GPA'
      ,gpa.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,gpa.GPA AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN gpa
  ON r.student_number = gpa.student_number 
 AND r.schoolid = gpa.schoolid
 AND r.academic_year >= gpa.academic_year
 AND r.reporting_term COLLATE Latin1_General_BIN = gpa.reporting_term
 AND r.term_start_date <= CONVERT(DATE,GETDATE())

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,lit.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,lit.test_round AS term
      ,r.reporting_term      
      ,'LIT'
      ,lit.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,lit.read_lvl AS measure_name
      ,lit.lvl_num AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN lit
  ON r.student_number = lit.student_number
 AND r.academic_year >= lit.academic_year
WHERE r.term_name = 'Y1'

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,map.test_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,map.term
      ,r.reporting_term      
      ,'MAP' AS domain
      ,map.subdomain      
      ,map.measurement_scale AS subject
      ,NULL AS course_name
      ,CONVERT(VARCHAR,map.test_ritscore) AS measure_name
      ,map.testpercentile AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN map
  ON r.student_number = map.student_number
 AND r.academic_year >= map.academic_year
WHERE r.term_name = 'Y1' 

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,std.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'STANDARDIZED TESTS' AS domain
      ,std.test_name COLLATE Latin1_General_BIN AS subdomain
      ,std.subject COLLATE Latin1_General_BIN AS subject
      ,NULL AS course_name
      ,CONVERT(VARCHAR(250),NEWID()) COLLATE Latin1_General_BIN AS measure_name
      ,std.test_scale_score AS measure_value
      ,std.test_date AS measure_date
      ,std.test_performance_level AS performance_level
      ,std.performance_level_label
FROM roster r
LEFT OUTER JOIN standardized_tests std
  ON r.student_number = std.student_number
WHERE r.term_name = 'Y1'

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'COLLEGE APPS' AS domain
      ,apps.level AS subdomain
      ,apps.result_code AS subject
      ,apps.collegename AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,apps.competitiveness_ranking AS performance_level
      ,apps.value AS performance_level_label
FROM roster r
LEFT OUTER JOIN collegeapps apps
  ON r.student_number = apps.student_number
WHERE r.term_name = 'Y1'

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'PROMO STATUS' AS domain
      ,promo.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,promo.numeric_value AS performance_level
      ,promo.text_value AS performance_level_label
FROM roster r
LEFT OUTER JOIN promo_status promo
  ON r.student_number = promo.student_number 
 AND r.academic_year = promo.academic_year
WHERE r.term_name = 'Y1'

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'CONTACT' AS domain
      ,c.type AS subdomain
      ,c.person AS subject
      ,NULL AS course_name
      ,c.value AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN contact c
  ON r.student_number = c.student_number  
WHERE r.term_name = 'Y1'

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,'BLENDED LEARNING' AS domain
      ,b.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,b.progress AS measure_value
      ,NULL AS measure_date
      ,b.goal AS performance_level
      ,b.goal_status AS performance_level_label
FROM roster r
JOIN instructional_tech b
  ON r.student_number = b.student_number
 AND r.academic_year = b.academic_year
 AND r.term_name = b.term_name

UNION ALL
--*/
--/*
/* blank row for default */
SELECT DISTINCT 
       NULL AS studentid
      ,NULL AS student_number
      ,' Choose a student...' AS lastfirst
      ,academic_year
      ,reporting_schoolid AS schoolid
      ,grade_level
      ,NULL AS cohort
      ,NULL AS team
      ,advisor_name      
      ,'No IEP' AS spedlep
      ,0 AS enroll_status
      ,NULL AS term
      ,NULL AS reporting_term      
      ,'CONTACT' AS domain
      ,NULL AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM gabby.powerschool.cohort_identifiers_static 
WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND reporting_schoolid NOT IN (999999, 5173)
--*/

/* no longer used */
/*
UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,logs.domain
      ,logs.logtype AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,logs.subtype AS measure_name
      ,logs.n_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN disc_logs logs
  ON r.studentid = logs.studentid
 AND r.academic_year = logs.academic_year
 AND r.reporting_term = logs.reporting_term
WHERE r.term_name != 'Y1'

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term_name
      ,r.reporting_term      
      ,daily.domain
      ,daily.field AS subdomain
      ,daily.time_of_day AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,daily.n_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN daily_tracking daily
  ON r.studentid = daily.studentid
 AND r.academic_year = daily.academic_year
 AND r.term_name = daily.term
WHERE r.term_name != 'Y1'

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,ss.term
      ,r.reporting_term      
      ,'SOCIAL SKILLS' AS domain
      ,NULL AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,ss.social_skill AS measure_name
      ,CONVERT(FLOAT,ss.score) AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN KIPP_NJ..REPORTING$social_skills#ES ss WITH(NOLOCK)
  ON r.student_number = ss.student_number 
 AND r.academic_year = ss.academic_year
 AND r.term_name = ss.term
 AND ISNUMERIC(ss.score) = 1
WHERE r.term_name != 'Y1'
  AND r.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,CONVERT(VARCHAR,ww.listweek_num) AS term
      ,r.reporting_term      
      ,ww.domain
      ,ww.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,ww.word AS measure_name
      ,ww.score AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN wordwork ww
  ON r.student_number = ww.student_number
 AND r.academic_year = ww.academic_year
WHERE r.term_name = 'Y1'
--*/