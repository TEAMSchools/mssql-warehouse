USE gabby
GO

CREATE OR ALTER VIEW tableau.school_health AS

WITH act_composite AS (
  SELECT stl.contact_c
        ,CASE WHEN MAX(stl.score) >= 16 THEN 1 ELSE 0 END AS is_act_16
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
    AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
)

SELECT sub.subdomain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,sub.pct_met_goal
      ,sub.pct_met_iep
      ,sub.pct_met_f
      ,sub.pct_met_m

      ,ml.metric_type
      ,ml.domain
      ,ml.metric_description
      ,ml.metric_average
      ,ml.level_1
      ,ml.level_2
      ,ml.level_3
      ,ml.level_4
      ,ml.[absolute]
      ,CASE WHEN ml.metric_type = 'greater' AND sub.pct_met_goal >= ml.level_4 THEN 4 
            WHEN ml.metric_type = 'greater' AND sub.pct_met_goal >= ml.level_3 THEN 3 
            WHEN ml.metric_type = 'greater' AND sub.pct_met_goal >= ml.level_2 THEN 2
            WHEN ml.metric_type = 'greater' AND sub.pct_met_goal < ml.level_2 THEN 1
            WHEN ml.metric_type = 'less' AND sub.pct_met_goal > ml.level_2 THEN 1 
            WHEN ml.metric_type = 'less' AND sub.pct_met_goal <= ml.level_3 THEN 2 
            WHEN ml.metric_type = 'less' AND sub.pct_met_goal <= ml.level_2 THEN 3
            WHEN ml.metric_type = 'less' AND sub.pct_met_goal <= ml.level_2 THEN 4
         ELSE NULL END AS subdomain_score
       ,ROUND(ml.[absolute] - sub.pct_met_goal, 2) AS diff_from_absolute
