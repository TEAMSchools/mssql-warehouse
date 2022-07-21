USE gabby
GO

CREATE OR ALTER VIEW tableau.school_health AS

WITH act_composite AS (
  SELECT stl.contact_c
        ,CASE WHEN MAX(stl.score) >= 20 THEN 1 ELSE 0 END AS is_act_20

        ,ktc.school_specific_id_c AS student_number
  FROM gabby.alumni.standardized_test_long stl
  INNER JOIN gabby.alumni.contact ktc
    ON stl.contact_c = ktc.id
  WHERE stl.test_type = 'ACT'
    AND stl.score_type = 'act_composite_c'
  GROUP BY stl.contact_c, ktc.school_specific_id_c
 )

,iready AS (
  SELECT co.academic_year
        ,co.schoolid
        ,co.iep_status
        ,co.gender

        ,CASE WHEN gm.progress_typical >= 1 THEN 1 ELSE 0 END AS is_typ_growth
        ,CASE WHEN gm.progress_stretch >= 1 THEN 1 ELSE 0 END AS is_str_growth
        ,LOWER(LEFT(gm.[subject], 4)) COLLATE Latin1_General_BIN AS iready_subject

        ,'ALL' AS grade_band
  FROM gabby.powerschool.cohort_identifiers_static co
  INNER JOIN gabby.iready.growth_metrics gm
    ON co.student_number = gm.student_number
   AND co.academic_year = gm.academic_year
  WHERE co.rn_year = 1
    AND co.is_enrolled_recent = 1
    AND co.grade_level <= 8
    AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
 )

SELECT 'f_and_p' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_on_level AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_on_level AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_on_level AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_on_level AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_on_level AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM
    (
     SELECT ats.academic_year
           ,ats.schoolid
           ,CAST(ats.grade_level AS NVARCHAR(2)) AS grade_band
           ,CASE 
             WHEN ats.grade_level = 0 AND ats.indep_lvl_num > 4 THEN 1
             WHEN ats.grade_level = 1 AND ats.indep_lvl_num > 9 THEN 1
             WHEN ats.grade_level = 2 AND ats.indep_lvl_num > 13 THEN 1
             WHEN ats.grade_level = 3 AND ats.indep_lvl_num > 16 THEN 1
             WHEN ats.grade_level = 4 AND ats.indep_lvl_num > 19 THEN 1
             ELSE 0
            END AS is_on_level

           ,co.iep_status
           ,co.gender
     FROM gabby.lit.achieved_by_round_static ats
     LEFT JOIN gabby.powerschool.cohort_identifiers_static co
       ON ats.student_number = co.student_number
      AND ats.academic_year = co.academic_year
      AND co.is_enrolled_recent = 1
     WHERE ats.academic_year >= gabby.utilities.global_academic_year() - 2
       AND ats.is_curterm = 1
       AND ats.grade_level <= 4
    ) sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION ALL

SELECT LOWER(grade_band) + '_gpa' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.pct_met_goal AS FLOAT)),2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.pct_met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.pct_met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.pct_met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.pct_met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM
    (
     SELECT gpa.academic_year
           ,gpa.schoolid
           ,CASE WHEN gpa.gpa_y1 >= 3 THEN 1 ELSE 0 END AS pct_met_goal

           ,co.iep_status
           ,co.gender
           ,co.school_level AS grade_band
     FROM gabby.powerschool.gpa_detail gpa
     INNER JOIN gabby.powerschool.cohort_identifiers_static co
       ON gpa.student_number = co.student_number
      AND gpa.academic_year = co.academic_year
      AND co.is_enrolled_recent = 1
      AND co.rn_year = 1
     WHERE gpa.is_curterm = 1
       AND gpa.academic_year >= gabby.utilities.global_academic_year() - 2
       AND gpa.grade_level >= 5
    )sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION ALL

SELECT 'i-ready_typical_' + sub.iready_subject AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_typ_growth AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_typ_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_typ_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_typ_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_typ_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM iready sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band
        ,sub.iready_subject

UNION ALL

SELECT 'i-ready_stretch_math' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_str_growth AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_str_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_str_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_str_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_str_growth AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM iready sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION ALL

SELECT 'i-ready_on_grade_' + sub.iready_subject AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_on_grade AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_on_grade AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_on_grade AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_on_grade AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_on_grade AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM
    (
     SELECT co.academic_year
           ,co.schoolid
           ,co.iep_status
           ,co.gender
           ,CAST(co.grade_level AS NVARCHAR(2)) AS grade_band

           ,di.diagnostic_overall_relative_placement_most_recent_
           ,LOWER(LEFT(di.[subject], 4)) AS iready_subject
           ,CASE 
             WHEN di.diagnostic_overall_relative_placement_most_recent_ IN ('On Level', 'Above Level') THEN 1 
             ELSE 0 
            END AS is_on_grade
     FROM gabby.powerschool.cohort_identifiers_static co
     INNER JOIN gabby.iready.diagnostic_and_instruction di
       ON co.student_number = di.student_id
      AND co.academic_year = LEFT(di.academic_year, 4)
     WHERE co.rn_year = 1
       AND co.is_enrolled_recent = 1
       AND co.grade_level <= 2
       AND co.academic_year >= gabby.utilities.global_academic_year() - 2
    ) sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band
        ,sub.iready_subject

