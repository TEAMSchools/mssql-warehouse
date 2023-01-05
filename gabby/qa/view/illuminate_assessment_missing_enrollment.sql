CREATE OR ALTER VIEW
  qa.illuminate_assessment_missing_enrollment AS
WITH
  enr AS (
    SELECT
      cc.dateenrolled AS entry_date,
      cc.dateleft AS leave_date,
      CASE
        WHEN cc.sectionid < 0 THEN 1.0
        ELSE 0.0
      END AS is_dropped_section,
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
      co.student_number,
      ns.illuminate_subject AS subject_area
    FROM
      powerschool.cc
      INNER JOIN powerschool.cohort_static AS co ON (
        cc.studentid = co.studentid
        AND cc.studyear = CONCAT(co.studentid, co.yearid)
        AND cc.[db_name] = co.[db_name]
        AND co.rn_year = 1
      )
      INNER JOIN assessments.normed_subjects AS ns ON (
        cc.course_number = ns.course_number
      )
    UNION ALL
    /* ES Writing */
    SELECT
      co.entrydate AS entry_date,
      co.exitdate AS leave_date,
      0.0 AS is_dropped_section,
      0.0 AS is_dropped_course,
      co.student_number,      
      'Writing' AS subject_area
    FROM
      powerschool.cohort_static AS co
      INNER JOIN illuminate_public.students AS ils ON (
        co.student_number = ils.local_student_id
      )
    WHERE
      co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
      AND co.grade_level <= 4
      AND co.[db_name] != 'kippmiami'
  )
SELECT
  a.assessment_id,
  a.title,
  a.academic_year_clean,
  a.administered_at,
  a.scope,
  a.subject_area,
  a.module_type,
  a.module_number,
  sa.student_id,
  sa.date_taken,
  ils.local_student_id
FROM
  illuminate_dna_assessments.assessments_identifiers_static AS a
  INNER JOIN illuminate_dna_assessments.students_assessments AS sa ON (
    a.assessment_id = sa.assessment_id
  )
  INNER JOIN illuminate_public.students AS ils ON (sa.student_id = ils.student_id)
  LEFT JOIN enr ON (
    ils.local_student_id = enr.student_number
    AND a.subject_area = enr.subject_area
    AND (
      a.administered_at BETWEEN enr.entry_date AND enr.leave_date
    )
  )
WHERE
  a.is_normed_scope = 1
  AND a.administered_at <= CAST(CURRENT_TIMESTAMP AS DATE)
  AND enr.student_number IS NULL
