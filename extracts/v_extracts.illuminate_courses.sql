USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.illuminate_courses AS
SELECT DISTINCT
  course_number AS [01 Course ID],
  course_name AS [02 Full Name],
  course_name AS [03 Short Name],
  credittype AS [04 Department Name],
  NULL AS [05 Low Grade Level ID],
  NULL AS [06 High Grade Level ID],
  NULL AS [07 Site ID List],
  NULL AS [08 Active],
  NULL AS [09 A-G Requirement Category],
  NULL AS [10 Course Weight],
  NULL AS [11 Course Description],
  NULL AS [12 Credits Possible],
  NULL AS [13 Variable Credit Class],
  NULL AS [14 Maximum Credits],
  NULL AS [15 Special Education Course],
  NULL AS [16 Max Capacity],
  NULL AS [17 Intervention Course],
  NULL AS [18 NCLB Instructional Level],
  NULL AS [19 Course Content],
  NULL AS [20 Education Service],
  NULL AS [21 Instructional Strategy],
  NULL AS [22 Program Funding Source],
  NULL AS [23 CTE Funding Provider],
  NULL AS [24 Tech Prep]
FROM
  gabby.powerschool.courses;
