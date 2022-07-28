USE gabby
GO

CREATE OR ALTER VIEW tableau.compliance_school_register_summary AS

WITH att_mem AS (
  SELECT studentid
        ,yearid
        ,[db_name]
        ,SUM(attendancevalue) AS n_att
        ,SUM(membershipvalue) AS n_mem
        ,SUM(CASE WHEN calendardate <= GETDATE() THEN membershipvalue END) AS n_mem_ytd
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,yearid
          ,[db_name]
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.ethnicity
      ,co.lunchstatus
      ,co.iep_status
      ,co.is_pathways
      ,co.track
      ,ISNULL(co.lep_status, 0) AS lep_status

      ,d.days_total AS n_days_school
      ,d.days_remaining AS n_days_remaining

      ,sub.n_mem
      ,sub.n_att
      ,sub.n_mem_ytd

      ,nj.programtypecode

      ,iep.nj_se_placement AS special_education_placement 
FROM gabby.powerschool.cohort_identifiers_static co
INNER JOIN gabby.powerschool.calendar_rollup_static d
  ON co.schoolid = d.schoolid
 AND co.yearid = d.yearid
 AND co.track = d.track
 AND co.[db_name] = d.[db_name]
INNER JOIN att_mem sub
  ON co.studentid = sub.studentid
 AND co.yearid = sub.yearid
 AND co.[db_name] = sub.[db_name]
LEFT JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
 AND co.[db_name] = nj.[db_name]
LEFT JOIN gabby.easyiep.njsmart_powerschool_clean_static iep
  ON co.student_number = iep.student_number
 AND co.academic_year = iep.academic_year
 AND co.[db_name] = iep.[db_name]
 AND iep.rn_stu_yr = 1
WHERE co.rn_year = 1
