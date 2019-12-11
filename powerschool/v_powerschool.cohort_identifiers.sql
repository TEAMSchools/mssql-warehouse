CREATE OR ALTER VIEW powerschool.cohort_identifiers AS

WITH enr AS (
  SELECT sub.student_number
        ,sub.yearid
        ,MAX(sub.is_enrolled_y1) AS is_enrolled_y1
        ,MAX(sub.is_enrolled_oct01) AS is_enrolled_oct01
        ,MAX(sub.is_enrolled_oct15) AS is_enrolled_oct15
        ,MAX(sub.is_enrolled_recent) AS is_enrolled_recent
        ,MAX(sub.is_enrolled_oct15_week) AS is_enrolled_oct15_week
        ,MAX(sub.is_enrolled_jan15_week) AS is_enrolled_jan15_week
  FROM
      (
       SELECT co.student_number
             ,co.yearid

             ,CASE WHEN co.exitdate IS NOT NULL THEN 1 END AS is_enrolled_y1
             ,CASE WHEN DATEFROMPARTS(co.academic_year, 10, 1) BETWEEN co.entrydate AND co.exitdate THEN 1 END AS is_enrolled_oct01
             ,CASE WHEN DATEFROMPARTS(co.academic_year, 10, 15) BETWEEN co.entrydate AND co.exitdate THEN 1 END AS is_enrolled_oct15
             ,CASE 
               WHEN co.exitdate >= c.max_calendardate THEN 1
               WHEN CONVERT(DATE, GETDATE()) BETWEEN co.entrydate AND co.exitdate THEN 1
              END AS is_enrolled_recent
              /* enrolled week of 10/15 */
             ,CASE
               WHEN co.entrydate <= DATEADD(DAY
                                           ,7 - (DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year, 10, 15)))
                                           ,DATEFROMPARTS(co.academic_year, 10, 15)) /* entered before 10/15 week end */
                AND co.exitdate  >= DATEADD(DAY
                                           ,0 - (DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year, 10, 15)) - 1)
                                           ,DATEFROMPARTS(co.academic_year, 10, 15)) /* exited after 10/15 week start */
                      THEN 1
              END AS is_enrolled_oct15_week
              /* enrolled week of 01/15 */
             ,CASE
               WHEN co.entrydate <= DATEADD(DAY
                                           ,7 - (DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year + 1, 1, 15)))
                                           ,DATEFROMPARTS(co.academic_year + 1, 1, 15)) /* entered before 01/15 week end */
                AND co.exitdate  >= DATEADD(DAY
                                           ,0 - (DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year + 1, 1, 15)) - 1)
                                           ,DATEFROMPARTS(co.academic_year + 1, 1, 15)) /* exited after 01/15 week start */
                      THEN 1
              END AS is_enrolled_jan15_week
       FROM powerschool.cohort_static co
       LEFT JOIN powerschool.calendar_rollup_static c
         ON co.schoolid = c.schoolid
        AND co.yearid = c.yearid
        AND co.track = c.track
       WHERE co.grade_level != 99
      ) sub
  GROUP BY sub.student_number
          ,sub.yearid
 )

