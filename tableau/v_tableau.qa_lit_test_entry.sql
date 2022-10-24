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

      ,CAST(achv.test_round AS VARCHAR(2)) AS lit_term
      ,achv.is_curterm

      ,COALESCE(testid.read_lvl, achv.read_lvl) AS read_lvl
      ,COALESCE(testid.lvl_num, achv.lvl_num) AS lvl_num
      ,COALESCE(testid.test_date, CASE WHEN achv.read_lvl IS NOT NULL THEN achv.end_date END) AS test_date
      ,COALESCE(testid.[status], CASE WHEN achv.read_lvl IS NOT NULL THEN 'Achieved' END) AS [status]
      ,COALESCE(testid.is_fp, CASE WHEN achv.read_lvl IS NOT NULL THEN 1 END) AS is_fp

      ,gr.gr_teacher

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, achv.test_round, testid.[status]
           ORDER BY testid.lvl_num DESC) AS rn_test_term
FROM gabby.powerschool.cohort_identifiers_static co
INNER JOIN gabby.lit.achieved_by_round_static achv
  ON co.student_number = achv.student_number
 AND co.academic_year = achv.academic_year
LEFT JOIN gabby.lit.all_test_events_static testid
  ON co.student_number = testid.student_number
 AND co.academic_year = testid.academic_year
 AND testid.test_date BETWEEN achv.[start_date] AND achv.end_date
LEFT JOIN gabby.lit.guided_reading_roster gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND achv.test_round = gr.test_round
WHERE co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.enroll_status = 0
  AND co.grade_level <= 4
