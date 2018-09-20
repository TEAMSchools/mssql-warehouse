USE gabby
GO

CREATE OR ALTER VIEW reporting.promotional_status AS

WITH attendance AS (
  SELECT studentid
        ,academic_year
        ,term_name
        ,mem_count_y1
        ,abs_unexcused_count_y1
        ,tdy_all_count_y1
        ,att_pts
        ,att_pts_pct
        ,db_name
        ,ROUND((((sub.mem_count_y1 * 0.105) - att_pts) / -0.105) + 0.5,0) AS days_to_90_pts
        ,ROUND((((sub.mem_count_y1 * 0.105) - abs_unexcused_count_y1) / -0.105) + 0.5,0) AS days_to_90_abs_only
        ,CASE
          WHEN sub.att_pts_pct >= 92 THEN 'On Track'
          WHEN sub.att_pts_pct >= 90 THEN 'Warning'
          WHEN sub.att_pts_pct < 90 THEN 'Off Track'          
         END AS promo_status_attendance        
  FROM
      (
       SELECT att.studentid
             ,att.academic_year
             ,att.term_name
             ,att.mem_count_y1
             ,att.abs_unexcused_count_y1
             ,att.tdy_all_count_y1       
             ,att.db_name 
             ,ROUND(att.abs_unexcused_count_y1 + (att.tdy_all_count_y1 / 3), 1, 1) AS att_pts
             ,ROUND(((att.mem_count_y1 - (att.abs_unexcused_count_y1 + FLOOR(att.tdy_all_count_y1 / 3))) / att.mem_count_y1) * 100, 0) AS att_pts_pct
       FROM gabby.powerschool.attendance_counts_static att
       WHERE att.mem_count_y1 > 0
      ) sub
 )

,lit AS (
  SELECT student_number
        ,academic_year
        ,term_name
        ,end_date
        ,base_read_lvl
        ,read_lvl      
        ,goal_lvl
        ,lvl_num
        ,goal_num
        ,is_new_test
        ,n_growth_rounds
        ,lvls_grown_yr
        ,lvls_grown_term
        ,CASE
          WHEN lvl_num >= 26 THEN 'On Track'
          WHEN end_date <= CONVERT(DATE,GETDATE()) AND lvl_num >= goal_num THEN 'On Track'
          WHEN end_date <= CONVERT(DATE,GETDATE()) AND lvl_num < goal_num THEN 'Off Track'
          WHEN is_new_test = 1 AND lvl_num >= goal_num THEN 'On Track'
          WHEN is_new_test = 1 AND lvl_num < goal_num THEN 'Off Track'
          WHEN is_new_test = 0 AND lvl_num >= prev_goal_num THEN 'On Track'
          WHEN is_new_test = 0 AND lvl_num < prev_goal_num THEN 'Off Track'
         END AS goal_status
        ,CASE
          WHEN lvl_num >= 26 THEN 1
          WHEN end_date <= CONVERT(DATE,GETDATE()) AND lvl_num >= goal_num THEN 1
          WHEN end_date <= CONVERT(DATE,GETDATE()) AND lvl_num < goal_num THEN 0
          WHEN is_new_test = 1 AND lvl_num >= goal_num THEN 1
          WHEN is_new_test = 1 AND lvl_num < goal_num THEN 0
          WHEN is_new_test = 0 AND lvl_num >= prev_goal_num THEN 1
          WHEN is_new_test = 0 AND lvl_num < prev_goal_num THEN 0
         END AS met_goal
  FROM
      (
       SELECT lit.student_number
             ,lit.academic_year             
             ,lit.end_date             
             ,lit.read_lvl
             ,lit.lvl_num
             ,lit.goal_lvl                             
             ,lit.goal_num             
             ,lit.is_new_test
             ,CASE 
               WHEN lit.test_round = 'DR' AND lit.is_curterm = 1 THEN 'Q1' 
               ELSE lit.test_round 
              END AS term_name             
             
             ,lit_prev.goal_num AS prev_goal_num                          
             ,lit.lvl_num - lit_prev.lvl_num AS lvls_grown_term

             ,lit_base.read_lvl AS base_read_lvl
             ,lit.lvl_num - lit_base.lvl_num AS lvls_grown_yr
             
             ,COUNT(CASE WHEN lit.end_date <= CONVERT(DATE,GETDATE()) THEN lit.read_lvl END) OVER(PARTITION BY lit.student_number, lit.academic_year ORDER BY lit.end_date ASC) - 1 AS n_growth_rounds                                       
       FROM gabby.lit.achieved_by_round_static lit
       LEFT JOIN gabby.lit.achieved_by_round_static lit_base
         ON lit.student_number = lit_base.student_number
        AND lit.academic_year = lit_base.academic_year
        AND lit_base.rn_round_asc = 1
       LEFT JOIN gabby.lit.achieved_by_round_static lit_prev
         ON lit.student_number = lit_prev.student_number
        AND lit.academic_year = lit_prev.academic_year
        AND (lit.rn_round_asc - 1) = lit_prev.rn_round_asc
       WHERE lit.achv_unique_id LIKE 'FPBAS%'
      ) sub
 )

