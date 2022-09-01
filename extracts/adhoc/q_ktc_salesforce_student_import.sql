SELECT CASE
        WHEN co.schoolid = 133570965 THEN 'TEAM Academy, a KIPP school'
        WHEN co.schoolid = 73252 THEN 'Rise Academy, a KIPP school'
        WHEN co.schoolid = 73253 THEN 'Newark Collegiate Academy, a KIPP school'
        WHEN co.schoolid = 179902 THEN 'KIPP Lanning Square Middle School'
       END AS [KIPP School of Enrollment]
      ,co.last_name AS [Last Name]
      ,co.first_name AS [First Name]
      ,LEFT(co.middle_name, 1) AS [Middle Initial]
      ,co.cohort AS [HS Class Cohort]
      ,'PowerSchool ID' AS [Student ID Type]
      ,co.student_number AS [Student ID #]
      ,u.name AS [Contact Owner Name]
      ,u.id AS [Contact Owner Salesforce ID]
      ,co.entrydate AS [School Enrollment Date]
      ,co.grade_level AS [School Enrollment Grade]
      ,CASE
        WHEN co.enroll_status = 0 THEN 'Attending'
        WHEN co.enroll_status = 2 THEN 'Transferred out'
        WHEN co.enroll_status = 3 THEN 'Graduated'
       END AS [Enrollment Status]
      ,co.grade_level AS [School Ending Grade]
      ,co.exitdate AS [School Exit Date]
      ,co.dob AS [Date of Birth]
      ,CASE
        WHEN co.gender = 'M' THEN 'Male'
        WHEN co.gender = 'F' THEN 'Female'
       END AS [Gender]
      ,CASE
        WHEN co.ethnicity = 'I' THEN 'American Indian/Alaska Native'
        WHEN co.ethnicity = 'A' THEN 'Asian'
        WHEN co.ethnicity = 'B' THEN 'Black/African American'
        WHEN co.ethnicity = 'H' THEN 'Hispanic/Latino'
        WHEN co.ethnicity = 'P' THEN 'Native Hawaiian/Pacific Islander'
        WHEN co.ethnicity = 'W' THEN 'White'
        WHEN co.ethnicity = 'T' THEN 'Two or More Races'
       END AS [Ethnicity]
      ,co.street AS [Street Address]
      ,co.city AS [City]
      ,co.state AS [State]
      ,co.zip AS [Zip]
      ,co.student_web_id + '@teamstudents.org' AS [Student E-mail]
      ,NULL AS [Student Mobile]
      ,co.home_phone AS [Student Home Phone]
      ,LTRIM(RTRIM(CASE
                     WHEN CHARINDEX(',', co.mother) = 0 AND CHARINDEX(' ', co.mother) = 0 THEN co.mother
                     WHEN (CHARINDEX(',', co.mother) - 1) < 0 THEN LEFT(co.mother, (CHARINDEX(' ', co.mother) - 1))
                     ELSE SUBSTRING(co.mother, (CHARINDEX(',', co.mother) + 2), LEN(co.mother))
                   END)) AS [Parent 1 First Name]
      ,LTRIM(RTRIM(CASE
                    WHEN CHARINDEX(',', co.mother) = 0 AND CHARINDEX(' ', co.mother) = 0 THEN co.mother
                    WHEN (CHARINDEX(',', co.mother) - 1) < 0 THEN SUBSTRING(co.mother, (CHARINDEX(' ', co.mother) + 1), LEN(co.mother))
                    ELSE LEFT(co.mother, (CHARINDEX(',', co.mother) - 1))
                   END)) AS [Parent 1 Last Name]
      ,co.parent_motherdayphone AS [Parent 1 Work Phone]
      ,co.mother_home_phone AS [Parent 1 Home Phone]
      ,REPLACE(REPLACE(CAST(co.guardianemail AS VARCHAR(MAX)), CHAR(10), ''), CHAR(13), '') AS [Parent 1 E-mail]
      ,LTRIM(RTRIM(CASE
                     WHEN CHARINDEX(',', co.father) = 0 AND CHARINDEX(' ', co.father) = 0 THEN co.father
                     WHEN (CHARINDEX(',', co.father) - 1) < 0 THEN LEFT(co.father, (CHARINDEX(' ', co.father) - 1))
                     ELSE SUBSTRING(co.father, (CHARINDEX(',', co.father) + 2), LEN(co.father))
                   END)) AS [Parent 2 First Name]
      ,LTRIM(RTRIM(CASE
                    WHEN CHARINDEX(',', co.father) = 0 AND CHARINDEX(' ', co.father) = 0 THEN co.father
                    WHEN (CHARINDEX(',', co.father) - 1) < 0 THEN SUBSTRING(co.father, (CHARINDEX(' ', co.father) + 1), LEN(co.father))
                    ELSE LEFT(co.father, (CHARINDEX(',', co.father) - 1))
                   END)) AS [Parent 2 Last Name]
      ,co.parent_fatherdayphone AS [Parent 2 Work Phone]
      ,co.father_home_phone AS [Parent 2 Home Phone]
      ,REPLACE(REPLACE(co.guardianemail, CHAR(10), ''), CHAR(13), '') AS [Parent 2 E-mail]
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.alumni.contact s
  ON co.student_number = s.school_specific_id_c
LEFT JOIN gabby.alumni.[user] u
  ON s.owner_id = u.id
WHERE co.schoolid IN (73252, 73253, 133570965, 179902)
  AND co.rn_undergrad = 1
  AND co.grade_level <> 99