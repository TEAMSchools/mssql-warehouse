CREATE OR ALTER VIEW powerschool.final_grades AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid
        ,co.academic_year
        ,co.schoolid
        ,co.grade_level

        ,css.term_name
        ,css.is_curterm
        ,css.course_number
        ,css.sectionid
        ,css.excludefromgpa
        ,css.course_name
        ,css.credittype
        ,css.credit_hours
        ,CONCAT('RT', RIGHT(css.term_name, 1)) AS reporting_term

        ,t.lastfirst AS teacher_name

        ,css.gradescaleid
  FROM powerschool.cohort_identifiers_static co
  JOIN powerschool.course_section_scaffold css
    ON co.student_number = css.student_number
   AND co.yearid = css.yearid
   AND css.course_number <> 'ALL'
  JOIN powerschool.sections sec
    ON css.sectionid = sec.id
  JOIN powerschool.teachers_static t
    ON sec.teacher = t.id
  WHERE co.rn_year = 1
    AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 )

,enr_grades AS (
  SELECT studentid
        ,academic_year
        ,course_number
        ,term_name
        ,term_gpa_points

        /* if stored grade exists, use that */
        ,COALESCE(stored_letter, pgf_letter) AS term_grade_letter
        ,COALESCE(stored_pct, pgf_pct) AS term_grade_percent

        /* F* rule */
        ,CASE 
          WHEN COALESCE(stored_pct, pgf_pct) < 50 THEN 'F*'
          ELSE COALESCE(stored_letter, pgf_letter)
         END AS term_grade_letter_adjusted
        ,CASE
          WHEN COALESCE(stored_pct, pgf_pct) < 50 THEN 50
          ELSE COALESCE(stored_pct, pgf_pct)
         END AS term_grade_percent_adjusted
  FROM
      (
       SELECT enr.studentid
             ,enr.course_number
             ,enr.academic_year

             ,pgf.finalgradename AS term_name

             ,CONVERT(VARCHAR(5), sg.grade) AS stored_letter
             ,ROUND(sg.[percent], 0) AS stored_pct

             ,CASE
               WHEN enr.sectionid < 0 AND sg.[percent] IS NULL THEN NULL
               ELSE CONVERT(VARCHAR(5), pgf.grade)
              END AS pgf_letter
             ,CASE 
               WHEN enr.sectionid < 0 AND sg.[percent] IS NULL THEN NULL
               WHEN pgf.grade = '--' THEN NULL
               ELSE ROUND(pgf.[percent], 0)
              END AS pgf_pct
             ,CASE
               WHEN enr.sectionid < 0 AND sg.[percent] IS NULL THEN NULL
               WHEN pgf.grade = '--' THEN NULL
               ELSE COALESCE(sg_scale.grade_points, scale.grade_points)
              END AS term_gpa_points

             ,ROW_NUMBER() OVER(
                PARTITION BY enr.studentid, enr.yearid, enr.course_number, pgf.finalgradename
                  ORDER BY sg.[percent] DESC, enr.section_enroll_status, enr.dateleft DESC) AS rn
       FROM powerschool.course_enrollments_current_static enr
       JOIN powerschool.pgfinalgrades pgf
         ON enr.studentid = pgf.studentid
        AND enr.abs_sectionid = pgf.sectionid
        AND pgf.finalgrade_type IN ('T', 'Q')
       LEFT JOIN powerschool.storedgrades sg
         ON enr.studentid = sg.studentid
        AND enr.abs_sectionid = sg.sectionid
        AND pgf.finalgradename = sg.storecode
       LEFT JOIN powerschool.gradescaleitem_lookup_static scale
         ON enr.gradescaleid = scale.gradescaleid
        AND pgf.[percent] BETWEEN scale.min_cutoffpercentage AND scale.max_cutoffpercentage
       LEFT JOIN powerschool.gradescaleitem_lookup_static sg_scale
         ON enr.gradescaleid = sg_scale.gradescaleid
        AND sg.[percent] BETWEEN sg_scale.min_cutoffpercentage AND sg_scale.max_cutoffpercentage
       WHERE enr.course_enroll_status = 0
      ) sub
  WHERE rn = 1
 )

