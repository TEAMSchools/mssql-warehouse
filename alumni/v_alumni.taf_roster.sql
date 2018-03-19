USE gabby
GO

CREATE OR ALTER VIEW alumni.taf_roster AS 

WITH ms_grads AS (
  SELECT co.studentid
        ,co.student_number
        ,co.first_name
        ,co.last_name
        ,co.lastfirst        
        ,co.dob
        ,co.schoolid        
        ,co.school_name
        ,co.grade_level                                
        ,co.exitdate
        ,co.cohort
        ,co.highest_achieved        
        ,co.guardianemail
        ,co.iep_status
        ,co.specialed_classification
        ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - co.academic_year) + co.grade_level AS curr_grade_level

        ,ROW_NUMBER() OVER(
           PARTITION BY co.student_number
             ORDER BY co.exitdate DESC) AS rn
  FROM gabby.powerschool.cohort_identifiers_static co
  WHERE co.grade_level = 8
    AND co.exitcode IN ('G1','T2')        
    AND co.rn_year = 1
    AND co.enroll_status != 0
    AND co.student_number NOT IN (SELECT student_number FROM gabby.powerschool.cohort_identifiers_static WHERE grade_level >= 9 AND exitcode = 'G1') /* exclude hs grads */
 )

,transfers AS (
  SELECT sub.studentid
        ,sub.student_number
        ,sub.first_name
        ,sub.last_name
        ,sub.lastfirst                
        ,sub.dob
        ,sub.curr_grade_level
        ,sub.cohort
        ,sub.highest_achieved        
        ,sub.final_exitdate
        ,sub.guardianemail

        ,CONVERT(INT,CASE 
                      WHEN s.graduated_schoolid = 0 THEN s.schoolid 
                      ELSE s.graduated_schoolid 
                     END) AS schoolid       
        ,CONVERT(VARCHAR(25),CASE 
                              WHEN s.graduated_schoolid = 0 THEN sch2.abbreviation 
                              ELSE sch.abbreviation 
                             END) AS school_name                         
  FROM
      (
       SELECT co.studentid             
             ,co.student_number
             ,co.first_name
             ,co.last_name
             ,co.lastfirst
             ,co.dob             
             ,co.highest_achieved             
             ,MAX(co.cohort) AS cohort
             ,MAX(co.guardianemail) AS guardianemail
             ,MIN(co.entrydate) AS orig_entrydate
             ,MAX(co.exitdate) AS final_exitdate
             ,DATEDIFF(YEAR, MIN(co.entrydate), MAX(co.exitdate)) AS years_enrolled             
             ,DATEPART(YEAR,MAX(co.exitdate)) AS year_final_exitdate             
             ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - MAX(co.academic_year)) + MAX(co.grade_level) AS curr_grade_level
       FROM gabby.powerschool.cohort_identifiers_static co
       WHERE co.grade_level >= 9
         AND co.enroll_status = 2
         AND co.studentid NOT IN (SELECT studentid FROM ms_grads) 
       GROUP BY co.studentid
               ,co.student_number
               ,co.lastfirst
               ,co.first_name
               ,co.last_name
               ,co.highest_achieved
               ,co.dob
      ) sub
  LEFT OUTER JOIN gabby.powerschool.students s
    ON sub.student_number = s.student_number
  LEFT OUTER JOIN gabby.powerschool.schools sch
    ON s.graduated_schoolid = sch.school_number
  LEFT OUTER JOIN gabby.powerschool.schools sch2 
    ON s.schoolid = sch2.school_number
  WHERE sub.cohort >= 2018 
    AND ((years_enrolled = 1 AND final_exitdate >= DATEFROMPARTS(year_final_exitdate, 10, 1)) OR (years_enrolled > 1))
 )

