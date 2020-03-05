WITH att AS (
SELECT psa.studentid
      ,psa.db_name
      ,psa.yearid
      ,SUM(psa.attendancevalue) AS CumulativeDaysPresent
      ,SUM(psa.membershipvalue) AS CumulativeDaysInMembership

FROM gabby.powerschool.ps_adaadm_daily_ctod_current_static psa

WHERE psa.calendardate <= CAST(SYSDATETIME() AS DATE)

GROUP BY psa.studentid
        ,psa.db_name
        ,psa.yearid
)

,race AS (
SELECT student_number
      ,CASE WHEN RaceAmericanIndian = 'I' THEN 'Y' ELSE 'N' END AS RaceAmericanIndian
      ,CASE WHEN RaceAsian = 'A' THEN 'Y' ELSE 'N' END AS RaceAsian
      ,CASE WHEN RaceBlack = 'B' THEN 'Y' ELSE 'N' END AS RaceBlack
      ,CASE WHEN RacePacific = 'P' THEN 'Y' ELSE 'N' END AS RacePacific
      ,CASE WHEN RaceWhite = 'W' THEN 'Y' ELSE 'N' END AS RaceWhite

FROM(
SELECT student_number
      ,[I] AS RaceAmericanIndian
      ,[A] AS RaceAsian
      ,[B] AS RaceBlack
      ,[P] AS RacePacific
      ,[W] AS RaceWhite

FROM (
SELECT s.student_number
      ,sr.racecd

FROM powerschool.students s
LEFT JOIN powerschool.studentrace sr
  ON s.id = sr.studentid
 AND s.db_name = sr.db_name
     )sub

PIVOT
(
MAX(racecd)
FOR racecd IN ([I],[A],[B],[P],[W])
) AS pvt
)sub2
)

