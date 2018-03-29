USE gabby
GO

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
      ,CASE        
        WHEN co.grade_level = 99 THEN MAX(CASE WHEN co.exitcode = 'G1' THEN co.yearid + 2003 + (-1 * co.grade_level) END) OVER(PARTITION BY co.studentid)
        WHEN co.grade_level >= 9 THEN MAX(CASE WHEN co.year_in_school = 1 THEN co.yearid + 2003 + (-1 * co.grade_level) END) OVER(PARTITION BY co.studentid, co.schoolid)
        ELSE co.yearid + 2003 + (-1 * co.grade_level)
       END AS cohort
      ,co.is_retained_year      
      ,MAX(co.year_in_network) OVER(PARTITION BY co.studentid, co.academic_year) AS year_in_network
      ,MAX(co.year_in_school) OVER(PARTITION BY co.studentid, co.academic_year) AS year_in_school
      ,co.rn_year
      ,co.rn_school
      ,co.rn_undergrad
      ,co.rn_all
  
      ,MIN(CASE WHEN co.year_in_network = 1 THEN co.schoolid END) OVER(PARTITION BY co.studentid) AS entry_schoolid
      ,MIN(CASE WHEN co.year_in_network = 1 THEN co.grade_level END) OVER(PARTITION BY co.studentid) AS entry_grade_level      
      ,MAX(co.is_retained_year) OVER(PARTITION BY co.studentid) AS is_retained_ever
      ,CASE 
        WHEN co.grade_level = 99 THEN 'Graduated'
        WHEN co.prev_grade_level IS NULL THEN 'New'        
        WHEN co.prev_grade_level < co.grade_level THEN 'Promoted'
        WHEN co.prev_grade_level = co.grade_level THEN 'Retained'
        WHEN co.prev_grade_level > co.grade_level THEN 'Demoted'                
       END AS boy_status
      ,CASE 
        WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() THEN NULL
        WHEN co.exitcode = 'G1' THEN 'Graduated'
        WHEN co.exitcode LIKE 'T%' THEN 'Transferred'        
        WHEN co.prev_grade_level < co.grade_level THEN 'Promoted'
        WHEN co.prev_grade_level = co.grade_level THEN 'Retained'
        WHEN co.prev_grade_level > co.grade_level THEN 'Demoted'
       END AS eoy_status      

      ,CONVERT(INT,s.student_number) AS student_number
      ,CONVERT(INT,s.dcid) AS students_dcid
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
      ,CONVERT(VARCHAR(125),mother_cell) AS mother_cell
      ,CONVERT(VARCHAR(125),parent_motherdayphone) AS parent_motherdayphone
      ,CONVERT(VARCHAR(125),father_cell) AS father_cell
      ,CONVERT(VARCHAR(125),parent_fatherdayphone) AS parent_fatherdayphone
      ,CONVERT(VARCHAR(125),release_1_name) AS release_1_name
      ,CONVERT(VARCHAR(125),release_2_name) AS release_2_name
      ,CONVERT(VARCHAR(125),release_3_name) AS release_3_name
      ,CONVERT(VARCHAR(125),release_4_name) AS release_4_name
      ,CONVERT(VARCHAR(125),release_5_name) AS release_5_name
      ,CONVERT(VARCHAR(125),release_1_phone) AS release_1_phone
      ,CONVERT(VARCHAR(125),release_2_phone) AS release_2_phone
      ,CONVERT(VARCHAR(125),release_3_phone) AS release_3_phone
      ,CONVERT(VARCHAR(125),release_4_phone) AS release_4_phone
      ,CONVERT(VARCHAR(125),release_5_phone) AS release_5_phone  

      ,CASE 
        WHEN co.schoolid LIKE '1799%' THEN 'KCNA' 
        WHEN co.schoolid NOT LIKE '1799%' THEN 'TEAM' 
       END AS region
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
        WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND co.rn_year = 1 THEN mcs.mealbenefitstatus 
        WHEN s.enroll_status = 2 AND co.academic_year = MAX(co.academic_year) OVER(PARTITION BY co.studentid) THEN REPLACE(s.lunchstatus,'false','F')
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
        WHEN s.enroll_status = 2 AND co.academic_year = MAX(co.academic_year) OVER(PARTITION BY co.studentid) THEN REPLACE(s.lunchstatus,'false','F')
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
FROM gabby.powerschool.cohort co
JOIN gabby.powerschool.students s
  ON co.studentid = s.id
LEFT JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid
JOIN gabby.powerschool.schools sch
  ON co.schoolid = sch.school_number
LEFT JOIN gabby.powerschool.spenrollments_gen sp
  ON co.studentid = sp.studentid
 AND co.entrydate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.programid IN (4573, 5074, 5075, 5173) 
 /* 
-- ProgramIDs for schools within schools 
--  * 4573 = Pathways (ES)
--  * 5074 = Pathways (MS)
--  * 5075 = Whittier (ES)
--  * 5713 = Out-of-District
 */
LEFT JOIN gabby.powerschool.team_roster_static t
  ON co.studentid = t.studentid
 AND co.academic_year = t.academic_year
 AND t.rn_year = 1
LEFT JOIN gabby.powerschool.advisory_static adv
  ON co.studentid = adv.studentid
 AND co.academic_year = adv.academic_year
 AND adv.rn_year = 1
LEFT JOIN gabby.mcs.lunch_info_static mcs
  ON s.student_number = mcs.studentnumber
LEFT JOIN gabby.easyiep.njsmart_powerschool sped
  ON s.student_number = sped.student_number
 AND co.academic_year  = sped.academic_year
LEFT JOIN gabby.powerschool.s_nj_stu_x nj
  ON s.dcid = nj.studentsdcid
LEFT JOIN gabby.powerschool.student_access_accounts_static saa
  ON s.student_number = saa.student_number