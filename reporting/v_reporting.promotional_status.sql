USE gabby
GO

CREATE OR ALTER VIEW reporting.promotional_status AS

WITH failing AS (
  SELECT student_number
        ,academic_year
        ,term_name COLLATE Latin1_General_BIN AS term_name
        ,SUM(CASE WHEN y1_grade_letter IN ('F', 'F*') THEN 1 ELSE 0 END) AS n_failing
        ,SUM(CASE WHEN y1_grade_letter IN ('F', 'F*') AND credittype IN ('MATH', 'ENG', 'SCI', 'SOC') THEN 1 ELSE 0 END) AS n_failing_ms_core
  FROM gabby.powerschool.final_grades_static
  GROUP BY student_number
          ,academic_year
          ,term_name
 )

,credits AS (
  SELECT studentid
        ,[db_name]
        ,schoolid
        ,earned_credits_cum_projected
  FROM gabby.powerschool.gpa_cumulative
 )

,qas AS (
  SELECT sub.local_student_id
        ,sub.academic_year
        ,sub.term_administered
        ,ROUND(AVG(sub.avg_performance_band_number) OVER(
           PARTITION BY local_student_id, academic_year 
             ORDER BY term_administered), 0) AS avg_performance_band_running
  FROM
      (
       SELECT local_student_id
             ,academic_year
             ,term_administered
             ,AVG(performance_band_number) AS avg_performance_band_number
       FROM gabby.illuminate_dna_assessments.agg_student_responses_all
       WHERE module_type = 'QA'
         AND subject_area = 'Mathematics'
         AND response_type = 'O'
         AND is_replacement = 0
       GROUP BY local_student_id
               ,academic_year
               ,term_administered
      ) sub
)

SELECT sub.student_number
      ,sub.academic_year
      ,sub.iep_status
      ,sub.is_retained_flag
      ,sub.reporting_term_name
      ,sub.alt_name
      ,sub.is_curterm
      ,sub.ada_y1_running
      ,sub.fp_independent_level
      ,sub.grades_y1_failing_projected
      ,sub.grades_y1_credits_projected
      ,sub.qa_avg_performance_band_running
      ,sub.promo_status_attendance
      ,sub.promo_status_lit
      ,sub.promo_status_grades
      ,sub.promo_status_qa_math
      ,CASE
        WHEN sub.iep_status = 'SPED' OR sub.is_retained_flag = 1 THEN 'See Teacher'
        WHEN CONCAT(sub.promo_status_attendance
                   ,sub.promo_status_lit
                   ,sub.promo_status_grades
                   ,sub.promo_status_qa_math) LIKE '%Off Track%' THEN 'Off Track'
        ELSE 'On Track'
       END AS promo_status_overall
FROM
    (
     SELECT sub.student_number
           ,sub.academic_year
           ,sub.iep_status
           ,sub.is_retained_flag
           ,sub.reporting_term_name
           ,sub.alt_name
           ,sub.is_curterm
           ,sub.ada_y1_running
           ,sub.fp_independent_level
           ,sub.grades_y1_failing_projected
           ,sub.grades_y1_credits_projected
           ,sub.qa_avg_performance_band_running
           ,CASE
             WHEN sub.ada_y1_running >= 90 THEN 'On Track'
             WHEN sub.ada_y1_running < 90 THEN 'Off Track'
             ELSE 'No Data'
            END AS promo_status_attendance
           ,CASE
             WHEN sub.school_level = 'HS' THEN 'N/A'
             WHEN sub.fp_goal_status IN ('Approaching', 'Target', 'Above Target', 'Achieved Z') THEN 'On Track'
             WHEN sub.fp_goal_status IN ('Far Below', 'Below') THEN 'Off Track'
             ELSE 'No Data'
            END AS promo_status_lit
           ,CASE
             WHEN sub.grade_level = 12 THEN 'N/A'
             WHEN sub.school_level = 'ES' THEN 'N/A'
             WHEN sub.school_level = 'MS' AND sub.grades_y1_failing_projected >= 2 THEN 'Off Track'
             WHEN sub.school_level = 'MS' AND sub.grades_y1_failing_projected < 2 THEN 'On Track'
             WHEN sub.school_level = 'HS' 
              AND (sub.grades_y1_failing_projected >= 3 OR sub.grades_y1_credits_projected < sub.grades_y1_credits_goal)
                  THEN 'Off Track'
             WHEN sub.school_level = 'HS' 
              AND (sub.grades_y1_failing_projected < 3 AND sub.grades_y1_credits_projected >= sub.grades_y1_credits_goal)
                  THEN 'On Track' 
             ELSE 'No Data'
            END AS promo_status_grades
           ,CASE 
             WHEN sub.school_level = 'HS' THEN 'N/A'
             WHEN sub.qa_avg_performance_band_running >= 3 THEN 'On Track' 
             WHEN sub.qa_avg_performance_band_running < 3 THEN 'Off Track' 
             ELSE 'No Data'
            END AS promo_status_qa_math
     FROM
         (
          SELECT co.student_number
                ,co.academic_year
                ,co.school_level
                ,co.grade_level
                ,co.iep_status
                ,CASE WHEN co.is_retained_year + co.is_retained_ever >= 1 THEN 1 ELSE 0 END AS is_retained_flag
      
                ,rt.time_per_name AS reporting_term_name
                ,rt.alt_name
                ,rt.is_curterm

                ,ROUND(((att.mem_count_y1 - att.abs_unexcused_count_y1) / att.mem_count_y1) * 100, 0) AS ada_y1_running

                ,lit.read_lvl AS fp_independent_level
                ,lit.goal_status AS fp_goal_status

                ,CASE
                  WHEN co.school_level = 'MS' THEN f.n_failing_ms_core
                  ELSE f.n_failing
                 END AS grades_y1_failing_projected

                ,cr.earned_credits_cum_projected AS grades_y1_credits_projected
                ,CASE
                  WHEN co.grade_level = 9 THEN 30
                  WHEN co.grade_level = 10 THEN 60
                  WHEN co.grade_level = 11 THEN 90
                 END AS grades_y1_credits_goal

                ,qas.avg_performance_band_running AS qa_avg_performance_band_running
          FROM gabby.powerschool.cohort_identifiers_static co
          JOIN gabby.reporting.reporting_terms rt
            ON co.schoolid = rt.schoolid
           AND co.academic_year = rt.academic_year
           AND rt.identifier = 'RT'
           AND rt._fivetran_deleted = 0
          LEFT JOIN gabby.powerschool.attendance_counts_static att
            ON co.studentid = att.studentid
           AND co.[db_name] = att.[db_name]
           AND co.academic_year = att.academic_year
           AND rt.time_per_name = att.reporting_term COLLATE Latin1_General_BIN
           AND att.mem_count_y1 > 0
          LEFT JOIN gabby.lit.achieved_by_round_static lit
            ON co.student_number = lit.student_number
           AND co.academic_year = lit.academic_year
           AND rt.alt_name = lit.test_round
          LEFT JOIN failing f
            ON co.student_number = f.student_number
           AND co.academic_year = f.academic_year
           AND rt.alt_name = f.term_name
          LEFT JOIN credits cr
            ON co.studentid = cr.studentid
           AND co.schoolid = cr.schoolid
           AND co.[db_name] = cr.[db_name]
          LEFT JOIN qas
            ON co.student_number = qas.local_student_id
           AND co.academic_year = qas.academic_year
           AND rt.alt_name = qas.term_administered
          WHERE co.rn_year = 1
         ) sub
    ) sub