USE gabby
GO

ALTER VIEW DL$student_misc#extract AS

WITH enroll_dates AS (
  SELECT student_number
        ,schoolid
        ,MIN(entrydate) AS school_entrydate
        ,MAX(exitdate) AS school_exitdate
  FROM gabby.powerschool.cohort_identifiers_static s  
  GROUP BY student_number, schoolid
 )

SELECT s.student_number
      ,s.state_studentnumber AS SID
      ,s.team
      ,s.dob
      ,s.home_phone
      ,s.mother AS parent1_name
      ,s.father AS parent2_name
      ,s.guardianemail

      ,suf.mother_cell AS parent1_cell      
      ,suf.father_cell AS parent2_cell
      ,suf.advisor AS advisor_name
      ,suf.advisor_cell
      ,suf.advisor_email
      ,suf.lunch_balance

      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year      
      
      ,CASE
        WHEN s.enroll_status = -1 THEN 'Pre-Registered'
        WHEN s.enroll_status = 0 THEN 'Enrolled'
        WHEN s.enroll_status = 1 THEN 'Inactive'
        WHEN s.enroll_status = 2 THEN 'Transferred Out'
        WHEN s.enroll_status = 3 THEN 'Graduated'
       END AS enroll_status
      ,CONCAT(s.street, ', ', s.city, ', ', s.state, ' ', s.zip) AS home_address
      
      ,nav.counselor_name AS ktc_counselor_name
      
      ,adp.personal_contact_personal_mobile AS ktc_counselor_phone
      
      ,ad.mail AS ktc_counselor_email
      
      ,ed.school_entrydate
      ,ed.school_exitdate
      
      ,cat.H_Y1 AS HWQ_Y1
      
      --,gpa.GPA_Y1      
FROM gabby.powerschool.students s
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN gabby.naviance.students nav 
  ON s.student_number = nav.hs_student_id
LEFT OUTER JOIN gabby.adp.staff_roster adp 
  ON nav.counselor_name = CONCAT(adp.preferred_first, ' ', adp.preferred_last)
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
LEFT OUTER JOIN enroll_dates ed
  ON s.student_number = ed.student_number
 AND CASE WHEN s.schoolid = 999999 THEN s.graduated_schoolid ELSE s.schoolid END = ed.schoolid
LEFT OUTER JOIN gabby.powerschool.category_grades_wide cat
  ON s.student_number = cat.student_number
 AND cat.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 AND cat.is_curterm = 1
 AND cat.course_number = 'ALL'
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
  ON s.student_number = gpa.student_number
 AND gpa.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND gpa.is_curterm = 1
