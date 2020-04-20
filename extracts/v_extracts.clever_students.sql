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
      ,sc.contact_relationship AS [Contact_relationship]
      ,CASE WHEN sc.contact_type IN ('parent1', 'parent2') THEN 'primary' ELSE sc.contact_type END AS [Contact_type]
      ,sc.contact_name AS [Contact_name]
      ,CONVERT(VARCHAR(25),LEFT(gabby.utilities.STRIP_CHARACTERS(sc.phone, '^0-9'), 10)) AS [Contact_phone]
      ,CASE
        WHEN sc.phone_type = 'home' THEN 'Home'
        WHEN sc.phone_type = 'cell' THEN 'Cell'
        WHEN sc.phone_type = 'day' THEN 'Work'
       END AS [Contact_phone_type]
      ,NULL AS [Contact_email]
      ,NULL AS [Contact_sis_id]
      ,co.student_web_id AS [Username]
      ,NULL AS [Password]
      ,NULL AS [Unweighted_gpa]
      ,NULL AS [Weighted_gpa]
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.student_contacts_static sc
  ON co.student_number = sc.student_number
 AND co.[db_name] = sc.[db_name]
 AND sc.contact_type IN ('emerg1', 'emerg2', 'emerg3', 'emerg4', 'emerg5', 'parent1'
                        ,'parent2', 'release1', 'release2','release3', 'release4', 'release5')
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level != 99

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