SELECT co.studentid
      ,co.academic_year
      ,co.yearid
      ,co.schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate                
      ,co.entrycode
      ,co.exitcode
      ,co.exit_code_kf
      ,co.exit_code_ts
      ,co.exitcomment      
      ,co.fteid
      ,co.cohort
      ,co.is_retained_year      
      ,co.year_in_network
      ,co.year_in_school
      ,co.rn_year
      ,co.rn_school
      ,co.rn_undergrad
      ,co.rn_all  
      ,co.entry_schoolid
      ,co.entry_grade_level
      ,co.is_retained_ever
      ,co.boy_status
      ,co.eoy_status
      ,co.track

      ,ISNULL(enr.is_enrolled_y1, 0) AS is_enrolled_y1
      ,ISNULL(enr.is_enrolled_oct01, 0) AS is_enrolled_oct01
      ,ISNULL(enr.is_enrolled_oct15, 0) AS is_enrolled_oct15
      ,ISNULL(enr.is_enrolled_recent, 0) AS is_enrolled_recent
      ,ISNULL(enr.is_enrolled_oct15_week, 0) AS is_enrolled_oct15_week
      ,ISNULL(enr.is_enrolled_jan15_week, 0) AS is_enrolled_jan15_week

      ,CONVERT(INT,s.student_number) AS student_number
      ,co.studentsdcid AS students_dcid
      ,CONVERT(VARCHAR,s.lastfirst) AS lastfirst
      ,CONVERT(VARCHAR,s.first_name) AS first_name
      ,CONVERT(VARCHAR,s.middle_name) AS middle_name
      ,CONVERT(VARCHAR,s.last_name) AS last_name
      ,s.state_studentnumber
      ,CONVERT(INT,s.enroll_status) AS enroll_status
      ,CONVERT(VARCHAR,UPPER(LEFT(s.gender, 1))) AS gender
      ,CONVERT(VARCHAR,UPPER(LEFT(s.ethnicity, 1))) AS ethnicity
      ,s.dob      
      ,CONVERT(VARCHAR,s.street) AS street
      ,CONVERT(VARCHAR,s.city) AS city
      ,CONVERT(VARCHAR,s.state) AS state
      ,CONVERT(VARCHAR,s.zip) AS zip
      ,CONVERT(VARCHAR(125),s.guardianemail) AS guardianemail
      ,CONVERT(VARCHAR,s.home_phone) AS home_phone
      ,CONVERT(VARCHAR,s.mother) AS mother
      ,CONVERT(VARCHAR,s.father) AS father
      ,CONVERT(INT,s.grade_level) AS highest_achieved

      ,CONVERT(VARCHAR(125),scf.mother_home_phone) AS mother_home_phone
      ,CONVERT(VARCHAR(125),scf.father_home_phone) AS father_home_phone
      
      ,CONVERT(VARCHAR(25),suf.newark_enrollment_number) AS newark_enrollment_number
      ,CONVERT(INT,suf.c_504_status) AS c_504_status
      ,suf.lunch_balance            
      ,CONVERT(VARCHAR(125),suf.mother_cell) AS mother_cell
      ,CONVERT(VARCHAR(125),suf.parent_motherdayphone) AS parent_motherdayphone
      ,CONVERT(VARCHAR(125),suf.father_cell) AS father_cell
      ,CONVERT(VARCHAR(125),suf.parent_fatherdayphone) AS parent_fatherdayphone
      ,CONVERT(VARCHAR(125),suf.release_1_name) AS release_1_name
      ,CONVERT(VARCHAR(125),suf.release_2_name) AS release_2_name
      ,CONVERT(VARCHAR(125),suf.release_3_name) AS release_3_name
      ,CONVERT(VARCHAR(125),suf.release_4_name) AS release_4_name
      ,CONVERT(VARCHAR(125),suf.release_5_name) AS release_5_name
      ,CONVERT(VARCHAR(125),suf.release_1_phone) AS release_1_phone
      ,CONVERT(VARCHAR(125),suf.release_2_phone) AS release_2_phone
      ,CONVERT(VARCHAR(125),suf.release_3_phone) AS release_3_phone
      ,CONVERT(VARCHAR(125),suf.release_4_phone) AS release_4_phone
      ,CONVERT(VARCHAR(125),suf.release_5_phone) AS release_5_phone  

      ,co.region
      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN sp.programid
        WHEN co.academic_year <= 2017 THEN CONCAT(co.schoolid, sp.programid) /* Pathways as a separate school era */
        ELSE co.schoolid
       END AS reporting_schoolid
      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN sp.specprog_name
        WHEN co.academic_year <= 2017 THEN CONVERT(VARCHAR(25),COALESCE(sp.specprog_name, sch.abbreviation)) /* Pathways as a separate school era */
        ELSE CONVERT(VARCHAR(25),sch.abbreviation)
       END AS school_name
      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN 'OD'
        WHEN sch.high_grade = 12 THEN 'HS'
        WHEN sch.high_grade = 8 THEN 'MS'
        WHEN sch.high_grade = 4 THEN 'ES'
       END AS school_level
      ,CASE WHEN sp.specprog_name IN ('Self-Contained Special Education', 'Pathways ES', 'Pathways MS') THEN 1 ELSE 0 END AS is_pathways

      ,t.team

      ,adv.advisor_name
      ,adv.advisor_phone COLLATE Latin1_General_BIN AS advisor_phone
      ,adv.advisor_email COLLATE Latin1_General_BIN AS advisor_email
      
      ,CONVERT(VARCHAR(25),
         ISNULL(CASE
                 WHEN DB_NAME() = 'kippmiami' THEN scf.spedlep
                 WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN sped.spedlep
                END,'No IEP')) AS iep_status
      ,CONVERT(VARCHAR(25),
         CASE
          WHEN DB_NAME() = 'kippmiami' THEN scf.spedlep
          WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN sped.special_education_code
         END) AS specialed_classification
      
      ,CASE
        WHEN DB_NAME() = 'kippmiami' AND scf.lep_status = 'Y' THEN 1
        WHEN nj.lepbegindate IS NULL THEN 0
        WHEN nj.lependdate < co.entrydate THEN 0
        WHEN nj.lepbegindate <= co.exitdate THEN 1
        ELSE 0
       END AS lep_status

      ,saa.student_web_id
      ,saa.student_web_password

      ,CONVERT(VARCHAR(5),UPPER(CASE
                                 WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                                  AND co.rn_year = 1 THEN CASE
                                                           WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN mcs.lunch_status COLLATE Latin1_General_BIN
                                                           WHEN DB_NAME() = 'kippmiami' AND s.lunchstatus = 'NoD' THEN NULL
                                                           WHEN DB_NAME() = 'kippmiami' THEN s.lunchstatus
                                                          END
                                 WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                                  AND co.entrydate = s.entrydate THEN CASE
                                                                       WHEN s.lunchstatus = 'NoD' THEN NULL
                                                                       ELSE s.lunchstatus
                                                                      END
                                 ELSE co.lunchstatus
                                END)) AS lunchstatus
      ,CONVERT(VARCHAR(125),CASE
                             WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                              AND co.rn_year = 1 THEN CASE
                                                       WHEN DB_NAME() = 'kippmiami' THEN s.lunchstatus
                                                       WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN mcs.lunch_app_status COLLATE Latin1_General_BIN
                                                      END
                             WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                              AND co.entrydate = s.entrydate 
                                  THEN s.lunchstatus
                             ELSE co.lunchstatus
                            END) AS lunch_app_status