SELECT co.db_name AS helper_db_name
      ,co.region as helper_region
      ,co.enroll_status AS helper_enroll
      ,co.school_name AS helper_school_name
      ,co.schoolid AS helper_schoolid
      ,co.specialed_classification AS helper_sped
      ,co.entrydate AS helper_entrydate
      ,s.city AS helper_city

      ,co.student_number AS LocalIdentificationNumber
      ,COALESCE(co.state_studentnumber,'') AS StateIdentificationNumber
      ,co.first_name AS FirstName
      ,co.middle_name AS MiddleName
      ,co.last_name AS LastName
      ,'' AS GenerationCodeSuffix
      ,co.gender AS Gender
      ,CONVERT(VARCHAR, co.dob, 112) AS DateofBirth
      ,COALESCE(nj.cityofbirth,'') AS CityofBirth
      ,COALESCE(nj.stateofbirth,'') AS StateOfBirth
      ,nj.countryofbirth
      ,CASE WHEN s.fedethnicity = 1 THEN 'Y'
            WHEN s.fedethnicity = 0 THEN 'N'
            ELSE NULL END AS Ethnicity
      ,r.RaceAmericanIndian AS RaceAmericanIndian
      ,r.RaceAsian AS RaceAsian
      ,r.RaceBlack AS RaceBlack
      ,r.RacePacific AS RacePacific
      ,r.RaceWhite AS RaceWhite
      ,CASE WHEN co.enroll_status = 0 THEN 'A'
            WHEN co.enroll_status IN (2,3) THEN 'I'
            ELSE NULL END AS [Status]
      ,'F' AS EnrollmentType
      ,nj.countycoderesident AS CountyCodeResident
      ,nj.districtcoderesident AS DistrictCodeResident
      ,nj.schoolcoderesident AS SchoolCodeResident
      ,CONVERT(VARCHAR, s.districtentrydate, 112) AS DistrictEntryDate
      ,CASE WHEN co.db_name = 'kippnewark' THEN 80
            WHEN co.db_name = 'kippcamden' THEN '07'
            ELSE NULL END AS CountyCodeReceiving
      ,CASE WHEN co.db_name = 'kippnewark' THEN 7325
            WHEN co.db_name = 'kippcamden' THEN 1799
            ELSE NULL END AS DistrictCodeReceiving
      ,CASE WHEN co.db_name = 'kippnewark' THEN 965
            WHEN co.db_name = 'kippcamden' THEN 111
            ELSE NULL END AS SchoolCodeReceiving
      ,CASE WHEN co.db_name = 'kippnewark' THEN 80
            WHEN co.db_name = 'kippcamden' THEN '07'
            ELSE NULL END AS CountyCodeAttending
      ,CASE WHEN co.db_name = 'kippnewark' THEN 7325
            WHEN co.db_name = 'kippcamden' THEN 1799
            ELSE NULL END AS DistrictCodeAttending
      ,CASE WHEN co.db_name = 'kippnewark' THEN 965
            WHEN co.db_name = 'kippcamden' THEN 111
            ELSE NULL END AS SchoolCodeAttending
      ,co.cohort AS YearOfGraduation
      ,CONVERT(VARCHAR, s.entrydate, 112) AS SchoolEntryDate
      ,CASE WHEN co.enroll_status = 0 THEN ''
            WHEN co.enroll_status IN (2,3) THEN CONVERT(VARCHAR, co.exitdate, 112)
            ELSE '' END AS SchoolExitDate
      ,co.exitcode AS SchoolExitWithdrawalCode
      ,a.CumulativeDaysInMembership AS CumulativeDaysInMembership
      ,a.CumulativeDaysPresent AS CumulativeDaysPresent
      ,(a.CumulativeDaysInMembership - a.CumulativeDaysPresent) AS CumulativeDaysTowardsTruancy
      ,CASE WHEN co.db_name = 'kippnewark' THEN '07'
            WHEN co.db_name = 'kippcamden' THEN '07'
            ELSE NULL END AS TuitionCode
      ,CASE WHEN co.lunchstatus IN ('P','D') THEN 'N'
            ELSE co.lunchstatus END AS FreeandReducedRateLunchStatus
      ,CASE WHEN co.grade_level = 0 THEN 'KF'
            ELSE CAST(co.grade_level AS varchar) END AS GradeLevel
      ,CASE WHEN co.grade_level = 0 THEN 'KF'
            ELSE CAST(co.grade_level AS varchar) END AS ProgramTypeCode
      ,CASE WHEN co.is_retained_year = 1 THEN 'Y'
            WHEN co.is_retained_year = 0 THEN 'N'
            ELSE NULL END AS Retained
      ,CASE WHEN co.specialed_classification = 'AI' THEN '01'
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
            ELSE '' END AS SpecialEducationClassification
      ,COALESCE(CONVERT(VARCHAR, nj.lepbegindate, 112),'') AS ELLIdentificationDate
      ,CASE WHEN nj.lep_completion_date_refused = 1 THEN 'REFUSED'
            ELSE COALESCE(CONVERT(VARCHAR, nj.lependdate, 112),'')
            END AS ELLExitDate
      ,'' AS NonPublic
      ,nj.residentmunicipalcode AS ResidentMunicipalCode
      ,CASE WHEN nj.military_connected_indicator IN (0,1,3,4) THEN 1
            WHEN nj.military_connected_indicator IS NULL THEN 1
            WHEN nj.military_connected_indicator = 2 THEN 2
            ELSE '' END AS MilitaryConnectedStudentIndicator
      ,'' AS ELAGraduationPathwayIndicator
      ,'' AS MathGraduationPathwayIndicator
      ,'' AS InDistrictPlacement
      ,'' AS LanguageInstructionEducationalProgram
      ,'' AS Biliterate
      ,'' AS WorldLanguageAssessment1	
      ,'' AS WorldLanguagesAssessed1	
      ,'' AS WorldLanguageAssessment2	
      ,'' AS WorldLanguagesAssessed2	
      ,'' AS WorldLanguageAssessment3	
      ,'' AS WorldLanguagesAssessed3	
      ,'' AS WorldLanguageAssessment4	
      ,'' AS WorldLanguagesAssessed4	
      ,'' AS WorldLanguageAssessment5	
      ,'' AS WorldLanguagesAssessed5


FROM powerschool.cohort_identifiers_static co
LEFT JOIN powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
 AND co.db_name = nj.db_name
LEFT JOIN powerschool.students s
  ON s.student_number = co.student_number
LEFT JOIN att a
  ON a.studentid = co.studentid
 AND a.db_name = co.db_name
LEFT JOIN race r
  ON r.student_number = co.student_number

WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.enroll_status NOT IN (1,3)
  AND co.db_name <> 'kippmiami'