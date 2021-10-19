USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_lit_test_entry AS

SELECT co.student_number
      ,co.lastfirst AS student_name
      ,co.academic_year
      ,co.region
      ,co.school_name
      ,co.grade_level
      ,co.school_level
      ,co.boy_status
      ,co.team
      ,co.iep_status
      ,co.lep_status

      ,CONVERT(VARCHAR(5),term.alt_name) AS lit_term
      ,term.is_curterm

      ,testid.read_lvl
      ,testid.lvl_num
      ,testid.test_date
      ,testid.[status]
      ,testid.is_fp

      ,gr.gr_teacher

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, term.time_per_name, testid.[status]
           ORDER BY testid.lvl_num DESC) AS rn_test_term
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.reporting.reporting_terms term
  ON co.schoolid = term.schoolid
 AND co.academic_year = term.academic_year
 AND term.identifier = 'LIT' 
 AND term._fivetran_deleted = 0
LEFT JOIN gabby.lit.all_test_events_static testid
  ON co.student_number = testid.student_number
 AND co.academic_year = testid.academic_year
 AND testid.test_date BETWEEN term.[start_date] AND term.end_date
LEFT JOIN gabby.lit.guided_reading_roster gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND term.alt_name = gr.test_round
WHERE co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.enroll_status = 0
  AND co.grade_level < 8
