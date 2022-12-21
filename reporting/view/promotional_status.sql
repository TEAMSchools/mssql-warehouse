CREATE OR ALTER VIEW
  reporting.promotional_status AS
WITH
  failing AS (
    SELECT
      fg.studentid,
      fg.yearid,
      fg.storecode,
      SUM(
        CASE
          WHEN fg.y1_grade_letter IN ('F', 'F*') THEN 1
          ELSE 0
        END
      ) AS n_failing,
      SUM(
        CASE
          WHEN (
            fg.y1_grade_letter IN ('F', 'F*')
            AND c.credittype IN ('MATH', 'ENG', 'SCI', 'SOC')
          ) THEN 1
          ELSE 0
        END
      ) AS n_failing_ms_core
    FROM
      gabby.powerschool.final_grades_static AS fg
      INNER JOIN gabby.powerschool.courses AS c ON (
        fg.course_number = c.course_number
        AND fg.[db_name] = c.[db_name]
      )
    GROUP BY
      fg.studentid,
      fg.yearid,
      fg.storecode
  ),
  credits AS (
    SELECT
      studentid,
      [db_name],
      schoolid,
      earned_credits_cum,
      earned_credits_cum_projected
    FROM
      gabby.powerschool.gpa_cumulative
  ),
  enrolled_credits AS (
    SELECT
      student_number,
      academic_year,
      SUM(credit_hours) AS credit_hours_enrolled
    FROM
      gabby.powerschool.course_enrollments
    WHERE
      course_enroll_status = 0
      AND section_enroll_status = 0
      AND rn_course_yr = 1
    GROUP BY
      student_number,
      academic_year
  ),
  qas AS (
    SELECT
      local_student_id,
      academic_year,
      term_administered,
      AVG(performance_band_number) AS avg_performance_band_number
    FROM
      gabby.illuminate_dna_assessments.agg_student_responses_all
    WHERE
      module_type = 'QA'
      AND subject_area IN ('Mathematics', 'Algebra I')
      AND response_type = 'O'
    GROUP BY
      local_student_id,
      academic_year,
      term_administered
  ),
  att AS (
    SELECT
      studentid,
      [db_name],
      yearid,
      ROUND(
        AVG(CAST(attendancevalue AS FLOAT)) * 100,
        1
      ) AS ada_y1_running
    FROM
      gabby.powerschool.ps_adaadm_daily_ctod
    WHERE
      membershipvalue > 0
      AND calendardate <= CAST(CURRENT_TIMESTAMP AS DATE)
    GROUP BY
      studentid,
      [db_name],
      yearid
  )
SELECT
  student_number,
  studentid,
  [db_name],
  academic_year,
  schoolid,
  iep_status,
  is_retained_flag,
  reporting_term_name,
  alt_name,
  is_curterm,
  ada_y1_running,
  fp_independent_level,
  grades_y1_failing_projected,
  grades_y1_credits_projected,
  grades_y1_credits_enrolled,
  grades_y1_credits_goal,
  qa_avg_performance_band_number,
  promo_status_attendance,
  promo_status_lit,
  promo_status_grades,
  promo_status_qa_math,
  CASE
    WHEN alt_name = 'Q4' THEN (
      CASE
        WHEN (
          sched_nextyeargrade = 99
          AND school_level = 'HS'
        ) THEN 'Graduated'
        WHEN sched_nextyeargrade > grade_level THEN 'Promoted'
        WHEN sched_nextyeargrade <= grade_level THEN 'Retained'
      END
    )
    WHEN (
      school_level != 'HS'
      AND (
        iep_status = 'SPED'
        OR is_retained_flag = 1
      )
    ) THEN 'See Teacher'
    WHEN CONCAT(
      promo_status_attendance,
      promo_status_lit,
      promo_status_grades,
      promo_status_qa_math
    ) LIKE '%At Risk%' THEN 'At Risk'
    WHEN CONCAT(
      promo_status_attendance,
      promo_status_lit,
      promo_status_grades,
      promo_status_qa_math
    ) LIKE '%Off Track%' THEN 'Off Track'
    ELSE 'On Track'
  END AS promo_status_overall
