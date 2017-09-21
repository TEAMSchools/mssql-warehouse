USE gabby
GO

CREATE OR ALTER VIEW tableau.student_roster AS

SELECT co.student_number
      ,co.lastfirst
      ,co.last_name
      ,co.first_name
      ,co.region
      ,co.schoolid
      ,co.school_name
      ,co.school_level
      ,co.yearid
      ,co.grade_level
      ,co.entrycode
      ,co.entrydate
      ,co.exitdate
      ,co.exitcomment
      ,co.enroll_status
      ,co.boy_status
      ,co.eoy_status
      ,co.entry_schoolid
      ,co.is_retained_year
      ,co.is_retained_ever
      ,co.iep_status
      ,co.specialed_classification
      ,co.advisor_name
      ,co.team
      ,co.state_studentnumber
      ,co.dob
      ,co.street
      ,co.city
      ,co.state
      ,co.zip
      ,co.guardianemail
      ,co.mother
      ,co.mother_cell
      ,co.mother_home_phone
      ,co.parent_motherdayphone
      ,co.father
      ,co.father_cell
      ,co.father_home_phone
      ,co.parent_fatherdayphone
      ,co.lunch_balance
      ,co.lunchstatus
      ,co.release_1_name
      ,co.release_1_phone
      ,co.release_2_name
      ,co.release_2_phone
      ,co.release_3_name
      ,co.release_3_phone
      ,co.release_4_name
      ,co.release_4_phone
      ,co.release_5_name
      ,co.release_5_phone
FROM powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid != 999999
  AND co.rn_year = 1