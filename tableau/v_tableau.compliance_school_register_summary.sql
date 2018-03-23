USE gabby
GO

CREATE OR ALTER VIEW tableau.compliance_school_register_summary AS

WITH schooldays AS (
  SELECT academic_year
        ,schoolid
        ,region
        ,n_days_school
        ,MIN(n_days_school) OVER(PARTITION BY academic_year, region) n_days_region_min
  FROM
      (
       SELECT CONVERT(INT,schoolid) AS schoolid
             ,CASE 
               WHEN schoolid LIKE '1799%' THEN 'KCNA' 
               WHEN schoolid LIKE '7325%' THEN 'TEAM' 
               WHEN schoolid = 133570965 THEN 'TEAM' 
              END AS region
             ,gabby.utilities.DATE_TO_SY(date_value) AS academic_year
             ,CONVERT(INT,SUM(membershipvalue)) AS n_days_school
       FROM gabby.powerschool.calendar_day              
       GROUP BY gabby.utilities.DATE_TO_SY(date_value)
               ,schoolid
      ) sub
  GROUP BY academic_year, region, schoolid, n_days_school
 )

,att_mem AS (
  SELECT CONVERT(INT,studentid) AS studentid
        ,CONVERT(INT,yearid) + 1990 AS academic_year
        ,CONVERT(INT,SUM(attendancevalue)) AS n_att
        ,CONVERT(INT,SUM(membershipvalue)) AS n_mem
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,yearid
 )

SELECT co.student_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate      
      ,co.ethnicity      
	     ,co.lunchstatus
      ,co.iep_status
      ,co.specialed_classification
      ,co.lep_status
      ,COUNT(co.student_number) OVER(PARTITION BY co.schoolid, co.academic_year) AS n_students
      
      ,nj.programtypecode
      ,nj.special_education_placement        
      
      ,d.n_days_school
      ,d.n_days_region_min
      
      ,sub.n_mem
      ,sub.n_att            
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
JOIN schooldays d
  ON co.schoolid = d.schoolid
 AND co.academic_year = d.academic_year
JOIN att_mem sub
  ON co.studentid = sub.studentid
 AND co.academic_year = sub.academic_year
WHERE co.rn_year = 1