FROM
  (
    SELECT
      student_number,
      studentid,
      [db_name],
      academic_year,
      school_level,
      schoolid,
      grade_level,
      iep_status,
      is_retained_flag,
      sched_nextyeargrade,
      reporting_term_name,
      alt_name,
      is_curterm,
      ada_y1_running,
      fp_independent_level,
      grades_y1_failing_projected,
      grades_y1_credits_projected,
      grades_y1_credits_enrolled,
      grades_y1_credits_goal,
      qa_avg_performance_band_number,
      CASE
        WHEN ada_y1_running >= 90.1 THEN 'On Track'
        WHEN ada_y1_running < 90.1 THEN 'Off Track'
        --WHEN ada_y1_running < 80.0 THEN 'At Risk'
        ELSE 'No Data'
      END AS promo_status_attendance,
      CASE
        WHEN school_level IN ('HS', 'MS') THEN 'N/A'
        WHEN fp_goal_status IN (
          'Target',
          'Above Target',
          'Achieved Z'
        ) THEN 'On Track'
        WHEN fp_goal_status IN ('Below', 'Approaching') THEN 'Off Track'
        WHEN fp_goal_status = 'Far Below' THEN 'At Risk'
        ELSE 'No Data'
      END AS promo_status_lit,
      CASE
        WHEN school_level IN ('HS', 'MS') THEN 'N/A'
        WHEN qa_avg_performance_band_number >= 4 THEN 'On Track'
        WHEN qa_avg_performance_band_number IN (2, 3) THEN 'Off Track'
        WHEN qa_avg_performance_band_number = 1 THEN 'At Risk'
        ELSE 'No Data'
      END AS promo_status_qa_math,
      CASE
        WHEN school_level = 'ES' THEN 'N/A'
        WHEN school_level = 'MS' THEN (
          CASE
            WHEN grades_y1_failing_projected = 0 THEN 'On Track'
            WHEN grades_y1_failing_projected >= 1 THEN 'Off Track'
            --WHEN grades_y1_failing_projected >= 2 THEN 'At Risk'
            ELSE 'No Data'
          END
        )
        WHEN school_level = 'HS' THEN (
          CASE
            WHEN grades_y1_credits_projected >= grades_y1_credits_goal THEN 'On Track'
            WHEN grades_y1_credits_projected < grades_y1_credits_goal THEN 'Off Track'
            ELSE 'No Data'
          END
        )
      END AS promo_status_grades
    FROM
      (
        SELECT
          co.student_number,
          co.studentid,
          co.[db_name],
          co.academic_year,
          co.school_level,
          co.schoolid,
          co.grade_level,
          co.iep_status,
          CASE
            WHEN co.is_retained_year + co.is_retained_ever >= 1 THEN 1
            ELSE 0
          END AS is_retained_flag,
          s.sched_nextyeargrade,
          rt.time_per_name AS reporting_term_name,
          rt.alt_name,
          rt.is_curterm,
          att.ada_y1_running,
          lit.read_lvl AS fp_independent_level,
          lit.goal_status AS fp_goal_status,
          CASE
            WHEN co.school_level = 'MS' THEN f.n_failing_ms_core
            ELSE f.n_failing
          END AS grades_y1_failing_projected,
          cr.earned_credits_cum_projected AS grades_y1_credits_projected,
          (
            ISNULL(cr.earned_credits_cum, 0) + ISNULL(enr.credit_hours_enrolled, 0)
          ) AS grades_y1_credits_enrolled,
          CASE
            WHEN co.grade_level = 9 THEN 25
            WHEN co.grade_level = 10 THEN 50
            WHEN co.grade_level = 11 THEN 85
            WHEN co.grade_level = 12 THEN 120
          END AS grades_y1_credits_goal,
          qas.avg_performance_band_number AS qa_avg_performance_band_number
        FROM
          gabby.powerschool.cohort_identifiers_static AS co
          INNER JOIN gabby.powerschool.students AS s ON (
            co.student_number = s.student_number
          )
          INNER JOIN gabby.reporting.reporting_terms AS rt ON (
            co.schoolid = rt.schoolid
            AND co.academic_year = rt.academic_year
            AND rt.identifier = 'RT'
            AND rt._fivetran_deleted = 0
          )
          LEFT JOIN att ON (
            co.studentid = att.studentid
            AND co.[db_name] = att.[db_name]
            AND co.yearid = att.yearid
          )
          LEFT JOIN gabby.lit.achieved_by_round_static AS lit ON (
            co.student_number = lit.student_number
            AND co.academic_year = lit.academic_year
            AND rt.alt_name = lit.test_round
          )
          LEFT JOIN failing AS f ON (
            co.studentid = f.studentid
            AND co.yearid = f.yearid
            AND (
              rt.alt_name = f.storecode
              COLLATE LATIN1_GENERAL_BIN
            )
          )
          LEFT JOIN credits AS cr ON (
            co.studentid = cr.studentid
            AND co.schoolid = cr.schoolid
            AND co.[db_name] = cr.[db_name]
          )
          LEFT JOIN enrolled_credits AS enr ON (
            co.student_number = enr.student_number
            AND co.academic_year = enr.academic_year
          )
          LEFT JOIN qas ON (
            co.student_number = qas.local_student_id
            AND co.academic_year = qas.academic_year
            AND rt.alt_name = qas.term_administered
          )
        WHERE
          co.rn_year = 1
      ) AS sub
  ) AS sub
