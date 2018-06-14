CREATE OR ALTER VIEW powerschool.cohort_identifiers AS

SELECT co.studentid
      ,co.academic_year
      ,co.yearid
      ,co.schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate                
      ,co.entrycode
      ,co.exitcode
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
        ELSE CONCAT(co.schoolid, sp.programid)
       END AS reporting_schoolid
      ,CONVERT(VARCHAR(25),COALESCE(sp.specprog_name, sch.abbreviation)) AS school_name
      ,CASE
        WHEN sch.high_grade = 12 THEN 'HS'
        WHEN sch.high_grade = 8 THEN 'MS'
        WHEN sch.high_grade = 4 THEN 'ES'
       END AS school_level

      ,t.team

      ,adv.advisor_name
      ,adv.advisor_phone
      ,adv.advisor_email
      
      ,CONVERT(VARCHAR(5),CASE
                           WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                            AND co.rn_year = 1 
                                  THEN mcs.mealbenefitstatus 
                           WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                            AND co.entrydate = s.entrydate THEN REPLACE(s.lunchstatus,'false','F')
                           ELSE co.lunchstatus
                          END) AS lunchstatus      
      ,CONVERT(VARCHAR(125),CASE 
                             WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                              AND co.rn_year = 1 
                              AND mcs.currentapplicationid IS NOT NULL 
                                    THEN mcs.mealbenefitstatus
                             WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                              AND co.rn_year = 1 
                              AND mcs.currentapplicationid IS NULL 
                                    THEN mcs.description
                             WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
                              AND co.entrydate = s.entrydate THEN REPLACE(s.lunchstatus,'false','F')
                             ELSE co.lunchstatus
                            END) AS lunch_app_status                 
      
      ,ISNULL(sped.spedlep,'No IEP') AS iep_status
      ,sped.special_education_code AS specialed_classification
      
      ,CASE 
        WHEN nj.lepbegindate IS NULL THEN NULL
        WHEN nj.lependdate < co.entrydate THEN NULL
        WHEN nj.lepbegindate <= co.exitdate THEN 1       
       END AS lep_status      

      ,saa.student_web_id
      ,saa.student_web_password
FROM powerschool.cohort_static co
JOIN powerschool.students s
  ON co.studentid = s.id
LEFT JOIN powerschool.u_studentsuserfields suf
  ON co.studentsdcid = suf.studentsdcid
LEFT JOIN powerschool.studentcorefields scf
  ON co.studentsdcid = scf.studentsdcid
LEFT JOIN gabby.mcs.lunch_info_static mcs
  ON co.student_number = mcs.studentnumber
LEFT JOIN powerschool.s_nj_stu_x nj
  ON co.studentsdcid = nj.studentsdcid
LEFT JOIN powerschool.student_access_accounts_static saa
  ON co.student_number = saa.student_number
JOIN powerschool.schools sch
  ON co.schoolid = sch.school_number
LEFT JOIN powerschool.team_roster_static t
  ON co.studentid = t.studentid
 AND co.academic_year = t.academic_year
LEFT JOIN powerschool.advisory_static adv
  ON co.studentid = adv.studentid
 AND co.academic_year = adv.academic_year
LEFT JOIN gabby.easyiep.njsmart_powerschool_static sped
  ON co.student_number = sped.student_number
 AND co.academic_year  = sped.academic_year
LEFT JOIN powerschool.spenrollments_gen sp
  ON co.studentid = sp.studentid
 AND co.entrydate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.programid IN (4573, 5074, 5075, 5173) 
/* 
ProgramIDs for schools within schools 
* 4573 = Pathways (ES)
* 5074 = Pathways (MS)
* 5075 = Whittier (ES)
* 5713 = Out-of-District 
*/