,exams AS (
  SELECT studentid
        ,academic_year
        ,course_number
        ,E1 AS e1
        ,E2 AS e2
        ,CASE WHEN E1 < 50 THEN 50 ELSE E1 END AS e1_adjusted
        ,CASE WHEN E2 < 50 THEN 50 ELSE E2 END AS e2_adjusted
  FROM
      (
       SELECT CONVERT(INT, studentid) AS studentid
             ,academic_year
             ,course_number
             ,storecode
             ,[percent]
       FROM powerschool.storedgrades
       WHERE storecode_type = 'E'
         AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
      ) sub
  PIVOT(
    MAX([percent])
    FOR storecode IN ([E1], [E2])
   ) p
 )

,grades_long AS (
  SELECT r.student_number
        ,r.studentid
        ,r.academic_year
        ,r.schoolid
        ,r.grade_level
        ,r.reporting_term
        ,r.term_name
        ,r.is_curterm
        ,r.credittype
        ,r.course_number
        ,r.course_name
        ,r.credit_hours
        ,r.gradescaleid 
        ,r.excludefromgpa
        ,r.sectionid
        ,r.teacher_name

        ,gr.term_grade_percent
        ,gr.term_grade_letter
        ,gr.term_grade_percent_adjusted
        ,gr.term_grade_letter_adjusted
        ,gr.term_gpa_points
        
        /* exam grades for Y1 calc, only for applicable terms */
        ,CASE WHEN r.term_name = 'Q2' THEN e.e1 ELSE NULL END AS e1
        ,CASE WHEN r.term_name = 'Q2' THEN e.e1_adjusted ELSE NULL END AS e1_adjusted
        ,CASE WHEN r.term_name = 'Q4' THEN e.e2 ELSE NULL END AS e2
        ,CASE WHEN r.term_name = 'Q4' THEN e.e2_adjusted ELSE NULL END AS e2_adjusted

        /* prior to 2016-2017, NCA used exam terms as 10% of the final grade */
        ,CASE
          WHEN gr.term_grade_percent IS NULL THEN NULL
          WHEN r.grade_level >= 9 THEN 0.225
          WHEN r.grade_level <= 8
               THEN 1.0 / CONVERT(FLOAT, COUNT(r.student_number) OVER(PARTITION BY r.student_number, r.academic_year, gr.course_number))
         END AS term_grade_weight
        ,CASE
          WHEN r.grade_level >= 9 THEN 0.225
          WHEN r.grade_level <= 8
               THEN 1.0 / CONVERT(FLOAT, COUNT(r.student_number) OVER(PARTITION BY r.student_number, r.academic_year, gr.course_number))
         END AS term_grade_weight_possible
        ,CASE
          WHEN r.grade_level >= 9
           AND r.term_name = 'Q2'
           AND e.e1 IS NOT NULL
               THEN 0.05
         END AS e1_grade_weight
        ,CASE
          WHEN r.grade_level >= 9
           AND r.term_name = 'Q4'
           AND e.e2 IS NOT NULL
               THEN 0.05
         END AS e2_grade_weight
  FROM roster r
  LEFT JOIN enr_grades gr
    ON r.studentid = gr.studentid
   AND r.academic_year = gr.academic_year
   AND r.term_name = gr.term_name
   AND r.course_number = gr.course_number
  LEFT JOIN exams e
    ON r.studentid = e.studentid
   AND r.academic_year = e.academic_year
   AND r.course_number = e.course_number
 )