UNION ALL

SELECT 'ada' AS domain
      ,co.academic_year
      ,co.schoolid
      ,'ALL' AS grade_band      
      ,ROUND(AVG(CONVERT(FLOAT, mem.attendancevalue)), 3) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN co.iep_status = 'SPED' THEN CAST(mem.attendancevalue AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN co.iep_status <> 'SPED' THEN CAST(mem.attendancevalue AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN co.gender = 'F' THEN CAST(mem.attendancevalue AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN co.gender = 'M' THEN CAST(mem.attendancevalue AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM gabby.powerschool.ps_adaadm_daily_ctod mem
INNER JOIN gabby.powerschool.cohort_identifiers_static co
  ON mem.studentid = co.studentid
 AND mem.yearid = co.yearid
 AND mem.[db_name] = co.[db_name]
 AND co.rn_year = 1
 AND co.is_enrolled_y1 = 1
WHERE mem.membershipvalue = 1
  AND mem.calendardate <= GETDATE()
  AND mem.yearid >= ((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2) - 1990)
GROUP BY co.academic_year
        ,co.schoolid

UNION ALL

SELECT 'suspension' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_suspended AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_suspended AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_suspended AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_suspended AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_suspended AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM
    (
     SELECT co.academic_year
           ,co.schoolid
           ,co.iep_status
           ,co.gender

           ,CASE 
             WHEN ips.issuspension IS NULL THEN 0
             ELSE ips.issuspension 
            END AS is_suspended

           ,'ALL' AS grade_band
     FROM gabby.powerschool.cohort_identifiers_static co
     LEFT JOIN gabby.deanslist.incidents_clean_static ics
       ON co.student_number = ics.student_school_id
      AND co.academic_year = ics.create_academic_year
      AND co.[db_name] = ics.[db_name]
     LEFT JOIN gabby.deanslist.incidents_penalties_static ips
       ON ips.incident_id = ics.incident_id
      AND ips.[db_name] = ics.[db_name]
      AND ips.issuspension = 1
     WHERE co.rn_year = 1
       AND co.is_enrolled_y1 = 1
       AND co.academic_year >= gabby.utilities.global_academic_year() - 2
    ) sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION ALL

SELECT 'act' AS domain
      ,co.academic_year
      ,co.schoolid
      ,CAST(co.grade_level AS NVARCHAR(2)) AS grade_band

      ,ROUND(AVG(CAST(act.is_act_20 AS FLOAT)), 2) AS pct_met_goal

      ,ROUND(AVG(CASE WHEN co.iep_status = 'SPED' THEN CAST(act.is_act_20 AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN co.iep_status <> 'SPED' THEN CAST(act.is_act_20 AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN co.gender = 'F' THEN CAST(act.is_act_20 AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN co.gender = 'M' THEN CAST(act.is_act_20 AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN act_composite act
  ON co.student_number = act.student_number
WHERE co.rn_year = 1
  AND co.is_enrolled_y1 = 1
  AND co.grade_level IN (11, 12)
  AND co.academic_year >= gabby.utilities.global_academic_year() - 2
GROUP BY co.academic_year
        ,co.schoolid
        ,co.grade_level

UNION ALL

SELECT 'njsla_' + sub.njsla_subject AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_proficient AS FLOAT)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_m
FROM
    (
     SELECT  co.academic_year
            ,co.schoolid
            ,co.iep_status
            ,co.gender
            ,CAST(co.grade_level AS NVARCHAR(2)) AS grade_band

            ,CASE 
              WHEN nj.[subject] IN ('Mathematics', 'Algebra I') THEN 'math'
              WHEN nj.[subject] = 'English Language Arts/Literacy' THEN 'ela'
             END AS njsla_subject
            ,CASE WHEN nj.test_performance_level >= 3 THEN 1 ELSE 0 END AS is_proficient
     FROM gabby.parcc.summative_record_file_clean nj
     INNER JOIN gabby.powerschool.cohort_identifiers_static co
       ON nj.local_student_identifier = co.student_number
      AND nj.academic_year = co.academic_year
      AND co.grade_level <= 8
      AND co.rn_year = 1
     WHERE nj.academic_year >= gabby.utilities.global_academic_year() - 2
       AND nj.[subject] IN ('Mathematics', 'Algebra I', 'English Language Arts/Literacy')
    )sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band
        ,sub.njsla_subject

UNION ALL

SELECT 'student_attrition' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(1 - ROUND(AVG(CAST(sub.is_enrolled_next AS FLOAT)), 2), 2) AS pct_met_goal
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_enrolled_next AS FLOAT) ELSE NULL END), 2), 2) AS pct_met_iep
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_enrolled_next AS FLOAT) ELSE NULL END), 2), 2) AS pct_met_no_iep
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_enrolled_next AS FLOAT) ELSE NULL END), 2), 2) AS pct_met_f
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_enrolled_next AS FLOAT) ELSE NULL END), 2), 2) AS pct_met_m
FROM
    (
     SELECT co.schoolid
           ,co.academic_year
           ,co.iep_status
           ,co.gender
           ,CASE 
             WHEN co.exitcode = 'G1' THEN NULL
             WHEN co.exitcode IS NULL THEN NULL
             ELSE LEAD(co.is_enrolled_oct01, 1, 0) OVER(PARTITION BY co.student_number ORDER BY co.academic_year)
            END AS is_enrolled_next

           ,'All' AS grade_band
     FROM gabby.powerschool.cohort_identifiers_static co
     WHERE co.is_enrolled_oct01 = 1
       AND co.rn_year = 1
       AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
    ) sub
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION ALL

