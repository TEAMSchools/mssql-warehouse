SELECT
  ar.student_number,
  ar.academic_year,
  ar.vch_content_title,
  ar.i_lexile,
  ar.i_word_count,
  ar.dt_taken,
  ar.rn_quiz,
  s.lastfirst,
  s.schoolid,
  s.grade_level
FROM
  gabby.renaissance.ar_studentpractice_identifiers_static AS ar
  INNER JOIN gabby.powerschool.students AS s ON ar.student_number = s.student_number
WHERE
  ar.rn_quiz > 1
  AND ar.ti_passed = 1
  AND ar.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1
