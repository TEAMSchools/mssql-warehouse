CREATE OR ALTER VIEW
  extracts.clever_students AS
SELECT
  CAST(co.schoolid AS NVARCHAR(16)) AS [School_id],
  CAST(co.student_number AS NVARCHAR(16)) AS [Student_id],
  CAST(co.student_number AS NVARCHAR(16)) AS [Student_number],
  CASE
    WHEN co.region = 'KMS' THEN suf.fleid
    ELSE co.state_studentnumber
  END AS [State_id],
  co.last_name AS [Last_name],
  co.middle_name AS [Middle_name],
  co.first_name AS [First_name],
  CASE
    WHEN co.grade_level = 0 THEN 'Kindergarten'
    ELSE CAST(co.grade_level AS NVARCHAR(2))
  END AS [Grade],
  co.gender AS [Gender],
  co.cohort AS [Graduation_year],
  CONVERT(VARCHAR, co.dob, 101) AS [DOB],
  co.ethnicity AS [Race],
  NULL AS [Hispanic_Latino],
  NULL AS [Home_language],
  CASE
    WHEN co.lep_status = 1 THEN 'Y'
    ELSE 'N'
  END AS [Ell_status],
  NULL AS [Frl_status],
  CASE
    WHEN co.iep_status IN ('SPED', 'SPED SPEECH') THEN 'Y'
    ELSE 'N'
  END AS [IEP_status],
  NULL AS [Student_street],
  NULL AS [Student_city],
  NULL AS [Student_state],
  NULL AS [Student_zip],
  co.student_web_id + '@teamstudents.org' AS [Student_email],
  sc.person_relationship AS [Contact_relationship],
  CASE
    WHEN sc.person_type IN ('mother', 'father', 'contact1', 'contact2') THEN 'primary'
    ELSE sc.person_type
  END AS [Contact_type],
  COALESCE(sc.person_name, sc.person_type) AS [Contact_name],
  CAST(
    LEFT(
      gabby.utilities.STRIP_CHARACTERS (sc.contact, '^0-9'),
      10
    ) AS VARCHAR(16)
  ) AS [Contact_phone],
  CASE
    WHEN sc.contact_type = 'home' THEN 'Home'
    WHEN sc.contact_type = 'mobile' THEN 'Cell'
    WHEN sc.contact_type = 'daytime' THEN 'Work'
  END AS [Contact_phone_type],
  NULL AS [Contact_email],
  NULL AS [Contact_sis_id],
  co.student_web_id AS [Username],
  NULL AS [Password],
  gpa.[cumulative_Y1_gpa] AS [Unweighted_gpa],
  gpa.[cumulative_Y1_gpa_unweighted] AS [Weighted_gpa]
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.student_contacts_static AS sc ON (
    co.student_number = sc.student_number
    AND co.[db_name] = sc.[db_name]
    AND sc.contact_category = 'Phone'
    AND sc.person_type != 'self'
  )
  LEFT JOIN gabby.powerschool.gpa_cumulative AS gpa ON (
    co.studentid = gpa.studentid
    AND co.schoolid = gpa.schoolid
    AND co.[db_name] = gpa.[db_name]
  )
  LEFT JOIN gabby.powerschool.u_studentsuserfields AS suf ON (
    co.students_dcid = suf.studentsdcid
    AND co.[db_name] = suf.[db_name]
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
  AND co.reporting_school_name != 'Out of District'