FROM
 (
 SELECT 'f_and_p' AS subdomain
       ,sub.academic_year
       ,sub.schoolid
       ,sub.grade_band
       ,ROUND(AVG(CAST(sub.met_goal AS FLOAT)), 2) AS pct_met_goal
       ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
       ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
       ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_f
       ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_m
 FROM
     (
      SELECT ats.academic_year
            ,ats.schoolid
            ,CAST(ats.grade_level AS NVARCHAR(2)) AS grade_band
            ,ats.met_goal
 
            ,co.iep_status
            ,co.gender
      FROM gabby.lit.achieved_by_round_static ats
      LEFT JOIN gabby.powerschool.cohort_identifiers_static co
        ON ats.student_number = co.student_number
       AND ats.academic_year = co.academic_year
       AND co.is_enrolled_recent = 1
      WHERE ats.academic_year >= gabby.utilities.global_academic_year() - 3
        AND ats.is_curterm = 1
        AND ats.grade_level <= 4
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
 
 UNION ALL
 
 SELECT LOWER(grade_band) + '_gpa' AS subdomain
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
        AND gpa.academic_year >= gabby.utilities.global_academic_year() - 3
        AND gpa.grade_level >= 5
        AND co.school_level NOT IN ('OD', 'ES')
     )sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
 
 UNION ALL
 
 SELECT 'i-ready_typical_' + sub.iready_subject AS subdomain
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
 
 SELECT 'i-ready_stretch_math' AS subdomain
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
 
 SELECT 'i-ready_on_grade_' + sub.iready_subject AS subdomain
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
        AND co.academic_year >= gabby.utilities.global_academic_year() - 3
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
         ,sub.iready_subject
 
 UNION ALL
 
 SELECT 'ada' AS subdomain
       ,co.academic_year
       ,co.schoolid
       ,'ALL' AS grade_band      
       ,ROUND(AVG(CAST(mem.attendancevalue AS FLOAT)), 3) AS pct_met_goal
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
   AND mem.calendardate <= CURRENT_TIMESTAMP
   AND mem.yearid >= ((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3) - 1990)
 GROUP BY co.academic_year
         ,co.schoolid
 
 UNION ALL
 
 SELECT 'suspension' AS subdomain
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
        AND co.academic_year >= gabby.utilities.global_academic_year() - 3
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
 
 UNION ALL
 
 SELECT 'act' AS subdomain
       ,co.academic_year
       ,co.schoolid
       ,CAST(co.grade_level AS NVARCHAR(2)) AS grade_band
 
       ,ROUND(AVG(CAST(act.is_act_16 AS FLOAT)), 2) AS pct_met_goal
 
       ,ROUND(AVG(CASE WHEN co.iep_status = 'SPED' THEN CAST(act.is_act_16 AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
       ,ROUND(AVG(CASE WHEN co.iep_status <> 'SPED' THEN CAST(act.is_act_16 AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
       ,ROUND(AVG(CASE WHEN co.gender = 'F' THEN CAST(act.is_act_16 AS FLOAT) ELSE NULL END), 2) AS pct_met_f
       ,ROUND(AVG(CASE WHEN co.gender = 'M' THEN CAST(act.is_act_16 AS FLOAT) ELSE NULL END), 2) AS pct_met_m
 FROM gabby.powerschool.cohort_identifiers_static co
 LEFT JOIN act_composite act
   ON co.student_number = act.student_number
 WHERE co.rn_year = 1
   AND co.is_enrolled_y1 = 1
   AND co.grade_level IN (11, 12)
   AND co.academic_year >= gabby.utilities.global_academic_year() - 3
 GROUP BY co.academic_year
         ,co.schoolid
         ,co.grade_level
 
 UNION ALL
 
 
 SELECT 'student_attrition' AS subdomain
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
 
            ,'ALL' AS grade_band
      FROM gabby.powerschool.cohort_identifiers_static co
      WHERE co.is_enrolled_oct01 = 1
        AND co.rn_year = 1
        AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
 
 UNION ALL
 
 SELECT 'q12' AS subdomain
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
        AND cm.campaign_academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
      GROUP BY sc.ps_school_id
              ,cm.campaign_academic_year
              ,cm.respondent_df_employee_number
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
 
 UNION ALL
 
 SELECT 'staff_retention' AS subdomain
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
 
 UNION ALL
 
 SELECT 'teacher_retention' AS subdomain
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
 
 SELECT 'etr_average' AS subdomain
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
   AND lb.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
 GROUP BY lb.academic_year, cw.ps_school_id
 
 UNION ALL
 
 SELECT 'scds_student' AS subdomain
       ,sub.academic_year
       ,sub.schoolid
       ,'ALL' AS grade_band
       ,ROUND(AVG(CAST(sub.met_goal AS FLOAT)), 2) AS pct_met_goal
     ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
     ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
     ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_f
     ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.met_goal AS FLOAT) ELSE NULL END), 2) AS pct_met_m
 FROM
  (
  SELECT academic_year
        ,student_number
        ,schoolid
        ,grade_level
        ,iep_status
        ,gender
        ,'ALL' AS grade_band
        ,CASE WHEN AVG(CAST(sub.response_value AS FLOAT)) >= 3.00 THEN 1 ELSE 0 END AS met_goal

  FROM
      (
       SELECT email_address
             ,CASE 
               WHEN u.response IN (
                 'School will help students get into a “good” college so they can get a “good” job and make lots of money.'
                ,'Staff frequently call students out publicly, use an angry tone with, or even yell at students.'
                ,'Staff make all the decisions - students are not involved.'
                ,'Staff often assign detentions and/or remove students from activities/classroom for even minor issues – OR staff ignore student behavior completely.'
                ,'Students are rarely ever allowed to talk or move without staff’s permission or presence.'
                ,'Students must show they can listen and do whatever staff say before being included in activities, like recess, trips, choice time, etc.'
                ,'Students’ performance is only measured by the grades they are getting on tests/quizzes.'
                ,'Teachers do not often communicate with families at my school.  Families are not sure who to go to when they want to learn more, have a concern, or need help.'
                ,'Teachers generally do not provide enough individualized support to students.  Students who don’t get the right answer are often left unsure about how to fix their work.'
                ,'The lessons, books, and learning resources used at my school that don''t value diversity and inclusion. Students often feel like they cannot relate to what they are learning about.'
               ) THEN 1
               WHEN u.response IN (
                 'Families and teachers at my school communicate when they need to.  Families ask questions and/or share concerns, and generally feel supported when they do.'
                ,'School will help students go to college OR have a career so they can be “successful” doing whatever they want.'
                ,'Some of the lessons, books, and learning resources used at my school show different cultures through photographs and stories. Many students are able to relate to what they are learning about.'
                ,'Staff don’t really listen to students and talk to them without much joy or excitement.'
                ,'Staff sometimes ask students questions to help them make decisions, but don’t always listen.'
                ,'Staff use the same consequences to address ALL levels of behavior without first working to understand the students or what happened.'
                ,'Students are expected to focus mostly on being respectful, follow directions immediately, and rarely question teachers.'
                ,'Students must perform and behave well to be included in activities.'
                ,'Students’ performance is measured both by the grades they are getting on tests/quizzes; as well as how much growth they are showing.'
                ,'Teachers plan lessons and use class time similarly each day.  Teachers are clear on which students’ work meets the expectations, and which students'' work do not.'
               ) THEN 2
               WHEN u.response IN (
                 'Families and teachers at my school communicate often about progress, concerns, and updates.  Many families know how to be and are actively involved with student and school-wide events.'
                ,'School will help students learn a lot and believe in themselves so they can live a life they choose.'
                ,'Staff always listen to and treat students with kindness.'
                ,'Staff regularly ask students questions to help them make decisions and listen to what they share.'
                ,'Staff work to understand students before issuing consequences – when consequences are given, they are fair.'
                ,'Students are welcomed to be themselves and bring their full personality to school.'
                ,'Students must show effort and growth to be included in activities.'
                ,'Students’ performance is measured through both what grades they are getting and how they are growing. Teachers often meet with students to discuss growth goals and to track progress.'
                ,'Teachers create an environment where most students actively participate, and take academic risks to strengthen their own learning.  Teachers find many different and creative ways to make learning engaging for most students.'
                ,'The lessons, books, and learning resources used at my school have a diverse representation of cultures and perspectives. Students are able to produce work that reflects and connects their own ideas, thoughts, and opinions.'
               ) THEN 3
               WHEN u.response IN (
                 'ALL students are encouraged to participate in any activity they like based on what they enjoy and care about.'
                ,'Families and teachers at my school communicate frequently and openly about progress, concerns, and updates.  Families are active members of the school community.'
                ,'School will help students learn a lot, believe in themselves, and understand what it means to be a Person of Color in America – so they can live a life they choose, no matter what challenges they may face.'
                ,'Staff care deeply about every student; staff share their personality and take time to relate to and learn about each student.'
                ,'Staff rely mostly on relationships to address student behavior, rarely ever send a student out of class, and take time to make all students feel heard and valued.'
                ,'Students are partners with staff and always part of decisions for the school.'
                ,'Students are welcomed to be themselves, bring their full personalities AND family culture, and engage with staff about academic and non-academic topics.'
                ,'Students’ performance includes grades earned on tests/quizzes, as well as academic and social goals.  Teachers and students work together to set, communicate, and celebrate all goals.'
                ,'Teachers are committed to challenging and helping all students learn.  Teachers create an environment where all students are included and can thrive.'
                ,'The lessons, books, and learning resources used by students support the development of who they are as people. Students routinely engage in exploring their own and other cultures, and understand the purpose of what they are learning.'
               ) THEN 4
               ELSE NULL 
              END AS response_value
             ,iep_status
             ,gender
             ,academic_year
             ,schoolid
             ,grade_level
             ,student_number
        FROM gabby.surveys.scds sc
        INNER JOIN gabby.powerschool.cohort_identifiers_static co
           ON LEFT(sc.email_address, LEN(sc.email_address) - 17) = co.student_web_id COLLATE Latin1_General_BIN
          AND co.academic_year = 2021
          AND co.rn_year = 1
        UNPIVOT(
          response
          FOR question_text IN (
                _1_what_best_describes_expectations_for_students_at_your_school_
               ,_2_what_best_describes_the_interactions_between_staff_and_students_
               ,_3_what_best_describes_how_staff_respond_to_student_behavior_
               ,_4_what_best_describes_how_school_handles_activities_for_students_
               ,_5_what_best_describes_how_much_input_students_have_on_school_decisions_
               ,_6_what_best_describes_what_students_are_taught_about_why_school_is_important_
               ,_7_what_best_describes_learning_outcomes_for_students_at_your_school_
               ,_8_what_best_describes_teachers_instructional_practices_at_your_school_
               ,_9_what_best_describes_the_lessons_and_learning_resources_at_your_school_
               ,_10_what_best_describes_family_engagement_at_your_school_
              )
        ) u
      )sub
  GROUP BY sub.academic_year, sub.student_number, sub.schoolid, sub.grade_level, sub.iep_status ,sub.gender
 ) sub
 GROUP BY sub.academic_year ,sub.schoolid
 
 UNION ALL
 
 SELECT 'state_asmt' + '_' + sub.[subject] AS subdomain
       ,sub.academic_year
       ,sub.schoolid
       ,CAST(sub.grade_band AS NVARCHAR) AS grade_band
       ,ROUND(AVG(CAST(sub.is_proficient AS FLOAT)), 2) AS pct_met_goal
       ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_iep
       ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_no_iep
       ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_f
       ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_proficient AS FLOAT) ELSE NULL END), 2) AS pct_met_m
 FROM
     (
      SELECT co.academic_year
            ,co.schoolid
            ,co.grade_level AS grade_band
            ,co.iep_status
            ,co.gender
            ,CASE 
              WHEN nj.[subject] IN ('Mathematics', 'Algebra I') THEN 'math'
              WHEN nj.[subject] LIKE 'English Language%' THEN 'ela'
              ELSE LOWER(nj.[subject])
             END AS [subject]
            ,CASE
              WHEN nj.[subject] = 'Science' AND nj.test_performance_level >= 3 THEN 1
              WHEN nj.[subject] = 'Science' AND nj.test_performance_level < 3 THEN 0
              WHEN nj.test_performance_level >= 4 THEN 1
              WHEN nj.test_performance_level < 4 THEN 0
             END AS is_proficient
      FROM gabby.parcc.summative_record_file_clean nj
      INNER JOIN gabby.powerschool.cohort_identifiers_static co
        ON nj.state_student_identifier = co.state_studentnumber
       AND nj.academic_year = co.academic_year
       AND nj.[db_name] = co.[db_name]
       AND co.rn_year = 1
       AND co.grade_level BETWEEN 3 AND 8
       AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
 
      UNION ALL
 
      SELECT co.academic_year
            ,co.schoolid
            ,co.grade_level AS grade_band
            ,co.iep_status
            ,co.gender
            ,CASE 
              WHEN fl.test_name LIKE '%MATH%' THEN 'math'
              WHEN fl.test_name LIKE '%ELA%' THEN 'ela'
              WHEN fl.test_name LIKE '%SCIENCE%' THEN 'science'
              ELSE NULL
             END AS [subject]
           ,CASE
             WHEN fl.performance_level >= 3 THEN 1
             WHEN fl.performance_level < 3 THEN 0
             ELSE NULL
            END AS is_proficient
      FROM kippmiami.fsa.student_scores fl
      INNER JOIN kippmiami.powerschool.u_studentsuserfields suf
        ON fl.fleid = suf.fleid
      INNER JOIN kippmiami.powerschool.cohort_identifiers_static co
        ON suf.studentsdcid = co.students_dcid
       AND LEFT(fl.school_year, 2) = RIGHT(co.academic_year, 2)
       AND co.rn_year = 1
       AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3
       AND co.grade_level BETWEEN 3 AND 8
     ) sub
 GROUP BY sub.academic_year
         ,sub.schoolid
         ,sub.grade_band
         ,sub.[subject]
 ) sub
LEFT JOIN gabby.reporting.school_health_metric_lookup ml
  ON sub.subdomain = ml.subdomain
 AND sub.grade_band = ml.grade_band COLLATE Latin1_General_BIN
