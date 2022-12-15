USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.nwea_roster_file AS
SELECT DISTINCT
  cst.School_id AS [School State Code],
  csh.School_name AS [School Name],
  NULL AS [Previous Instructor ID],
  ct.Teacher_number AS [Instructor ID],
  ct.State_teacher_id AS [Instructor State ID],
  ct.Last_name AS [Instructor Last Name],
  ct.First_name AS [Instructor First Name],
  NULL AS [Instructor Middle Initial],
  ct.Teacher_email AS [User Name],
  ct.Teacher_email AS [Email Address],
  csc.Course_name + ' - ' + csc.Section_number AS [Class Name],
  NULL AS [Previous Student ID],
  cst.Student_number AS [Student ID],
  NULL AS [Student State ID],
  cst.Last_name AS [Student Last Name],
  cst.First_name AS [Student First Name],
  UPPER(LEFT(cst.Middle_name, 1)) AS [Student Middle Initial],
  CASE
    WHEN cst.DOB >= CURRENT_TIMESTAMP THEN CAST(CURRENT_TIMESTAMP AS DATE)
    WHEN cst.DOB IS NULL THEN CAST(CURRENT_TIMESTAMP AS DATE)
    ELSE cst.DOB
  END AS [Student Date Of Birth],
  CASE
    WHEN cst.Gender IS NOT NULL THEN cst.Gender
    WHEN RAND() >= 0.5 THEN 'M'
    ELSE 'F'
  END AS [Student Gender],
  CASE
    WHEN cst.Grade = 'Kindergarten' THEN '0'
    ELSE cst.Grade
  END AS [Student Grade],
  CASE
    WHEN cst.Race = 'A' THEN 'Asian'
    WHEN cst.Race = 'B' THEN 'Black or African American'
    WHEN cst.Race = 'H' THEN 'Hispanic or Latino'
    WHEN cst.Race = 'I' THEN 'American Indian or Alaskan Native'
    WHEN cst.Race = 'P' THEN 'Native Hawaiian or Other Pacific Islander'
    WHEN cst.Race = 'T' THEN 'Multi-ethnic'
    WHEN cst.Race = 'W' THEN 'White'
    ELSE 'Not specified or Other'
  END AS [Student Ethnic Group Name],
  NULL AS [Student User Name],
  NULL AS [Student Email]
FROM
  gabby.extracts.clever_students cst
  JOIN gabby.extracts.clever_schools csh ON cst.School_id = csh.School_id
  JOIN gabby.extracts.clever_enrollments cer ON cst.Student_id = cer.Student_id
  AND cst.School_id = cer.School_id
  JOIN gabby.extracts.clever_sections csc ON cer.Section_id = csc.Section_id
  JOIN gabby.extracts.clever_teachers ct ON csc.Teacher_id = ct.Teacher_id
COLLATE Latin1_General_BIN
