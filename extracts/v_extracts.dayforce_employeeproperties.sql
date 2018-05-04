USE gabby
GO

--CREATE OR ALTER VIEW extracts.dayforce_employeeproperties AS

SELECT r.df_employee_number
      ,MIN(enr.dateenrolled) AS effective_start_date
      ,MAX(enr.dateleft) AS effective_end_date
      ,'Grade Taught' AS employee_property_value_name
      ,CASE WHEN s.grade_level = 0 THEN 'K' ELSE CONVERT(VARCHAR,s.grade_level) END AS property_value
FROM gabby.powerschool.course_enrollments_static enr
LEFT JOIN gabby.people.id_crosswalk_powerschool psid
  ON enr.teachernumber = psid.ps_teachernumber
LEFT JOIN gabby.dayforce.staff_roster r
  ON psid.df_employee_number = r.df_employee_number
LEFT JOIN gabby.powerschool.students s
  ON enr.studentid = s.id
WHERE enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0
GROUP BY enr.academic_year
        ,r.df_employee_number
        ,s.grade_level