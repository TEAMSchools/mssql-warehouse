CREATE OR ALTER VIEW
  extracts.powerschool_autocomm_students_easyiep AS
SELECT
  student_number,
  CONVERT(NVARCHAR, nj_se_referraldate, 101) AS [S_NJ_STU_X.Referral_Date],
  /* trunk-ignore(sqlfluff/L016) */
  CONVERT(NVARCHAR, nj_se_parentalconsentdate, 101) AS [S_NJ_STU_X.Parental_Consent_Eval_Date],
  /* trunk-ignore(sqlfluff/L016) */
  CONVERT(NVARCHAR, nj_se_eligibilityddate, 101) AS [S_NJ_STU_X.Eligibility_Determ_Date],
  NULL AS [S_NJ_STU_X.Early_Intervention_YN],
  /* trunk-ignore(sqlfluff/L016) */
  CONVERT(NVARCHAR, nj_se_initialiepmeetingdate, 101) AS [S_NJ_STU_X.Initial_IEP_Meeting_Date],
  nj_se_parental_consentobtained AS [S_NJ_STU_X.Parent_Consent_Obtain_Code],
  /* trunk-ignore(sqlfluff/L016) */
  CONVERT(NVARCHAR, nj_se_consenttoimplementdate, 101) AS [S_NJ_STU_X.Parent_Consent_Intial_IEP_Date],
  /* trunk-ignore(sqlfluff/L016) */
  CONVERT(NVARCHAR, nj_se_lastiepmeetingdate, 101) AS [S_NJ_STU_X.Annual_IEP_Review_Meeting_Date],
  special_education_code AS [S_NJ_STU_X.SpecialEd_Classification],
  CONVERT(NVARCHAR, nj_se_reevaluationdate, 101) AS [S_NJ_STU_X.Reevaluation_Date],
  nj_se_delayreason AS [S_NJ_STU_X.Initial_Process_Delay_Reason],
  nj_se_placement AS [S_NJ_STU_X.Special_Education_Placement],
  nj_timeinregularprogram AS [S_NJ_STU_X.Time_In_Regular_Program],
  CASE
    WHEN ti_serv_counseling = 'Y' THEN 1
    WHEN ti_serv_counseling = 'N' THEN 0
  END AS [S_NJ_STU_X.Counseling_Services_YN],
  CASE
    WHEN ti_serv_occup = 'Y' THEN 1
    WHEN ti_serv_occup = 'N' THEN 0
  END AS [S_NJ_STU_X.Occupational_Therapy_Serv_YN],
  CASE
    WHEN ti_serv_physical = 'Y' THEN 1
    WHEN ti_serv_physical = 'N' THEN 0
  END AS [S_NJ_STU_X.Physical_Therapy_Services_YN],
  CASE
    WHEN ti_serv_speech = 'Y' THEN 1
    WHEN ti_serv_speech = 'N' THEN 0
  END AS [S_NJ_STU_X.Speech_Lang_Theapy_Services_YN],
  CASE
    WHEN ti_serv_other = 'Y' THEN 1
    WHEN ti_serv_other = 'N' THEN 0
  END AS [S_NJ_STU_X.Other_Related_Services_YN],
  spedlep AS [STUDENTCOREFIELDS.SPEDLEP],
  CASE
    WHEN special_education_code = '00' THEN '1'
  END AS [S_NJ_STU_X.Determined_Ineligible_YN],
  [db_name]
FROM
  gabby.easyiep.njsmart_powerschool_clean_static
WHERE
  academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND rn_stu_yr = 1