,enrollments AS (
  SELECT salesforce_contact_id
        ,student_number
        ,sf_mobile_phone
        ,sf_home_phone
        ,sf_other_phone
        ,sf_email
        ,kipp_hs_class_c
        ,expected_hs_graduation_c
        ,contact_owner_id
        ,ktc_counselor
        ,enrollment_type
        ,enrollment_status
        ,enrollment_name
        ,start_date_c
        ,ROW_NUMBER() OVER(
          PARTITION BY student_number
            ORDER BY start_date_c DESC) AS rn
  FROM
      (
       SELECT CONVERT(VARCHAR(25),s.id) AS salesforce_contact_id
             ,CONVERT(INT,s.school_specific_id_c) AS student_number        
             ,CONVERT(VARCHAR(125),s.mobile_phone) AS sf_mobile_phone
             ,CONVERT(VARCHAR(125),s.home_phone) AS sf_home_phone
             ,CONVERT(VARCHAR(125),s.other_phone) AS sf_other_phone
             ,CONVERT(VARCHAR(125),s.email) AS sf_email
             ,CONVERT(INT,s.kipp_hs_class_c) AS kipp_hs_class_c
             ,s.expected_hs_graduation_c
        
             ,CONVERT(VARCHAR(25),u.id) AS contact_owner_id
             ,CONVERT(VARCHAR(125),u.name) AS ktc_counselor
        
             ,CONVERT(VARCHAR(25),enr.type_c) AS enrollment_type
             ,CONVERT(VARCHAR(25),enr.status_c) AS enrollment_status
             ,CONVERT(VARCHAR(125),enr.name) AS enrollment_name    
             ,enr.start_date_c    
       FROM gabby.alumni.contact s
       JOIN gabby.alumni.[user] u
         ON s.owner_id = u.id
       JOIN gabby.alumni.enrollment_c enr
         ON s.id = enr.student_c
       WHERE s.is_deleted = 0
         AND s.school_specific_id_c IS NOT NULL
      ) sub
 )

,roster_union AS (
  SELECT studentid
        ,student_number
        ,first_name
        ,last_name
        ,lastfirst
        ,dob
        ,exitdate
        ,schoolid
        ,school_name
        ,curr_grade_level
        ,cohort
        ,highest_achieved        
        ,guardianemail
  FROM ms_grads  

  UNION  

  SELECT studentid
        ,student_number
        ,first_name
        ,last_name           
        ,lastfirst
        ,dob
        ,final_exitdate
        ,schoolid
        ,school_name
        ,curr_grade_level
        ,cohort
        ,highest_achieved        
        ,guardianemail
  FROM transfers    
 ) 

