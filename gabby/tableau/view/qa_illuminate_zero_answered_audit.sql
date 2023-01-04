CREATE OR ALTER VIEW
  tableau.qa_illuminate_zero_answered_audit AS
SELECT
  co.student_number,
  co.lastfirst,
  co.region,
  co.schoolid,
  co.grade_level,
  co.team,
  co.enroll_status,
  ovr.date_taken,
  ovr.percent_correct,
  ovr.answered,
  ovr.number_of_questions,
  a.assessment_id,
  a.title,
  a.administered_at,
  a.scope,
  a.subject_area,
  dt.alt_name AS term_name,
  dt.start_date,
  dt.end_date,
  att.att_code
FROM
  gabby.illuminate_dna_assessments.agg_student_responses AS ovr
  INNER JOIN gabby.illuminate_public.students AS s ON (ovr.student_id = s.student_id)
  INNER JOIN gabby.illuminate_dna_assessments.assessments_identifiers AS a ON (
    ovr.assessment_id = a.assessment_id
  )
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
    s.local_student_id = co.student_number
    AND a.academic_year_clean = co.academic_year
    AND co.rn_year = 1
    AND co.enroll_status = 0
  )
  LEFT JOIN gabby.reporting.reporting_terms AS dt ON (
    co.schoolid = dt.schoolid
    AND (
      a.administered_at BETWEEN dt.start_date AND dt.end_date
    )
    AND dt.identifier = 'RT'
    AND dt._fivetran_deleted = 0
  )
  LEFT JOIN gabby.powerschool.ps_attendance_daily AS att ON (
    co.studentid = att.studentid
    AND co.db_name = att.db_name
    AND ovr.date_taken = att.att_date
    AND att.att_code LIKE 'A%'
  )
WHERE
  ovr.answered = 0
  AND ovr.date_taken >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