SELECT 'q12' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,'ALL' AS grade_band
      ,ROUND(AVG(CAST(sub.avg_response AS FLOAT)), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM
    (
     SELECT cm.campaign_academic_year AS academic_year
           ,cm.respondent_df_employee_number
           ,CASE WHEN ROUND(AVG(CAST(cm.answer_value AS FLOAT)), 2) >= 4 THEN 1 ELSE 0 END AS avg_response

           ,sc.ps_school_id AS schoolid
     FROM gabby.surveys.cmo_engagement_regional_survey_detail cm
     INNER JOIN gabby.people.school_crosswalk sc
       ON cm.respondent_primary_site = sc.site_name
      AND sc.ps_school_id <> 0
      AND sc.ps_school_id IS NOT NULL
     WHERE cm.is_open_ended = 'N'
       AND cm.question_shortname LIKE '%Q12%'
       AND cm.campaign_academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
     GROUP BY sc.ps_school_id
             ,cm.campaign_academic_year
             ,cm.respondent_df_employee_number
    ) sub
GROUP BY sub.academic_year
        ,sub.schoolid

UNION ALL

SELECT 'staff_retention' AS domain
      ,sa.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(1 - SUM(sa.is_attrition) / CAST(SUM(sa.is_denominator) AS FLOAT), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM gabby.tableau.compliance_staff_attrition sa
INNER JOIN gabby.people.school_crosswalk cw
  ON sa.primary_site = cw.site_name
 AND cw.ps_school_id <> 0
WHERE sa.is_denominator <> 0
  AND sa.primary_job <> 'Intern'
  AND sa.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3)
GROUP BY sa.academic_year, cw.ps_school_id
​
UNION ALL
​
SELECT 'teacher_retention' AS domain
      ,sa.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(1 - SUM(sa.is_attrition) / CAST(SUM(sa.is_denominator) AS FLOAT), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM gabby.tableau.compliance_staff_attrition sa
INNER JOIN gabby.people.school_crosswalk cw
  ON sa.primary_site = cw.site_name
 AND cw.ps_school_id <> 0
WHERE sa.primary_job IN (
        'Co-Teacher', 'Co-Teacher_HISTORICAL', 'Learning Specialist', 'Learning Specialist Coordinator'
       ,'Teacher', 'Teacher ESL', 'Teacher Fellow', 'Teacher in Residence', 'Teacher, ESL'
       ,'Temporary Teacher'
      )
  AND sa.is_denominator <> 0
  AND sa.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3)
GROUP BY sa.academic_year, cw.ps_school_id

UNION ALL

SELECT 'etr_average' AS domain
      ,lb.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(AVG(CASE WHEN metric_value >= 3 THEN 1.0 ELSE 0 END), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM gabby.pm.teacher_goals_lockbox_wide lb
INNER JOIN gabby.people.employment_history_static eh
  ON lb.df_employee_number = eh.employee_number
 AND DATEFROMPARTS(lb.academic_year + 1, 4, 30) BETWEEN eh.effective_start_date AND eh.effective_end_date
 AND eh.primary_position = 'Yes'
INNER JOIN gabby.people.school_crosswalk cw
  ON eh.[location] = cw.site_name
 AND cw.ps_school_id <> 0
WHERE lb.metric_name = 'etr_overall_score'
  AND lb.pm_term = 'PM4'
  AND lb.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
GROUP BY lb.academic_year, cw.ps_school_id
