USE gabby
GO

CREATE OR ALTER VIEW tableau.compliance_school_register_summary AS

WITH schooldays AS (
  SELECT academic_year
        ,region
        ,MIN(n_days) AS n_days
  FROM
      (
       SELECT gabby.utilities.DATE_TO_SY(date_value) AS academic_year
             ,schoolid
             ,CASE WHEN schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region
             ,SUM(membershipvalue) AS N_days
       FROM gabby.powerschool.calendar_day       
       WHERE schoolid NOT IN (12345, 0, 999999) /* exclude summer school, grads, district */
         AND CONVERT(DATE,date_value) <= CONVERT(DATE,GETDATE())
       GROUP BY gabby.utilities.DATE_TO_SY(date_value)
               ,schoolid
      ) sub
  GROUP BY academic_year, region
 )

,att_mem AS (
  SELECT studentid
        ,yearid + 1990 AS academic_year
        ,SUM(CONVERT(INT,attendancevalue)) AS N_att
        ,SUM(CONVERT(INT,membershipvalue)) AS N_mem
  FROM gabby.powerschool.ps_adaadm_daily_ctod_static
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,yearid
 )

SELECT sub.academic_year      
      ,co.student_number
      ,co.state_studentnumber AS SID
      ,co.lastfirst
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.region      
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate
      ,co.specialed_classification AS sped_code
      ,CASE
        WHEN nj.programtypecode IS NOT NULL 
         AND nj.special_education_placement IN ('04','11')
               THEN CONVERT(VARCHAR,nj.programtypecode)
        WHEN co.grade_level = 0 THEN 'K'
        ELSE CONVERT(VARCHAR,co.grade_level)
       END AS report_grade_level      
      ,co.ethnicity
      ,ISNULL(co.ethnicity,'B') AS race_status
	     ,co.lunchstatus
      ,CASE
        WHEN co.lunchstatus IN ('F','R') THEN 'Low Income'
        WHEN co.lunchstatus = 'P' THEN 'Not Low Income'
        WHEN co.lunchstatus IS NULL THEN 'Not Low Income'
       END AS low_income_status
      ,co.iep_status AS sped
      ,CASE
        WHEN co.iep_status LIKE '%SPED%' THEN 'IEP'
        ELSE 'Not IEP'
       END AS IEP_status
      ,co.lep_status AS lep
      ,CASE 
        WHEN co.lep_status = 1 THEN 'LEP' 
        WHEN co.lep_status IS NULL THEN 'Not LEP'        
       END AS LEP_status
      ,d.N_days AS N_days_open
      ,CASE WHEN sub.N_mem > d.N_days THEN d.N_days ELSE sub.N_mem END AS N_days_possible
      ,CASE WHEN sub.N_att > d.N_days THEN d.N_days ELSE sub.N_att END AS N_days_present 
FROM att_mem sub
JOIN gabby.powerschool.cohort_identifiers_static co
  ON sub.studentid = co.studentid
 AND sub.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
JOIN schooldays d
  ON sub.academic_year = d.academic_year
 AND co.region = d.region