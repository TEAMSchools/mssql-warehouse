USE gabby
GO

CREATE OR ALTER VIEW tableau.compliance_school_register_summary AS

WITH schooldays AS (
  SELECT db_name
        ,academic_year
        ,schoolid
        ,region
        ,n_days_school
        ,n_days_remaining
        ,MIN(n_days_school) OVER(PARTITION BY academic_year, region) n_days_region_min
  FROM (
        SELECT CONVERT(INT, schoolid) AS schoolid
              ,db_name
              ,CASE
                WHEN db_name = 'kippcamden' THEN 'KCNA'
                WHEN db_name LIKE 'kippnewark' THEN 'TEAM'
               END AS region
              ,gabby.utilities.DATE_TO_SY(date_value) AS academic_year
              ,CONVERT(INT,SUM(membershipvalue)) AS n_days_school
              ,CONVERT(INT,SUM(CASE WHEN date_value > GETDATE() THEN membershipvalue END)) AS n_days_remaining
        FROM gabby.powerschool.calendar_day
        GROUP BY gabby.utilities.DATE_TO_SY(date_value)
                ,schoolid
                ,db_name
       ) sub
 )

,att_mem AS (
  SELECT CONVERT(INT,studentid) AS studentid
        ,db_name
        ,CONVERT(INT,yearid) + 1990 AS academic_year
        ,CONVERT(INT,SUM(attendancevalue)) AS n_att
        ,CONVERT(INT,SUM(membershipvalue)) AS n_mem
        ,CONVERT(INT,SUM(CASE WHEN calendardate <= GETDATE() THEN membershipvalue END)) AS n_mem_ytd
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,yearid
          ,db_name
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
      ,co.enroll_status
      ,co.is_pathways
      ,ISNULL(co.lep_status, 0) AS lep_status
      ,COUNT(co.student_number) OVER(PARTITION BY co.schoolid, co.academic_year) AS n_students
      
      ,nj.programtypecode
      
      ,iep.nj_se_placement AS special_education_placement 
      
      ,d.n_days_school
      ,d.n_days_region_min
      ,d.n_days_remaining
      
      ,sub.n_mem
      ,sub.n_att          
      ,sub.n_mem_ytd
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
 AND co.db_name = nj.db_name
LEFT JOIN gabby.easyiep.njsmart_powerschool_clean iep
  ON co.student_number = iep.student_number
 AND co.academic_year = iep.academic_year
 AND co.db_name = iep.db_name
JOIN schooldays d
  ON co.schoolid = d.schoolid
 AND co.academic_year = d.academic_year
 AND co.db_name = d.db_name
JOIN att_mem sub
  ON co.studentid = sub.studentid
 AND co.academic_year = sub.academic_year
 AND co.db_name = sub.db_name
WHERE co.rn_year = 1