SELECT r.student_number
      ,r.studentid
      ,r.lastfirst
      ,r.schoolid
      ,r.school_name
      ,r.curr_grade_level AS approx_grade_level
      ,r.first_name
      ,r.last_name
      ,r.dob
      ,r.exitdate      
      ,r.guardianemail AS ps_email
      ,CASE WHEN r.highest_achieved = 99 THEN 1 ELSE 0 END AS is_grad

      ,enr.kipp_hs_class_c AS cohort      
      ,enr.expected_hs_graduation_c AS expected_hs_graduation_date
      ,enr.ktc_counselor
      ,enr.enrollment_type
      ,enr.enrollment_name
      ,enr.enrollment_status
      ,enr.sf_home_phone
      ,enr.sf_mobile_phone
      ,enr.sf_other_phone
      ,enr.sf_email
      
      ,CONVERT(VARCHAR(125),s.home_phone) AS ps_home_phone
      ,CONVERT(VARCHAR(125),s.mother) AS ps_mother
      ,CONVERT(VARCHAR(125),s.father) AS ps_father
      ,CONVERT(VARCHAR(125),s.doctor_name) AS ps_doctor_name
      ,CONVERT(VARCHAR(125),s.doctor_phone) AS ps_doctor_phone
      ,CONVERT(VARCHAR(125),s.emerg_contact_1) AS ps_emerg_contact_1
      ,CONVERT(VARCHAR(125),s.emerg_phone_1) AS ps_emerg_phone_1
      ,CONVERT(VARCHAR(125),s.emerg_contact_2) AS ps_emerg_contact_2
      ,CONVERT(VARCHAR(125),s.emerg_phone_2) AS ps_emerg_phone_2

      ,CONVERT(VARCHAR(125),scf.mother_home_phone) AS ps_mother_home
      ,CONVERT(VARCHAR(125),scf.father_home_phone) AS ps_father_home
      ,CONVERT(VARCHAR(125),scf.emerg_1_rel) AS ps_emerg_1_rel
      ,CONVERT(VARCHAR(125),scf.emerg_2_rel) AS ps_emerg_2_rel
      ,CONVERT(VARCHAR(125),scf.emerg_contact_3) AS ps_emerg_contact_3
      ,CONVERT(VARCHAR(125),scf.emerg_3_rel) AS ps_emerg_3_rel
      ,CONVERT(VARCHAR(125),scf.emerg_3_phone) AS ps_emerg_3_phone
            
      ,CONVERT(VARCHAR(125),suf.mother_cell) AS ps_mother_cell
      ,CONVERT(VARCHAR(125),suf.parent_motherdayphone) AS ps_mother_day
      ,CONVERT(VARCHAR(125),suf.father_cell) AS ps_father_cell
      ,CONVERT(VARCHAR(125),suf.parent_fatherdayphone) AS ps_father_day      
      ,CONVERT(VARCHAR(125),suf.emerg_4_name) AS ps_emerg_4_name
      ,CONVERT(VARCHAR(125),suf.emerg_4_rel) AS ps_emerg_4_rel
      ,CONVERT(VARCHAR(125),suf.emerg_4_phone) AS ps_emerg_4_phone
      ,CONVERT(VARCHAR(125),suf.emerg_5_name) AS ps_emerg_5_name
      ,CONVERT(VARCHAR(125),suf.emerg_5_rel) AS ps_emerg_5_rel
      ,CONVERT(VARCHAR(125),suf.emerg_5_phone) AS ps_emerg_5_phone
      ,CONVERT(VARCHAR(125),suf.release_1_name) AS ps_release_1_name
      ,CONVERT(VARCHAR(125),suf.release_1_phone) AS ps_release_1_phone
      ,CONVERT(VARCHAR(125),suf.release_1_relation) AS ps_release_1_relation
      ,CONVERT(VARCHAR(125),suf.release_2_name) AS ps_release_2_name
      ,CONVERT(VARCHAR(125),suf.release_2_phone) AS ps_release_2_phone
      ,CONVERT(VARCHAR(125),suf.release_2_relation) AS ps_release_2_relation
      ,CONVERT(VARCHAR(125),suf.release_3_name) AS ps_release_3_name
      ,CONVERT(VARCHAR(125),suf.release_3_phone) AS ps_release_3_phone
      ,CONVERT(VARCHAR(125),suf.release_3_relation) AS ps_release_3_relation
      ,CONVERT(VARCHAR(125),suf.release_4_name) AS ps_release_4_name
      ,CONVERT(VARCHAR(125),suf.release_4_phone) AS ps_release_4_phone
      ,CONVERT(VARCHAR(125),suf.release_4_relation) AS ps_release_4_relation
      ,CONVERT(VARCHAR(125),suf.release_5_name) AS ps_release_5_name
      ,CONVERT(VARCHAR(125),suf.release_5_phone) AS ps_release_5_phone
      ,CONVERT(VARCHAR(125),suf.release_5_relation) AS ps_release_5_relation
FROM roster_union r
LEFT OUTER JOIN enrollments enr
  ON r.student_number = enr.student_number
 AND enr.rn = 1
LEFT OUTER JOIN gabby.powerschool.students s
  ON r.student_number = s.student_number
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid