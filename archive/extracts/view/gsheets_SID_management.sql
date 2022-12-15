USE gabby GO
CREATE OR ALTER VIEW
  extracts.gsheets_sid_management AS
WITH
  att AS (
    SELECT
      sub.studentid,
      sub.[db_name],
      SUM(sub.attendancevalue) AS CumulativeDaysPresent,
      SUM(sub.membershipvalue) AS CumulativeDaysInMembership,
      SUM(
        CASE
          WHEN sub.membershipvalue = 1
          AND sub.is_inperson = 1 THEN 1
          ELSE 0
        END
      ) AS membership_in_person,
      SUM(
        CASE
          WHEN sub.attendancevalue = 1
          AND sub.is_inperson = 1 THEN 1
          ELSE 0
        END
      ) AS present_in_person
    FROM
      (
        SELECT
          mem.studentid,
          mem.[db_name],
          mem.membershipvalue,
          CAST(mem.attendancevalue AS FLOAT) AS attendancevalue,
          CASE
            WHEN hb.specprog_name = 'Hybrid (SC) - Cohort D'
            AND cal.[type] <> 'AR' THEN 1
            WHEN hb.specprog_name = 'Hybrid - Cohort A'
            AND cal.[type] = 'BCR' THEN 1
            WHEN hb.specprog_name = 'Hybrid - Cohort B'
            AND cal.[type] = 'ACR' THEN 1
            ELSE 0
          END AS is_inperson
        FROM
          gabby.powerschool.ps_adaadm_daily_ctod_current_static AS mem
          INNER JOIN gabby.powerschool.calendar_day AS cal ON mem.schoolid = cal.schoolid
          AND mem.calendardate = cal.date_value
          AND mem.[db_name] = cal.[db_name]
          LEFT JOIN gabby.powerschool.spenrollments_gen_static AS hb ON mem.studentid = hb.studentid
          AND mem.calendardate (BETWEEN hb.enter_date AND hb.exit_date)
          AND mem.[db_name] = hb.[db_name]
          AND hb.specprog_name IN (
            'Hybrid - Cohort A',
            'Hybrid - Cohort B',
            'Remote - Cohort C',
            'Hybrid (SC) - Cohort D'
          )
        WHERE
          mem.calendardate <= CURRENT_TIMESTAMP
          AND mem.membershipvalue > 0
      ) sub
    GROUP BY
      sub.studentid,
      sub.[db_name]
  ),
  race AS (
    SELECT
      p.studentid,
      p.[db_name],
      p.W,
      p.P,
      p.B,
      p.A,
      p.I
    FROM
      (
        SELECT
          sr.studentid,
          sr.[db_name],
          sr.racecd,
          'Y' AS yn
        FROM
          gabby.powerschool.studentrace AS sr
      ) sub PIVOT (
        MAX(yn) FOR racecd IN ([I], [A], [B], [P], [W])
      ) p
  )
SELECT
  co.region AS helper_region,
  co.enroll_status AS helper_enroll_status,
  co.school_name AS helper_school_name,
  co.schoolid AS helper_schoolid,
  co.specialed_classification AS helper_sped,
  co.entrydate AS helper_entrydate,
  co.city AS helper_city,
  co.student_number AS LocalIdentificationNumber,
  co.state_studentnumber AS StateIdentificationNumber,
  co.first_name AS FirstName,
  co.middle_name AS MiddleName,
  co.last_name AS LastName,
  NULL AS GenerationCodeSuffix,
  co.gender AS Gender,
  CAST(co.dob, 112 AS VARCHAR) AS DateofBirth,
  nj.cityofbirth AS CityofBirth,
  nj.stateofbirth AS StateOfBirth,
  nj.countryofbirth AS CountryOfBirth,
  CASE
    WHEN s.fedethnicity = 1 THEN 'Y'
    WHEN s.fedethnicity = 0 THEN 'N'
    ELSE NULL
  END AS Ethnicity,
  COALESCE(r.I, 'N') AS RaceAmericanIndian,
  COALESCE(r.A, 'N') AS RaceAsian,
  COALESCE(r.B, 'N') AS RaceBlack,
  COALESCE(r.P, 'N') AS RacePacific,
  COALESCE(r.W, 'N') AS RaceWhite,
  CASE
    WHEN co.enroll_status = 0 THEN 'A'
    WHEN co.enroll_status IN (2, 3) THEN 'I'
    ELSE NULL
  END AS [Status],
  'F' AS EnrollmentType /* needs to be updated to live PS field */,
  nj.countycoderesident AS CountyCodeResident,
  nj.districtcoderesident AS DistrictCodeResident,
  nj.schoolcoderesident AS SchoolCodeResident,
  CAST(s.districtentrydate, 112 AS VARCHAR) AS DistrictEntryDate,
  CASE
    WHEN co.region = 'TEAM' THEN '80'
    WHEN co.region = 'KCNA' THEN '07'
    ELSE NULL
  END AS CountyCodeReceiving,
  CASE
    WHEN co.region = 'TEAM' THEN '7325'
    WHEN co.region = 'KCNA' THEN '1799'
    ELSE NULL
  END AS DistrictCodeReceiving,
  CASE
    WHEN co.region = 'TEAM' THEN '965'
    WHEN co.region = 'KCNA' THEN '111'
    ELSE NULL
  END AS SchoolCodeReceiving,
  CASE
    WHEN co.region = 'TEAM' THEN '80'
    WHEN co.region = 'KCNA' THEN '07'
    ELSE NULL
  END AS CountyCodeAttending,
  CASE
    WHEN co.region = 'TEAM' THEN '7325'
    WHEN co.region = 'KCNA' THEN '1799'
    ELSE NULL
  END AS DistrictCodeAttending,
  CASE
    WHEN co.region = 'TEAM' THEN '965'
    WHEN co.region = 'KCNA' THEN '111'
    ELSE NULL
  END AS SchoolCodeAttending,
  co.cohort AS YearOfGraduation,
  CAST(s.entrydate, 112 AS VARCHAR) AS SchoolEntryDate,
  CASE
    WHEN co.enroll_status = 0 THEN NULL
    WHEN co.enroll_status IN (2, 3) THEN CAST(co.exitdate, 112 AS VARCHAR)
    ELSE NULL
  END AS SchoolExitDate,
  CASE
    WHEN co.exitcode = 'G1' THEN 'L'
    ELSE co.exitcode
  END AS SchoolExitWithdrawalCode,
  a.CumulativeDaysInMembership,
  a.CumulativeDaysPresent,
  (
    a.CumulativeDaysInMembership - a.CumulativeDaysPresent
  ) AS CumulativeDaysTowardsTruancy,
  CASE
    WHEN co.region = 'TEAM' THEN '07'
    WHEN co.region = 'KCNA' THEN '07'
    ELSE NULL
  END AS TuitionCode,
  CASE
    WHEN co.lunchstatus IN ('P', 'D') THEN 'N'
    ELSE co.lunchstatus
  END AS FreeandReducedRateLunchStatus,
  CASE
    WHEN co.grade_level = 0 THEN 'KF'
    ELSE CAST(co.grade_level AS VARCHAR)
  END AS GradeLevel,
  nj.programtypecode AS ProgramTypeCode,
  CASE
    WHEN co.is_retained_year = 1 THEN 'Y'
    WHEN co.is_retained_year = 0 THEN 'N'
    ELSE NULL
  END AS Retained,
  CASE
    WHEN co.specialed_classification = 'AI' THEN '01'
    WHEN co.specialed_classification = 'AUT' THEN '02'
    WHEN co.specialed_classification = 'CMI' THEN '03'
    WHEN co.specialed_classification = 'CMO' THEN '04'
    WHEN co.specialed_classification = 'CME' THEN '05'
    WHEN co.specialed_classification = 'CI' THEN '06'
    WHEN co.specialed_classification = 'ED' THEN '07'
    WHEN co.specialed_classification = 'MD' THEN '08'
    WHEN co.specialed_classification = 'OI' THEN '10'
    WHEN co.specialed_classification = 'OHI' THEN '11'
    WHEN co.specialed_classification = 'PSD' THEN '12'
    WHEN co.specialed_classification = 'SLD' THEN '14'
    WHEN co.specialed_classification = 'TBI' THEN '15'
    WHEN co.specialed_classification = 'VI' THEN '16'
    WHEN co.specialed_classification = 'ESLS' THEN '17'
    WHEN co.specialed_classification = '99' THEN '99'
    WHEN nj.determined_ineligible_yn = 1 THEN '00'
  END AS SpecialEducationClassification,
  CAST(nj.lepbegindate, 112 AS VARCHAR) AS ELLIdentificationDate,
  CASE
    WHEN nj.lep_completion_date_refused = 1 THEN 'REFUSED'
    ELSE CAST(nj.lependdate, 112 AS VARCHAR)
  END AS ELLExitDate,
  NULL AS NonPublic,
  nj.residentmunicipalcode AS ResidentMunicipalCode,
  CASE
    WHEN nj.military_connected_indicator = 2 THEN 2
    WHEN nj.military_connected_indicator IN (0, 1, 3, 4) THEN 1
    WHEN nj.military_connected_indicator IS NULL THEN 1
    ELSE NULL
  END AS MilitaryConnectedStudentIndicator,
  nj.graduation_pathway_ela AS ELAGraduationPathwayIndicator,
  nj.graduation_pathway_math AS MathGraduationPathwayIndicator,
  nj.indistrictplacement AS InDistrictPlacement,
  CASE
    WHEN nj.lepbegindate IS NOT NULL
    AND nj.lependdate IS NOT NULL THEN '3'
  END AS LanguageInstructionEducationalProgram,
  NULL AS Biliterate,
  NULL AS WorldLanguageAssessment1,
  NULL AS WorldLanguagesAssessed1,
  NULL AS WorldLanguageAssessment2,
  NULL AS WorldLanguagesAssessed2,
  NULL AS WorldLanguageAssessment3,
  NULL AS WorldLanguagesAssessed3,
  NULL AS WorldLanguageAssessment4,
  NULL AS WorldLanguagesAssessed4,
  NULL AS WorldLanguageAssessment5,
  NULL AS WorldLanguagesAssessed5,
  nj.gifted_and_talented AS GiftedAndTalentedStudent,
  nj.learningenvironment AS StudentLearningEnvironment,
  nj.internetconnectivity AS StudentInternetConnectivity,
  nj.federalhsmathtestingreq AS FederalHSMathTestingReq,
  nj.iepgradcourserequirement AS IEPGraduationCourseRequirement,
  nj.iepgraduationattendance AS IEPGraduationAttendance,
  CASE
    WHEN co.grade_level = 12 THEN nj.bridge_year
  END AS BridgeYear,
  CASE
    WHEN nj.lepbegindate IS NOT NULL
    AND nj.lependdate IS NOT NULL THEN 'OTH'
  END AS LIEPLanguageOfInstruction,
  NULL AS StudentDeviceOwner,
  NULL AS StudentDeviceType,
  a.CumulativeDaysInMembership - a.membership_in_person AS RemoteDaysInMembership,
  a.CumulativeDaysPresent - a.present_in_person AS RemoteDaysPresent
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.powerschool.students AS s ON co.student_number = s.student_number
  LEFT JOIN gabby.powerschool.s_nj_stu_x AS nj ON co.students_dcid = nj.studentsdcid
  AND co.[db_name] = nj.[db_name]
  LEFT JOIN att AS a ON co.studentid = a.studentid
  AND co.[db_name] = a.[db_name]
  LEFT JOIN race AS r
WITH
  (FORCESEEK) ON co.studentid = r.studentid
  AND co.[db_name] = r.[db_name]
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level <> 99
  AND co.[db_name] IN ('kippnewark', 'kippcamden')
