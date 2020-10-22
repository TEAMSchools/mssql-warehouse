USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_students AS

SELECT CONVERT(VARCHAR(25), co.schoolid) AS [School_id]
      ,CONVERT(VARCHAR(25), co.student_number) AS [Student_id]
      ,CONVERT(VARCHAR(25), co.student_number) AS [Student_number]
      ,NULL AS [State_id]
      ,co.last_name AS [Last_name]
      ,co.middle_name AS [Middle_name]
      ,co.first_name AS [First_name]
      ,CASE
        WHEN co.grade_level = 0 THEN 'Kindergarten'
        ELSE CONVERT(VARCHAR(5), co.grade_level)
       END AS [Grade]
      ,co.gender AS [Gender]
      ,co.cohort AS [Graduation_year]
      ,CONVERT(VARCHAR(25), dob, 101) AS [DOB]
      ,co.ethnicity AS [Race]
      ,NULL AS [Hispanic_Latino]
      ,NULL AS [Home_language]
      ,CASE
        WHEN co.lep_status = 1 THEN 'Y'
        ELSE 'N'
       END AS [Ell_status]
      ,NULL AS [Frl_status]
      ,CASE
        WHEN co.iep_status IN ('SPED', 'SPED SPEECH') THEN 'Y'
        ELSE 'N'
       END AS [IEP_status]
      ,NULL AS [Student_street]
      ,NULL AS [Student_city]
      ,NULL AS [Student_state]
      ,NULL AS [Student_zip]
      ,co.student_web_id + '@teamstudents.org' AS [Student_email]
      ,sc.person_relationship AS [Contact_relationship]
      ,CASE WHEN sc.person_type IN ('mother', 'father', 'contact1', 'contact2') THEN 'primary' ELSE sc.person_type END AS [Contact_type]
      ,COALESCE(sc.person_name, sc.person_type) AS [Contact_name]
      ,CONVERT(VARCHAR(25), LEFT(gabby.utilities.STRIP_CHARACTERS(sc.contact, '^0-9'), 10)) AS [Contact_phone]
      ,CASE
        WHEN sc.contact_type = 'home' THEN 'Home'
        WHEN sc.contact_type = 'mobile' THEN 'Cell'
        WHEN sc.contact_type = 'daytime' THEN 'Work'
       END AS [Contact_phone_type]
      ,NULL AS [Contact_email]
      ,NULL AS [Contact_sis_id]
      ,co.student_web_id AS [Username]
      ,NULL AS [Password]
      ,gpa.cumulative_Y1_gpa AS [Unweighted_gpa]
      ,gpa.cumulative_Y1_gpa_unweighted AS [Weighted_gpa]
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.student_contacts_static sc
  ON co.student_number = sc.student_number
 AND co.[db_name] = sc.[db_name]
 AND sc.contact_category = 'Phone'
 AND sc.person_type <> 'self'
LEFT JOIN gabby.powerschool.gpa_cumulative gpa
  ON co.studentid = gpa.studentid
 AND co.schoolid = gpa.schoolid
 AND co.[db_name] = gpa.[db_name]
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level <> 99

UNION ALL

/* demo students */
SELECT CONVERT(VARCHAR(25), co.schoolid) AS [School_id]
      ,CONVERT(VARCHAR(25), CONCAT(999, co.student_number)) AS [Student_id]
      ,CONVERT(VARCHAR(25), CONCAT(999, co.student_number)) AS [Student_number]
      ,NULL AS [State_id]
      ,'Student ' + co.school_level AS [Last_name]
      ,NULL AS [Middle_name]
      ,'Awesome' AS [First_name]
      ,CASE
        WHEN co.grade_level = 0 THEN 'Kindergarten'
        ELSE CONVERT(VARCHAR(5), co.grade_level)
       END AS [Grade]
      ,co.gender AS [Gender]
      ,co.cohort AS [Graduation_year]
      ,CONVERT(VARCHAR(25), dob, 101) AS [DOB]
      ,co.ethnicity AS [Race]
      ,NULL AS [Hispanic_Latino]
      ,NULL AS [Home_language]
      ,CASE
        WHEN co.lep_status = 1 THEN 'Y'
        ELSE 'N'
       END AS [Ell_status]
      ,NULL AS [Frl_status]
      ,CASE
        WHEN co.iep_status IN ('SPED', 'SPED SPEECH') THEN 'Y'
        ELSE 'N'
       END AS [IEP_status]
      ,NULL AS [Student_street]
      ,NULL AS [Student_city]
      ,NULL AS [Student_state]
      ,NULL AS [Student_zip]
      ,'awesomestudent' + LOWER(co.school_level) + '@teamstudents.org' AS [Student_email]
      ,NULL AS [Contact_relationship]
      ,NULL AS [Contact_type]
      ,NULL AS [Contact_name]
      ,NULL AS [Contact_phone]
      ,NULL AS [Contact_phone_type]
      ,NULL AS [Contact_email]
      ,NULL AS [Contact_sis_id]
      ,'awesomestudent' + LOWER(co.school_level) AS [Username]
      ,NULL AS [Password]
      ,NULL AS [Unweighted_gpa]
      ,NULL AS [Weighted_gpa]
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.student_number IN (17453, 11900)
