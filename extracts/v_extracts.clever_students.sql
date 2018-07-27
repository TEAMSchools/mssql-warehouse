USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_students AS

SELECT CONVERT(VARCHAR(25),schoolid) AS [School_id]
      ,CONVERT(VARCHAR(25),student_number) AS [Student_id]
      ,CONVERT(VARCHAR(25),student_number) AS [Student_number]
      ,NULL AS [State_id]
      ,last_name AS [Last_name]
      ,middle_name AS [Middle_name]
      ,first_name AS [First_name]
      ,CASE
        WHEN grade_level = 0 THEN 'Kindergarten'
        ELSE CONVERT(VARCHAR(5), grade_level)
       END AS [Grade]
      ,NULL AS [Gender]
      ,cohort AS [Graduation_year]
      ,CONVERT(VARCHAR(25), dob, 101) AS [DOB]
      ,NULL AS [Race]
      ,NULL AS [Hispanic_Latino]
      ,NULL AS [Home_language]
      ,CASE WHEN lep_status = 1 THEN 'Y' ELSE 'N' END AS [Ell_status]
      ,NULL AS [Frl_status]
      ,CASE WHEN iep_status IN ('SPED', 'SPED SPEECH') THEN 'Y' ELSE 'N' END AS [IEP_status]
      ,NULL AS [Student_street]
      ,NULL AS [Student_city]
      ,NULL AS [Student_state]
      ,NULL AS [Student_zip]
      ,student_web_id + '@teamstudents.org' AS [Student_email]
      ,NULL AS [Contact_relationship]
      ,NULL AS [Contact_type]
      ,NULL AS [Contact_name]
      ,NULL AS [Contact_phone]
      ,NULL AS [Contact_phone_type]
      ,NULL AS [Contact_email]
      ,NULL AS [Contact_sis_id]
      ,student_web_id AS [Username]
      ,NULL AS [Password]
      ,NULL AS [Unweighted_gpa]
      ,NULL AS [Weighted_gpa]
FROM gabby.powerschool.cohort_identifiers_static
WHERE rn_undergrad = 1
  AND schoolid != 999999