SELECT sub.student_number
      ,sub.studentid
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_level
      ,sub.reporting_term
      ,sub.term_name
      ,sub.is_curterm
      ,sub.credittype
      ,sub.course_number
      ,sub.course_name
      ,sub.sectionid
      ,sub.teacher_name
      ,sub.excludefromgpa
      ,sub.gradescaleid
      ,CASE
        WHEN y1.potentialcrhrs IS NOT NULL THEN y1.potentialcrhrs
        ELSE sub.credit_hours
       END AS credit_hours
      ,sub.term_gpa_points
      ,sub.term_grade_letter
      ,sub.term_grade_percent
      ,sub.term_grade_letter_adjusted
      ,sub.term_grade_percent_adjusted
      ,sub.e1
      ,sub.e1_adjusted
      ,sub.e2
      ,sub.e2_adjusted
      ,sub.weighted_grade_total
      ,sub.weighted_points_total
      ,sub.y1_grade_percent AS y1_grade_percent
      /* these use the adjusted Y1 */
      ,CASE
        WHEN y1.[percent] IS NOT NULL THEN y1.[percent]
        ELSE sub.y1_grade_percent_adjusted
       END AS y1_grade_percent_adjusted
      ,CONVERT(VARCHAR(5),
         CASE
          WHEN y1.grade IS NOT NULL THEN y1.grade
          WHEN sub.y1_grade_percent_adjusted = 50 AND sub.y1_grade_percent < 50 THEN 'F*'
          ELSE y1_scale.letter_grade
         END) AS y1_grade_letter
      ,CASE
        WHEN y1.gpa_points IS NOT NULL THEN y1.gpa_points
        ELSE y1_scale.grade_points
       END AS y1_gpa_points
      ,y1_scale_unweighted.grade_points AS y1_gpa_points_unweighted

      /* Need To Get calcs */
      ,ROUND(((weighted_points_possible_total * 0.9) /* 90% of total points possible */
                - (ISNULL(weighted_grade_total_adjusted, 0) - (ISNULL(term_grade_weighted, 0) + ISNULL(e1_grade_weighted, 0) + ISNULL(e2_grade_weighted, 0)))) /* factor out points earned so far, including current */
                / (term_grade_weight_possible + ISNULL(e1_grade_weight, 0) + ISNULL(e2_grade_weight, 0)) /* divide by current term weights */
         , 0) AS need_90
      ,ROUND(((weighted_points_possible_total * 0.8) /* 80% of total points possible */
                - (ISNULL(weighted_grade_total_adjusted, 0) - (ISNULL(term_grade_weighted, 0) + ISNULL(e1_grade_weighted, 0) + ISNULL(e2_grade_weighted, 0)))) /* factor out points earned so far, including current */
                / (term_grade_weight_possible + ISNULL(e1_grade_weight, 0) + ISNULL(e2_grade_weight, 0)) /* divide by current term weights */
         , 0) AS need_80
      ,ROUND(((weighted_points_possible_total * 0.7) /* 70% of total points possible */
                - (ISNULL(weighted_grade_total_adjusted, 0) - (ISNULL(term_grade_weighted, 0) + ISNULL(e1_grade_weighted, 0) + ISNULL(e2_grade_weighted, 0)))) /* factor out points earned so far, including current */
                / (term_grade_weight_possible + ISNULL(e1_grade_weight, 0) + ISNULL(e2_grade_weight, 0)) /* divide by current term weights */
         , 0) AS need_70 
      ,ROUND(((weighted_points_possible_total * 0.6) /* 60% of total points possible - the field is still called need_65 but it is aliased as need_60 because walters is a liar */
                - (ISNULL(weighted_grade_total_adjusted, 0) - (ISNULL(term_grade_weighted, 0) + ISNULL(e1_grade_weighted, 0) + ISNULL(e2_grade_weighted, 0)))) /* factor out points earned so far, including current */
                / (term_grade_weight_possible + ISNULL(e1_grade_weight, 0) + ISNULL(e2_grade_weight, 0)) /* divide by current term weights */
         , 0) AS need_65
