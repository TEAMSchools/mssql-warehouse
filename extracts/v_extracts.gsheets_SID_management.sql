USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_sid_management AS

WITH att AS (
  SELECT psa.studentid
        ,psa.[db_name]
        ,psa.yearid
        ,SUM(psa.attendancevalue) AS CumulativeDaysPresent
        ,SUM(psa.membershipvalue) AS CumulativeDaysInMembership
  FROM gabby.powerschool.ps_adaadm_daily_ctod_current_static psa
  WHERE psa.membershipvalue = 1
    AND psa.calendardate <= CAST(GETDATE() AS DATE)
  GROUP BY psa.studentid
          ,psa.yearid
          ,psa.[db_name]
 )

,race AS (
  SELECT p.studentid
        ,p.[db_name]
        ,p.W
        ,p.P
        ,p.B
        ,p.A
        ,p.I
  FROM 
      (
       SELECT sr.studentid
             ,sr.[db_name]
             ,sr.racecd
             ,'Y' AS yn
       FROM gabby.powerschool.studentrace sr
      )sub
  PIVOT (
    MAX(yn)
    FOR racecd IN ([I],[A],[B],[P],[W])
   ) p
 )

SELECT co.region AS helper_region
      ,co.enroll_status AS helper_enroll_status
      ,co.school_name AS helper_school_name
      ,co.schoolid AS helper_schoolid
      ,co.specialed_classification AS helper_sped
      ,co.entrydate AS helper_entrydate
      ,co.city AS helper_city

      ,co.student_number AS LocalIdentificationNumber
      ,co.state_studentnumber AS StateIdentificationNumber
      ,co.first_name AS FirstName
      ,co.middle_name AS MiddleName
      ,co.last_name AS LastName
      ,NULL AS GenerationCodeSuffix
      ,co.gender AS Gender
      ,CONVERT(VARCHAR, co.dob, 112) AS DateofBirth

      ,nj.cityofbirth AS CityofBirth
      ,nj.stateofbirth AS StateOfBirth
      ,nj.countryofbirth AS CountryOfBirth

      ,CASE
        WHEN s.fedethnicity = 1 THEN 'Y'
        WHEN s.fedethnicity = 0 THEN 'N'
        ELSE NULL 
       END AS Ethnicity

      ,COALESCE(r.I, 'N') AS RaceAmericanIndian
      ,COALESCE(r.A, 'N') AS RaceAsian
      ,COALESCE(r.B, 'N') AS RaceBlack
      ,COALESCE(r.P, 'N') AS RacePacific
      ,COALESCE(r.W, 'N') AS RaceWhite

      ,CASE 
        WHEN co.enroll_status = 0 THEN 'A'
        WHEN co.enroll_status IN (2, 3) THEN 'I'
        ELSE NULL 
       END AS [Status]
      ,'F' AS EnrollmentType

      ,nj.countycoderesident AS CountyCodeResident
      ,nj.districtcoderesident AS DistrictCodeResident
      ,nj.schoolcoderesident AS SchoolCodeResident

      ,CONVERT(VARCHAR, s.districtentrydate, 112) AS DistrictEntryDate

      ,CASE 
        WHEN co.region = 'TEAM' THEN '80'
        WHEN co.region = 'KCNA' THEN '07'
        ELSE NULL 
       END AS CountyCodeReceiving
      ,CASE 
        WHEN co.region = 'TEAM' THEN '7325'
        WHEN co.region = 'KCNA' THEN '1799'
        ELSE NULL 
       END AS DistrictCodeReceiving
      ,CASE 
        WHEN co.region = 'TEAM' THEN '965'
        WHEN co.region = 'KCNA' THEN '111'
        ELSE NULL
       END AS SchoolCodeReceiving
      ,CASE 
        WHEN co.region = 'TEAM' THEN '80'
        WHEN co.region = 'KCNA' THEN '07'
        ELSE NULL 
       END AS CountyCodeAttending
      ,CASE 
        WHEN co.region = 'TEAM' THEN '7325'
        WHEN co.region = 'KCNA' THEN '1799'
        ELSE NULL 
       END AS DistrictCodeAttending
      ,CASE
        WHEN co.region = 'TEAM' THEN '965'
        WHEN co.region = 'KCNA' THEN '111'
        ELSE NULL 
       END AS SchoolCodeAttending
      ,co.cohort AS YearOfGraduation
      ,CONVERT(VARCHAR, s.entrydate, 112) AS SchoolEntryDate
      ,CASE 
        WHEN co.enroll_status = 0 THEN NULL
        WHEN co.enroll_status IN (2,3) THEN CONVERT(VARCHAR, co.exitdate, 112)
        ELSE NULL
       END AS SchoolExitDate
      ,co.exitcode AS SchoolExitWithdrawalCode

      ,a.CumulativeDaysInMembership
      ,a.CumulativeDaysPresent
      ,(a.CumulativeDaysInMembership - a.CumulativeDaysPresent) AS CumulativeDaysTowardsTruancy

      ,CASE 
        WHEN co.region = 'TEAM' THEN '07'
        WHEN co.region = 'KCNA' THEN '07'
        ELSE NULL 
       END AS TuitionCode
      ,CASE 
        WHEN co.lunchstatus IN ('P','D') THEN 'N'
        ELSE co.lunchstatus 
       END AS FreeandReducedRateLunchStatus
      ,CASE 
        WHEN co.grade_level = 0 THEN 'KF'
        ELSE CONVERT(VARCHAR, co.grade_level) 
       END AS GradeLevel
      ,CASE 
        WHEN co.grade_level = 0 THEN 'KF'
        ELSE CONVERT(VARCHAR, co.grade_level) 
       END AS ProgramTypeCode
      ,CASE 
        WHEN co.is_retained_year = 1 THEN 'Y'
        WHEN co.is_retained_year = 0 THEN 'N'
        ELSE NULL 
       END AS Retained
      ,CASE 
        WHEN co.specialed_classification = 'AI' THEN '01'
        WHEN co.specialed_classification = 'AUT' THEN '02'
        WHEN co.specialed_classification = 'CI' THEN '06'
        WHEN co.specialed_classification = 'CMI' THEN '03'
        WHEN co.specialed_classification = 'CMO' THEN '04'
        WHEN co.specialed_classification = 'ED' THEN '07'
        WHEN co.specialed_classification = 'ESLS' THEN '17'
        WHEN co.specialed_classification = 'MD' THEN '08'
        WHEN co.specialed_classification = 'OHI' THEN '11'
        WHEN co.specialed_classification = 'OI' THEN '10'
        WHEN co.specialed_classification = 'PSD' THEN '12'
        WHEN co.specialed_classification = 'SLD' THEN '14'
        WHEN co.specialed_classification = 'TBI' THEN '15'
        WHEN co.specialed_classification = 'VI' THEN '16'
        ELSE NULL 
       END AS SpecialEducationClassification
      ,CONVERT(VARCHAR, nj.lepbegindate, 112) AS ELLIdentificationDate
      ,CASE 
        WHEN nj.lep_completion_date_refused = 1 THEN 'REFUSED'
        ELSE CONVERT(VARCHAR, nj.lependdate, 112)
       END AS ELLExitDate
      ,NULL AS NonPublic
      ,nj.residentmunicipalcode AS ResidentMunicipalCode
      ,CASE 
        WHEN nj.military_connected_indicator = 2 THEN 2
        WHEN nj.military_connected_indicator IN (0, 1, 3, 4) THEN 1
        WHEN nj.military_connected_indicator IS NULL THEN 1
        ELSE NULL 
       END AS MilitaryConnectedStudentIndicator

      ,NULL AS ELAGraduationPathwayIndicator
      ,NULL AS MathGraduationPathwayIndicator
      ,NULL AS InDistrictPlacement
      ,NULL AS LanguageInstructionEducationalProgram
      ,NULL AS Biliterate
      ,NULL AS WorldLanguageAssessment1
      ,NULL AS WorldLanguagesAssessed1
      ,NULL AS WorldLanguageAssessment2
      ,NULL AS WorldLanguagesAssessed2
      ,NULL AS WorldLanguageAssessment3
      ,NULL AS WorldLanguagesAssessed3
      ,NULL AS WorldLanguageAssessment4
      ,NULL AS WorldLanguagesAssessed4
      ,NULL AS WorldLanguageAssessment5
      ,NULL AS WorldLanguagesAssessed5
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
LEFT JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
 AND co.[db_name] = nj.[db_name]
LEFT JOIN att a
  ON co.studentid = a.studentid
 AND co.[db_name] = a.[db_name]
LEFT JOIN race r WITH(FORCESEEK)
  ON co.studentid = r.studentid
 AND co.[db_name] = r.[db_name]
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level <> 99
  AND co.[db_name] IN ('kippnewark', 'kippcamden')
