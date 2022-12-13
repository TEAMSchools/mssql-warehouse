USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.illuminate_roster AS
SELECT
  enr.student_number AS [01 Student ID],
  NULL AS [02 Ssid],
  NULL AS [03 Last Name],
  NULL AS [04 First Name],
  NULL AS [05 Middle Name],
  NULL AS [06 Birth Date],
  CONCAT(
    CASE
      WHEN enr.[db_name] = 'kippnewark' THEN 'NWK'
      WHEN enr.[db_name] = 'kippcamden' THEN 'CMD'
      WHEN enr.[db_name] = 'kippmiami' THEN 'MIA'
    END,
    enr.sectionid
  ) AS [07 Section ID],
  enr.schoolid AS [08 Site ID],
  enr.course_number AS [09 Course ID],
  enr.teachernumber AS [10 User ID],
  enr.dateenrolled AS [11 Entry Date],
  enr.dateleft AS [12 Leave Date],
  CASE
    WHEN co.grade_level IN (-2, -1) THEN 15
    WHEN co.grade_level = 99 THEN 14
    ELSE co.grade_level + 1
  END AS [13 Grade Level ID],
  CONCAT(enr.academic_year, '-', (enr.academic_year + 1)) AS [14 Academic Year],
  NULL AS [15 Session Type ID]
FROM
  gabby.powerschool.course_enrollments_current_static enr
  JOIN gabby.powerschool.cohort_identifiers_static co ON enr.student_number = co.student_number
  AND enr.academic_year = co.academic_year
  AND enr.[db_name] = co.[db_name]
  AND co.rn_year = 1
WHERE
  enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0;
