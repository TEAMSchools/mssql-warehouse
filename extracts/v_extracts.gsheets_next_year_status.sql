USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_next_year_status AS

SELECT student_number
      ,state_studentnumber
      ,lastfirst
      ,academic_year
      ,region
      ,schoolid
      ,school_name
      ,grade_level
      ,iep_status
      ,cohort
      ,is_retained_ever
      ,enroll_status
      ,next_school
      ,sched_nextyeargrade
      ,NULL AS promo_status
      ,gmaps_address
FROM gabby.tableau.next_year_status
