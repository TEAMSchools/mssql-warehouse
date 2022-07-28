CREATE OR ALTER VIEW easyiep.njsmart_powerschool_clean AS

SELECT _file
      ,_line
      ,state_studentnumber
      ,student_number
      ,academic_year
      ,case_manager
      ,special_education
      ,nj_se_delayreason
      ,nj_se_placement
      ,nj_timeinregularprogram
      ,nj_se_referraldate
      ,nj_se_parentalconsentdate
      ,nj_se_eligibilityddate
      ,nj_se_initialiepmeetingdate
      ,nj_se_parental_consentobtained
      ,nj_se_consenttoimplementdate
      ,nj_se_lastiepmeetingdate
      ,nj_se_reevaluationdate
      ,ti_serv_counseling
      ,ti_serv_occup
      ,ti_serv_physical
      ,ti_serv_speech
      ,ti_serv_other
      ,iepgraduation_attendance
      ,iepgraduation_course_requirement
      ,iepbegin_date
      ,iepend_date
      ,effective_date AS effective_start_date
      ,CASE
        WHEN special_education = '' THEN NULL
        WHEN special_education IS NULL THEN NULL
        WHEN nj_se_parental_consentobtained = 'R' THEN NULL
        WHEN special_education IN ('00','99') THEN NULL
        WHEN special_education = '17' THEN 'SPED SPEECH'
        ELSE 'SPED'
       END AS spedlep
      ,CASE 
        WHEN nj_se_parental_consentobtained = 'R' THEN NULL
        WHEN special_education = '01' THEN 'AI'
        WHEN special_education = '02' THEN 'AUT'
        WHEN special_education = '03' THEN 'CMI'
        WHEN special_education = '04' THEN 'CMO'
        WHEN special_education = '05' THEN 'CSE'
        WHEN special_education = '06' THEN 'CI'
        WHEN special_education = '07' THEN 'ED'
        WHEN special_education = '08' THEN 'MD'
        WHEN special_education = '09' THEN 'DB'
        WHEN special_education = '10' THEN 'OI'
        WHEN special_education = '11' THEN 'OHI'
        WHEN special_education = '12' THEN 'PSD'
        WHEN special_education = '13' THEN 'SM'
        WHEN special_education = '14' THEN 'SLD'
        WHEN special_education = '15' THEN 'TBI'
        WHEN special_education = '16' THEN 'VI'
        WHEN special_education = '17' THEN 'ESLS'
        WHEN special_education = '99' THEN '99'
        WHEN special_education = '00' THEN '00'
       END AS special_education_code
      ,COALESCE(
         DATEADD(DAY, -1
          ,LEAD(effective_date, 1) OVER(PARTITION BY student_number, academic_year ORDER BY effective_date ASC)
         )
        ,DATEFROMPARTS(academic_year + 1, 6, 30)
       ) AS effective_end_date
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year 
           ORDER BY effective_date DESC) AS rn_stu_yr
FROM
    (
     SELECT _file
           ,_line
           ,row_hash
           ,state_studentnumber
           ,iepgraduation_attendance
           ,iepgraduation_course_requirement
           ,case_manager
           ,effective_date
           ,academic_year
           ,CONVERT(DATE, nj_se_referraldate) AS nj_se_referraldate
           ,CONVERT(DATE, nj_se_parentalconsentdate) AS nj_se_parentalconsentdate
           ,CONVERT(DATE, nj_se_eligibilityddate) AS nj_se_eligibilityddate
           ,CONVERT(DATE, nj_se_initialiepmeetingdate) AS nj_se_initialiepmeetingdate
           ,CONVERT(DATE, nj_se_consenttoimplementdate) AS nj_se_consenttoimplementdate
           ,CONVERT(DATE, nj_se_lastiepmeetingdate) AS nj_se_lastiepmeetingdate
           ,CONVERT(DATE, nj_se_reevaluationdate) AS nj_se_reevaluationdate
           ,CONVERT(DATE, iepbegin_date) AS iepbegin_date
           ,CONVERT(DATE, iepend_date) AS iepend_date
           ,CONVERT(FLOAT, nj_timeinregularprogram) AS nj_timeinregularprogram
           ,CONVERT(VARCHAR(2), nj_se_delayreason) AS nj_se_delayreason
           ,CONVERT(VARCHAR(2), nj_se_placement) AS nj_se_placement
           ,CONVERT(VARCHAR(1), nj_se_parental_consentobtained) AS nj_se_parental_consentobtained
           ,CONVERT(VARCHAR(1), ti_serv_counseling) AS ti_serv_counseling
           ,CONVERT(VARCHAR(1), ti_serv_occup) AS ti_serv_occup
           ,CONVERT(VARCHAR(1), ti_serv_physical) AS ti_serv_physical
           ,CONVERT(VARCHAR(1), ti_serv_speech) AS ti_serv_speech
           ,CONVERT(VARCHAR(1), ti_serv_other) AS ti_serv_other
           ,CONVERT(INT, TRY_PARSE(CONVERT(VARCHAR(32), student_number) AS INT)) AS student_number
           ,RIGHT('0' + CONVERT(VARCHAR, special_education), 2) AS special_education
           ,ROW_NUMBER() OVER(PARTITION BY row_hash, academic_year ORDER BY effective_date ASC) AS rn_row_asc
     FROM easyiep.njsmart_powerschool
    ) sub
WHERE rn_row_asc = 1
