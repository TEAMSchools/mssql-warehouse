CREATE OR ALTER VIEW
  extracts.clever_enrollments AS
SELECT
  cc.schoolid AS [School_id],
  CONCAT(
    CASE
      WHEN cc.[db_name] = 'kippnewark' THEN 'NWK'
      WHEN cc.[db_name] = 'kippcamden' THEN 'CMD'
      WHEN cc.[db_name] = 'kippmiami' THEN 'MIA'
    END,
    cc.sectionid
  ) AS [Section_id],
  s.student_number AS [Student_id]
FROM
  powerschool.cc
  INNER JOIN powerschool.students AS s ON (
    cc.studentid = s.id
    AND cc.[db_name] = s.[db_name]
  )
WHERE
  cc.dateleft >= CAST(CURRENT_TIMESTAMP AS DATE)
UNION ALL
/* ENR sections */
SELECT
  schoolid AS [School_id],
  CONCAT(
    utilities.GLOBAL_ACADEMIC_YEAR () - 1990,
    schoolid,
    RIGHT(CONCAT(0, grade_level), 2)
  ) AS [Section_id],
  student_number AS [Student_id]
FROM
  powerschool.students
WHERE
  enroll_status IN (0, -1)
