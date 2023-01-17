CREATE OR ALTER VIEW
  qa.easyiep_powerschool_match AS
SELECT
  iep.db_name,
  iep._file,
  iep._line,
  iep.student_number,
  iep.state_studentnumber,
  nj.lastfirst,
  nj.student_number AS correct_student_number
FROM
  easyiep.njsmart_powerschool_clean_static AS iep
  LEFT JOIN powerschool.students AS s ON (
    iep.student_number = s.student_number
    AND iep.[db_name] = s.[db_name]
  )
  LEFT JOIN powerschool.students AS nj ON (
    iep.state_studentnumber = nj.state_studentnumber
    AND iep.[db_name] = nj.[db_name]
  )
WHERE
  (
    CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN iep.effective_start_date AND iep.effective_end_date
  )
  AND s.student_number IS NULL
