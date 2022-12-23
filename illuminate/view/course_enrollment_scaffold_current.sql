CREATE OR ALTER VIEW
  illuminate_dna_assessments.course_enrollment_scaffold_current AS
WITH
  enr AS (
    /* K-12 enrollments */
    SELECT
      cc.dateenrolled AS entry_date,
      cc.dateleft AS leave_date,
      AVG(
        CASE
          WHEN cc.sectionid < 0 THEN 1.0
          ELSE 0.0
        END
      ) OVER (
        PARTITION BY
          cc.studyear,
          cc.course_number
      ) AS is_dropped_course,
      co.academic_year + 1 AS academic_year,
      co.grade_level + 1 AS grade_level_id,
      si.credittype,
      ils.student_id,
      (
        ns.illuminate_subject
        COLLATE LATIN1_GENERAL_BIN
      ) AS subject_area,
      CASE
        WHEN ns.illuminate_subject IN (
          'Algebra I',
          'Geometry',
          'Algebra II',
          'Algebra IIA',
          'Algebra IIB',
          'Pre-Calculus'
        ) THEN 1
        ELSE 0
      END AS is_advanced_math
    FROM
      gabby.powerschool.cc
      INNER JOIN gabby.powerschool.sections_identifiers AS si ON (
        ABS(cc.sectionid) = si.sectionid
        AND cc.[db_name] = si.[db_name]
      )
      INNER JOIN gabby.powerschool.cohort_static AS co ON (
        cc.studentid = co.studentid
        AND cc.studyear = CONCAT(co.studentid, co.yearid)
        AND cc.[db_name] = co.[db_name]
        AND co.rn_year = 1
      )
      INNER JOIN gabby.illuminate_public.students AS ils ON (
        co.student_number = ils.local_student_id
      )
      INNER JOIN gabby.assessments.normed_subjects AS ns ON (
        cc.course_number = ns.course_number
        COLLATE LATIN1_GENERAL_BIN
      )
    WHERE
      cc.dateenrolled >= DATEFROMPARTS(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        7,
        1
      )
    UNION ALL
    /* ES Writing */
    SELECT
      co.entrydate AS entry_date,
      co.exitdate AS leave_date,
      0.0 AS is_dropped_course,
      co.academic_year + 1 AS academic_year,
      co.grade_level + 1 AS grade_level_id,
      'RHET' AS credittype,
      ils.student_id,
      (
        'Writing'
        COLLATE LATIN1_GENERAL_BIN
      ) AS subject_area,
      0 AS is_advanced_math
    FROM
      gabby.powerschool.cohort_static AS co
      INNER JOIN gabby.illuminate_public.students AS ils ON (
        co.student_number = ils.local_student_id
      )
    WHERE
      co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND co.grade_level <= 4
      AND co.[db_name] != 'kippmiami'
  )
SELECT
  student_id,
  academic_year,
  entry_date,
  leave_date,
  grade_level_id,
  credittype,
  subject_area,
  is_advanced_math_student
FROM
  (
    SELECT
      student_id,
      academic_year,
      grade_level_id,
      entry_date,
      credittype,
      subject_area,
      leave_date,
      MAX(is_advanced_math) OVER (
        PARTITION BY
          student_id,
          academic_year,
          credittype
      ) AS is_advanced_math_student,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_id,
          entry_date,
          leave_date,
          subject_area
        ORDER BY
          entry_date DESC,
          leave_date DESC
      ) AS rn
    FROM
      enr
    WHERE
      is_dropped_course < 1.0
  ) AS sub
WHERE
  rn = 1