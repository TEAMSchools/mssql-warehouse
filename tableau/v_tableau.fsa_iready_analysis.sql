USE gabby
GO

CREATE OR ALTER VIEW tableau.fsa_iready_analysis AS

WITH current_week AS (
  SELECT tw.[date]
  FROM gabby.utilities.reporting_days td
  JOIN gabby.utilities.reporting_days tw
    ON td.week_part = tw.week_part
   AND td.year_part = tw.year_part
  WHERE td.[date] = CAST(GETDATE() AS DATE)
 )

,iready_lessons AS (
  SELECT pl.student_id
        ,pl.[subject]
        ,CAST(SUM(CASE WHEN pl.passed_or_not_passed = 'Passed' THEN 1 ELSE 0 END) AS FLOAT) AS lessons_passed
        ,CAST(COUNT(DISTINCT pl.lesson_id) AS FLOAT) AS total_lessons
        ,ROUND(
           SUM(CASE WHEN pl.passed_or_not_passed = 'Passed' THEN 1.0 ELSE 0.0 END) 
             / CAST(COUNT(pl.lesson_id) AS FLOAT)
          ,2) AS pct_passed
  FROM gabby.iready.personalized_instruction_by_lesson pl
  WHERE pl.completion_date IN (SELECT [date] FROM current_week)
  GROUP BY pl.student_id
          ,pl.[subject]
 )

SELECT co.student_number
      ,co.state_studentnumber AS mdcps_id
      ,co.lastfirst
      ,co.grade_level
      ,co.schoolid
      ,co.school_name
      ,co.is_retained_year
      ,co.year_in_network
      ,co.gender
      ,co.ethnicity
      ,co.iep_status
      ,co.lep_status

      ,suf.fleid

      ,subjects.[value] AS iready_subject
      ,CASE WHEN subjects.[value] = 'Reading' THEN 'ELA' ELSE subjects.[value] END AS fsa_subject

      ,fsp.fsa_year
      ,fsp.fsa_grade
      ,fsp.fsa_level
      ,CASE WHEN fsp.fsa_scale_s <> '' THEN fsp.fsa_scale_s END AS fsa_scale
      ,CASE 
        WHEN fsa_scale_s = '' THEN NULL
        WHEN fsa_scale_s IS NULL THEN NULL
        ELSE CAST(
               RANK() OVER(
                 PARTITION BY fsp.fsa_grade, subjects.[value]
                   ORDER BY CASE WHEN fsp.fsa_scale_s = '' THEN 1 WHEN fsp.fsa_scale_s IS NULL THEN 1 ELSE 0 END, fsp.fsa_scale_s ASC) 
              AS FLOAT)
       END
       /
       CASE WHEN fsa_scale_s = '' THEN NULL
            WHEN fsa_scale_s IS NULL THEN NULL
         ELSE CAST(COUNT(*) OVER (PARTITION BY fsp.fsa_grade, subjects.[value] ORDER BY CASE WHEN fsp.fsa_scale_s = '' THEN 1 WHEN fsp.fsa_scale_s IS NULL THEN 1 ELSE 0 END) AS float) END AS fl_fsa_percentile

      ,di.diagnostic_overall_scale_score_most_recent_
      ,di.diagnostic_completion_date_most_recent_
      ,di.diagnostic_overall_relative_placement_most_recent_
      ,di.diagnostic_percentile_most_recent_
      ,di.[subject]
      ,COALESCE(di.diagnostic_overall_scale_score_1_, di.diagnostic_overall_scale_score_most_recent_) AS iready_scale_boy
      ,di.annual_stretch_growth_measure
      ,di.annual_typical_growth_measure
      ,di.diagnostic_gain_note_negative_gains_zero_

      ,ir.total_lessons
      ,ir.lessons_passed
      ,ir.pct_passed

      ,cw1.sublevel_name AS fsa_sublevel_name
      ,cw1.sublevel_number AS fsa_sublevel_number
      ,cw2.sublevel_name AS iready_sublevel_predict_name
      ,cw2.sublevel_number AS iready_sublevel_predict_number
      ,cw3.scale_low AS predicted_proficiency_scale
      ,cw6.scale_low AS predicted_growth_scale
      ,cw4.scale_low AS fsa_scale_for_growth
      ,cw5.scale_low AS fsa_scale_for_proficiency

      ,ce.course_number
      ,ce.course_name
      ,ce.teacher_name

FROM kippmiami.powerschool.cohort_identifiers_static co
LEFT JOIN kippmiami.powerschool.u_studentsuserfields suf
  ON co.students_dcid = suf.studentsdcid
CROSS JOIN STRING_SPLIT ('Reading,Math', ',') subjects
LEFT JOIN kippmiami.fsa.student_scores_previous fsp
  ON co.state_studentnumber = fsp.student_id
 AND co.academic_year = fsp.fsa_year
 AND subjects.[value] = CASE
                         WHEN fsp._file LIKE '%Math%' THEN 'Math'
                         WHEN fsp._file LIKE '%ELA%' THEN 'Reading'
                        END
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw1
  ON cw1.test_name = CASE
                      WHEN fsp.fsa_scale_s IS NULL THEN NULL
                      WHEN fsp._file LIKE '%Math%' THEN CONCAT('MATH', ' ', fsp.fsa_grade)
                      WHEN fsp._file LIKE '%ELA%' THEN CONCAT('ELA', ' ', fsp.fsa_grade)
                     END
 AND fsp.fsa_scale_s BETWEEN cw1.scale_low AND cw1.scale_high
 AND cw1.source_system = 'FSA'
LEFT JOIN gabby.iready.diagnostic_and_instruction di
  ON di.student_id = co.student_number
 AND LEFT(di.academic_year, 4) = co.academic_year
 AND di.[subject] = subjects.[value]
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw2
  ON co.grade_level = cw2.grade_level
 AND di.[subject] = cw2.test_name
 AND di.diagnostic_overall_scale_score_most_recent_ BETWEEN cw2.scale_low AND cw2.scale_high
 AND cw2.source_system = 'i-Ready'
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw3
  ON co.grade_level = cw3.grade_level
 AND di.[subject] = cw3.test_name
 AND cw3.source_system = 'i-Ready'
 AND cw3.sublevel_name = 'Level 3'
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw4
  ON cw4.test_name = CONCAT(CASE WHEN subjects.[value] = 'Reading' THEN 'ELA' ELSE subjects.[value] END, ' ', co.grade_level)
 AND (cw1.sublevel_number + 1) = cw4.sublevel_number
 AND cw4.source_system = 'FSA'
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw5
  ON cw5.test_name = CONCAT(CASE WHEN subjects.[value] = 'Reading' THEN 'ELA' ELSE subjects.[value] END, ' ', co.grade_level)
 AND cw5.sublevel_name = 'Level 3'
 AND cw5.source_system = 'FSA'
LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw6
  ON cw6.test_name = subjects.[value]
 AND cw1.sublevel_number + 1 = cw6.sublevel_number
 AND cw6.grade_level = co.grade_level
 AND cw6.source_system = 'i-Ready'
LEFT JOIN kippmiami.powerschool.course_enrollments_current_static ce
  ON ce.student_number = co.student_number
 AND ce.credittype = CASE
                      WHEN subjects.[value] = 'Reading' THEN 'ENG'
                      WHEN subjects.[value] = 'Math' THEN 'MATH'
                     END
 AND ce.section_enroll_status = 0
 AND ce.rn_subject = 1
LEFT JOIN iready_lessons ir
  ON co.student_number = ir.student_id
 AND subjects.[value] = ir.[subject]
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.grade_level >= 3