FROM
    (
     SELECT student_number
           ,studentid
           ,academic_year
           ,schoolid
           ,grade_level
           ,reporting_term
           ,term_name
           ,is_curterm
           ,credittype
           ,course_number
           ,course_name
           ,sectionid
           ,teacher_name
           ,excludefromgpa
           ,gradescaleid
           ,credit_hours
           ,term_gpa_points
           ,term_grade_letter
           ,term_grade_percent
           ,term_grade_letter_adjusted
           ,term_grade_percent_adjusted
           ,e1
           ,e1_adjusted
           ,e2
           ,e2_adjusted
           ,weighted_grade_total
           ,weighted_grade_total_adjusted
           ,weighted_points_total
           ,term_grade_weight_possible
           ,e1_grade_weight
           ,e2_grade_weight
           ,CASE
             WHEN sub.gradescaleid = 712 THEN 874 /* unweighted 2016-2018 */
             WHEN sub.gradescaleid = 991 THEN 976 /* unweighted 2019+ */
             WHEN sub.gradescaleid IS NULL THEN 874 /* MISSING GRADESCALE - default 2016+ */
             ELSE sub.gradescaleid
            END AS unweighted_gradescaleid

           /* Y1 calcs */
           ,ROUND((weighted_grade_total / weighted_points_total) * 100, 0) AS y1_grade_percent
           ,ROUND((weighted_grade_total_adjusted / weighted_points_total) * 100, 0) AS y1_grade_percent_adjusted

           ,CASE
             WHEN term_grade_percent_adjusted IS NULL THEN ISNULL(weighted_points_total, 0) + (term_grade_weight_possible * 100)
             ELSE weighted_points_total
            END + ISNULL(e1_grade_weight, 0) + ISNULL(e2_grade_weight, 0) AS weighted_points_possible_total
           ,(term_grade_percent_adjusted * term_grade_weight) AS term_grade_weighted
           ,ISNULL((e1 * e1_grade_weight), 0) AS e1_grade_weighted
           ,ISNULL((e2 * e2_grade_weight), 0) AS e2_grade_weighted
     FROM
         (
          SELECT student_number
                ,studentid
                ,academic_year
                ,schoolid
                ,grade_level
                ,reporting_term
                ,term_name
                ,is_curterm
                ,credittype
                ,course_number
                ,course_name
                ,sectionid
                ,teacher_name
                ,excludefromgpa
                ,gradescaleid
                ,credit_hours
                ,term_gpa_points
                ,term_grade_letter
                ,term_grade_percent
                ,term_grade_letter_adjusted
                ,term_grade_percent_adjusted
                ,e1
                ,e1_adjusted
                ,e2
                ,e2_adjusted
                ,term_grade_weight
                ,term_grade_weight_possible
                ,e1_grade_weight
                ,e2_grade_weight
                /* Y1 calc -- weighted avg */
                /* (weighted term grade + weighted exam grades) / total weighted points possible */
                ,SUM(
                   (term_grade_percent * term_grade_weight)
                     + ISNULL((e1 * e1_grade_weight), 0)
                     + ISNULL((e2 * e2_grade_weight), 0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number 
                           ORDER BY reporting_term ASC) AS weighted_grade_total /* does NOT use F* grades */
                ,SUM(
                   (term_grade_percent_adjusted * term_grade_weight)
                     + ISNULL((e1_adjusted * e1_grade_weight), 0)
                     + ISNULL((e2_adjusted * e2_grade_weight), 0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number
                           ORDER BY reporting_term ASC) AS weighted_grade_total_adjusted /* uses F* adjusted grade */
                ,SUM(
                   (term_grade_weight * 100)
                     + ISNULL((e1_grade_weight * 100), 0)
                     + ISNULL((e2_grade_weight * 100), 0)
                  ) OVER(PARTITION BY student_number, academic_year, course_number
                           ORDER BY reporting_term ASC) AS weighted_points_total
          FROM grades_long
         ) sub
    ) sub
LEFT JOIN powerschool.storedgrades y1
  ON sub.studentid = y1.studentid
 AND sub.academic_year = y1.academic_year
 AND sub.course_number = y1.course_number
 AND y1.storecode = 'Y1'
LEFT JOIN powerschool.gradescaleitem_lookup_static y1_scale
  ON sub.gradescaleid = y1_scale.gradescaleid
 AND sub.y1_grade_percent_adjusted BETWEEN y1_scale.min_cutoffpercentage AND y1_scale.max_cutoffpercentage
LEFT JOIN powerschool.gradescaleitem_lookup_static y1_scale_unweighted
  ON sub.unweighted_gradescaleid = y1_scale_unweighted.gradescaleid
 AND sub.y1_grade_percent_adjusted BETWEEN y1_scale_unweighted.min_cutoffpercentage AND y1_scale_unweighted.max_cutoffpercentage
