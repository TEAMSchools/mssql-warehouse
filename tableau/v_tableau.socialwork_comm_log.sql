USE gabby
GO

--CREATE OR ALTER VIEW tableau.socialwork_comm_log AS

WITH commlog AS (
  SELECT c.student_school_id
        ,c.reason AS commlog_reason
        ,c.response AS commlog_notes        
        ,c.call_topic AS commlog_topic
        ,CONVERT(DATE,c.call_date_time) AS commlog_date
        ,CONCAT(u.first_name, ' ', u.last_name) AS commlog_staff_name        
        ,f.init_notes AS followup_init_notes
        ,f.followup_notes AS followup_close_notes
        ,f.outstanding
        ,CONCAT(f.c_first, ' ', f.c_last) AS followup_staff_name      
  FROM gabby.deanslist.communication c
  JOIN gabby.deanslist.users u
    ON c.dluser_id = u.dluser_id
  LEFT OUTER JOIN gabby.deanslist.followups f
    ON c.followup_id = f.followup_id
  WHERE c.reason LIKE 'SW:%'
 )

,promo_status AS (
  SELECT student_number
      ,academic_year
	  ,att_pts_pct
	  ,promo_status_attendance
	  ,promo_status_grades
	  ,GPA_Y1
	  ,is_curterm
	  ,term_name
	  
  FROM gabby.reporting.promotional_status

  WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND is_curterm = 1
 )



SELECT co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.region
      ,co.reporting_schoolid
	  ,co.school_name    
	  ,co.enroll_status
	  ,co.is_retained_ever
	  ,co.is_retained_year
	  ,co.advisor_name
	  ,co.advisor_phone
	  ,co.mother_cell
	  ,co.home_phone
	  ,co.father_cell
	  ,co.mother
	  ,co.father
	  ,co.guardianemail
	  ,co.street + ', ' + co.city + ', ' + co.zip AS address
	  ,co.specialed_classification
	  ,co.iep_status
	  ,co.boy_status
	  
	  ,promo_status.att_pts_pct
	  ,promo_status.promo_status_attendance
	  ,promo_status.promo_status_grades
	  ,promo_status.GPA_Y1
	  
	  ,cl.commlog_staff_name
      ,cl.commlog_reason
      ,cl.commlog_notes
      ,cl.commlog_topic
      ,cl.followup_staff_name
      ,cl.followup_init_notes
      ,cl.followup_close_notes

FROM gabby.powerschool.cohort_identifiers_static co
JOIN commlog cl
  ON co.student_number = cl.student_school_id
JOIN promo_status
  ON co.student_number = promo_status.student_number
 AND co.academic_year = promo_status.academic_year
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
