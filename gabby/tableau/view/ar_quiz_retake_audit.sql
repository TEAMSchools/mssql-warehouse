CREATE OR ALTER VIEW
  tableau.ar_quiz_retake_audit AS
SELECT
  co.student_number,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.region,
  ar.i_quiz_number,
  ar.vch_content_title,
  ar.vch_lexile_display,
  ar.ch_fiction_non_fiction,
  ar.dt_taken,
  ar.d_percent_correct,
  ar.i_word_count,
  CAST(ar.rn_quiz AS INT) AS rn_quiz,
  CAST(dts.alt_name AS VARCHAR(25)) AS term,
  dts.is_curterm,
  enr.teacher_name,
  hr.teacher_name AS homeroom_teacher
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN renaissance.ar_studentpractice_identifiers_static AS ar ON (
    co.student_number = ar.student_number
    AND co.academic_year = ar.academic_year
    AND ar.ti_passed = 1
    AND ar.rn_quiz > 1
  )
  LEFT JOIN reporting.reporting_terms AS dts ON (
    co.schoolid = dts.schoolid
    AND (
      ar.dt_taken BETWEEN dts.[start_date] AND dts.end_date
    )
    AND dts.identifier = 'AR'
    AND dts.time_per_name != 'ARY'
    AND dts._fivetran_deleted = 0
  )
  LEFT JOIN powerschool.course_enrollments_current_static AS enr ON (
    co.student_number = enr.student_number
    AND co.academic_year = enr.academic_year
    AND co.[db_name] = enr.[db_name]
    AND enr.credittype = 'ENG'
    AND enr.section_enroll_status = 0
    AND enr.rn_subject = 1
  )
  LEFT JOIN powerschool.course_enrollments_current_static AS hr ON (
    co.student_number = hr.student_number
    AND co.academic_year = hr.academic_year
    AND co.schoolid = hr.schoolid
    AND co.[db_name] = hr.[db_name]
    AND hr.course_number = 'HR'
    AND hr.section_enroll_status = 0
    AND hr.rn_course_yr = 1
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.grade_level != 99
  AND co.enroll_status = 0