,final_grades AS (
  SELECT student_number
        ,academic_year
        ,term_name
        ,N_below_60
        ,N_below_70
        ,db_name
        ,CASE
          WHEN N_below_60 > 0 THEN 'Off Track'
          WHEN N_below_70 > 0 THEN 'Warning'
          ELSE 'On Track'
         END AS promo_status_grades        
  FROM
      (
       SELECT gr.student_number
             ,gr.academic_year
             ,gr.term_name
             ,gr.db_name
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 70 THEN 1 ELSE 0 END) AS N_below_70
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 60 THEN 1 ELSE 0 END) AS N_below_60
       FROM gabby.powerschool.final_grades_static gr
       WHERE gr.excludefromgpa = 0
         AND gr.y1_grade_percent_adjusted IS NOT NULL
       GROUP BY gr.student_number
               ,gr.term_name
               ,gr.academic_year
               ,gr.db_name
      ) sub
 )

,credits AS (
  SELECT fg.student_number
        ,fg.academic_year
        ,fg.term_name
        ,fg.db_name
  
        ,ISNULL(SUM(fg.credit_hours), 0) AS total_credit_hours_enrolled_y1
        ,ISNULL(SUM(CASE                      
                     WHEN fg.y1_grade_letter LIKE 'F%' THEN 0 
                     ELSE fg.credit_hours 
                    END), 0) AS total_projected_credit_hours_y1

        ,ISNULL(SUM(CASE WHEN sg.studentid IS NULL THEN fg.credit_hours END), 0) AS total_credit_hours_enrolled
        ,ISNULL(SUM(CASE 
                     WHEN sg.studentid IS NOT NULL THEN NULL
                     WHEN fg.y1_grade_letter LIKE 'F%' THEN 0 
                     ELSE fg.credit_hours 
                    END), 0) AS total_projected_credit_hours        
  FROM gabby.powerschool.final_grades_static fg  
  LEFT JOIN gabby.powerschool.storedgrades sg
    ON fg.studentid = sg.studentid
   AND fg.course_number = sg.course_number
   AND fg.db_name = sg.db_name
   AND fg.academic_year = (LEFT(sg.termid, 2) + 1990)
   AND sg.storecode = 'Y1'
  GROUP BY fg.student_number
          ,fg.academic_year
          ,fg.term_name
          ,fg.db_name
 )

SELECT studentid
      ,student_number
      ,lastfirst
      ,academic_year
      ,schoolid 
      ,school_name     
      ,school_level
      ,iep_status
      ,is_retained_year
      ,is_retained_ever
      ,retention_flag
      ,sched_nextyeargrade
      ,next_school
      ,summerschoolnote  
      ,term_name
      ,reporting_term
      ,is_curterm
      ,promo_status_attendance
      ,att_pts_pct
      ,att_pts
      ,mem_count_y1
      ,abs_unexcused_count_y1
      ,tdy_all_count_y1
      ,days_to_90_pts
      ,days_to_90_abs_only
      ,base_read_lvl
      ,cur_read_lvl
      ,goal_lvl
      ,met_goal
      ,lit_goal_status
      ,lvls_grown_yr
      ,lvls_grown_term
      ,promo_status_lit
      ,promo_status_grades
      ,N_below_60
      ,N_below_70
      ,credits_enrolled_cum
      ,credits_enrolled_y1
      ,projected_credits_earned_cum
      ,projected_credits_earned_y1
      ,earned_credits_cum
      ,credits_needed
      ,promo_status_credits
      ,HWC_Y1
      ,HWQ_Y1
      ,GPA_Y1
      ,GPA_Y1_status
      ,GPA_term
      ,GPA_term_status
      ,GPA_cum
      ,GPA_cum_status
      ,CASE 
        WHEN school_level = 'ES' AND (iep_status = 'SPED' OR retention_flag >= 1) THEN 'See Teacher'
        WHEN CONCAT(promo_status_attendance, promo_status_credits, promo_status_grades, promo_status_lit) LIKE '%Off Track%' THEN 'Off Track'
        ELSE 'On Track'
       END AS promo_status_overall