FROM powerschool.cohort_static co
LEFT JOIN enr
  ON co.student_number = enr.student_number
 AND co.yearid = enr.yearid
JOIN powerschool.students s
  ON co.studentid = s.id
LEFT JOIN powerschool.u_studentsuserfields suf
  ON co.studentsdcid = suf.studentsdcid
LEFT JOIN powerschool.studentcorefields scf
  ON co.studentsdcid = scf.studentsdcid
LEFT JOIN powerschool.s_nj_stu_x nj
  ON co.studentsdcid = nj.studentsdcid
LEFT JOIN gabby.powerschool.student_access_accounts_static saa
  ON co.student_number = saa.student_number
JOIN powerschool.schools sch
  ON co.schoolid = sch.school_number
LEFT JOIN powerschool.team_roster_static t
  ON co.student_number = t.student_number
 AND co.academic_year = t.academic_year
 AND co.schoolid = t.schoolid
LEFT JOIN powerschool.advisory_static adv
  ON co.student_number = adv.student_number
 AND co.academic_year = adv.academic_year
LEFT JOIN easyiep.njsmart_powerschool_clean sped
  ON co.student_number = sped.student_number
 AND co.academic_year  = sped.academic_year
LEFT JOIN powerschool.spenrollments_gen sp
  ON co.studentid = sp.studentid
 AND co.entrydate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name IN ('Out of District', 'Self-Contained Special Education', 'Pathways ES', 'Pathways MS', 'Whittier ES')
LEFT JOIN mcs.view_student_data_static mcs
  ON co.student_number = mcs.student_number