FROM
    (
     SELECT co.studentid
           ,co.student_number
           ,co.lastfirst
           ,co.academic_year
           ,co.schoolid 
           ,co.school_name     
           ,co.school_level
           ,co.iep_status
           ,co.is_retained_year
           ,co.is_retained_ever           
           ,co.is_retained_ever + co.is_retained_year AS retention_flag
           
           ,s.sched_nextyeargrade
           ,s.next_school
           ,s.summerschoolnote  
           
           ,dt.alt_name AS term_name
           ,dt.time_per_name AS reporting_term
           
           ,dt.is_curterm

           /* attendance */
           ,att.promo_status_attendance
           ,att.att_pts_pct
           ,att.att_pts
           ,att.mem_count_y1
           ,att.abs_unexcused_count_y1
           ,att.tdy_all_count_y1
           ,att.days_to_90_pts
           ,att.days_to_90_abs_only

           /* lit */
           ,lit.base_read_lvl
           ,lit.read_lvl AS cur_read_lvl
           ,lit.goal_lvl
           ,lit.met_goal           
           ,lit.goal_status AS lit_goal_status
           ,lit.lvls_grown_yr
           ,lit.lvls_grown_term
           ,NULL AS promo_status_lit
           --,CASE                     
           --  WHEN NOT (co.schoolid = 73257 AND (co.grade_level - (co.academic_year - 2014)) > 0) THEN lit.goal_status
           --  /* Life Upper students have different promo criteria */
           --  WHEN lit.goal_status = 'On Track' THEN 'On Track' /* if On Track, then On Track*/
           --  WHEN lit.lvls_grown_yr >= lit.n_growth_rounds THEN 'On Track' /* if grew 1 lvl per round overall, then On Track */        
           --  WHEN lit.lvls_grown_yr < lit.n_growth_rounds THEN 'Off Track'             
           -- END AS promo_status_lit

           /* final grades */
           ,fg.promo_status_grades
           ,fg.N_below_60
           ,fg.N_below_70

           /* credits */
           ,CASE 
             WHEN co.grade_level < 9 THEN NULL
             ELSE cr.total_credit_hours_enrolled + ISNULL(cum.earned_credits_cum, 0)              
            END AS credits_enrolled_cum
           ,CASE WHEN co.grade_level >= 9 THEN cr.total_credit_hours_enrolled_y1 END AS credits_enrolled_y1
           
           ,CASE WHEN co.grade_level >= 9 THEN cr.total_projected_credit_hours + ISNULL(cum.earned_credits_cum, 0) END AS projected_credits_earned_cum                      
           ,CASE WHEN co.grade_level >= 9 THEN cr.total_projected_credit_hours_y1 END AS projected_credits_earned_y1
           
           ,CASE WHEN co.grade_level >= 9 THEN ISNULL(cum.earned_credits_cum, 0) END AS earned_credits_cum

           ,CASE             
             WHEN co.grade_level = 12 THEN 120
             WHEN co.grade_level = 11 THEN 85
             WHEN co.grade_level = 10 THEN 50
             WHEN co.grade_level = 9 THEN 25
            END AS credits_needed
           ,CASE
             WHEN co.grade_level < 9 THEN NULL
             WHEN co.grade_level = 12 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(cum.earned_credits_cum, 0) >= 120 THEN 'On Track'
             WHEN co.grade_level = 11 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(cum.earned_credits_cum, 0) >= 85 THEN 'On Track'
             WHEN co.grade_level = 10 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(cum.earned_credits_cum, 0) >= 50 THEN 'On Track'
             WHEN co.grade_level = 9 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(cum.earned_credits_cum, 0) >= 25 THEN 'On Track'
             ELSE 'Off Track'
            END AS promo_status_credits
           
           /* HW grades */
           ,cat.H_Y1 AS HWC_Y1
           ,CASE WHEN co.academic_year <= 2015 THEN cat.E_Y1 ELSE cat.H_Y1 END AS HWQ_Y1

           /* GPA */
           ,gpa.GPA_Y1
           ,CASE 
             WHEN gpa.GPA_Y1 IS NULL THEN NULL
             WHEN gpa.GPA_Y1 >= 3.85 THEN 'Summa Cum Laude'
             WHEN gpa.GPA_Y1 >= 3.5 THEN 'Magna Cum Laude'
             WHEN gpa.GPA_Y1 >= 3.0  THEN 'Cum Laude'
            END AS GPA_Y1_status      
           ,gpa.GPA_term      
           ,CASE 
             WHEN gpa.GPA_term IS NULL THEN NULL
             WHEN gpa.GPA_term >= 3.85 THEN 'Summa Cum Laude'
             WHEN gpa.GPA_term >= 3.5 THEN 'Magna Cum Laude'
             WHEN gpa.GPA_term >= 3.0  THEN 'Cum Laude'
            END AS GPA_term_status      
           ,cum.cumulative_Y1_gpa AS GPA_cum
           ,CASE 
             WHEN cum.cumulative_Y1_gpa IS NULL THEN NULL
             WHEN cum.cumulative_Y1_gpa >= 3.85 THEN 'Summa Cum Laude'
             WHEN cum.cumulative_Y1_gpa >= 3.5 THEN 'Magna Cum Laude'
             WHEN cum.cumulative_Y1_gpa >= 3.0  THEN 'Cum Laude'
            END AS GPA_cum_status          
     FROM gabby.powerschool.cohort_identifiers_static co
     JOIN gabby.powerschool.students s
       ON co.student_number = s.student_number
      AND co.db_name = s.db_name
     JOIN gabby.reporting.reporting_terms dt
       ON co.schoolid = dt.schoolid
      AND co.academic_year = dt.academic_year
      AND dt.identifier = 'RT'
      AND dt.alt_name != 'Summer School'
     LEFT JOIN attendance att
       ON co.studentid = att.studentid
      AND co.academic_year = att.academic_year
      AND co.db_name = att.db_name
      AND dt.alt_name = att.term_name COLLATE Latin1_General_BIN
     LEFT JOIN lit
       ON co.student_number = lit.student_number
      AND co.academic_year = lit.academic_year
      AND dt.alt_name = lit.term_name
      AND co.school_level = 'ES'
     LEFT JOIN final_grades fg
       ON co.student_number = fg.student_number
      AND co.academic_year = fg.academic_year
      AND co.db_name = fg.db_name
      AND dt.alt_name = fg.term_name COLLATE Latin1_General_BIN
     LEFT JOIN gabby.powerschool.category_grades_wide cat
       ON co.student_number = cat.student_number
      AND co.academic_year = cat.academic_year 
      AND co.db_name = cat.db_name
      AND dt.time_per_name = cat.reporting_term COLLATE Latin1_General_BIN
      AND cat.credittype = 'ALL'
     LEFT JOIN gabby.powerschool.gpa_detail gpa 
       ON co.student_number = gpa.student_number
      AND co.academic_year = gpa.academic_year
      AND co.db_name = gpa.db_name
      AND dt.alt_name = gpa.term_name COLLATE Latin1_General_BIN
     LEFT JOIN gabby.powerschool.gpa_cumulative cum
       ON co.studentid = cum.studentid
      AND co.schoolid = cum.schoolid
      AND co.db_name = cum.db_name
     LEFT JOIN credits cr
       ON co.student_number = cr.student_number
      AND co.academic_year = cr.academic_year
      AND co.db_name = cr.db_name
      AND dt.alt_name = cr.term_name COLLATE Latin1_General_BIN
     WHERE co.rn_year = 1
    ) sub