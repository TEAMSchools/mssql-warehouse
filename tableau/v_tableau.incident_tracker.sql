USE gabby
GO

CREATE OR ALTER VIEW tableau.incident_tracker AS

WITH dlrosters AS (
  SELECT student_school_id
        ,roster_name
  FROM gabby.deanslist.roster_assignments
  WHERE dlroster_id = 43532 /* Comeback Scholars (1) */
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity
      
      ,r.roster_name AS dl_rostername
      
      ,dli.incident_id AS dl_id            
      ,dli.status
      ,dli.reported_details AS notes
      ,dli.create_first + ' ' + dli.create_last AS referring_teacher_name
      ,dli.update_first + ' ' + dli.update_last AS reviewed_by            
      ,CONVERT(DATE,JSON_VALUE(dli.create_ts, '$.date')) AS dl_timestamp      
      ,ISNULL(dli.category, 'Referral') AS dl_behavior
      ,'Referral' AS dl_category
      
      ,d.alt_name AS term
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.incidents dli
  ON co.student_number = dli.student_school_id
 AND co.academic_year = gabby.utilities.DATE_TO_SY(CONVERT(DATE,JSON_VALUE(dli.create_ts, '$.date')))
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND JSON_VALUE(dli.create_ts, '$.date') BETWEEN d.start_date AND d.end_date
 AND d.identifier = 'RT'
WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.schoolid != 999999
  AND co.rn_year = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity

      ,r.roster_name AS dl_rostername

      ,dlip.incidentpenaltyid AS dl_id
      ,dli.status
      ,dli.admin_summary AS notes
      ,dli.create_first + ' ' + dli.create_last AS referring_teacher_name
      ,dli.update_first + ' ' + dli.update_last AS reviewed_by
      ,CONVERT(DATE,ISNULL(dlip.startdate, JSON_VALUE(dli.close_ts, '$.date'))) AS dl_timestamp
      ,dlip.penaltyname AS dl_behavior
      ,'Consequence' AS dl_category

      ,d.alt_name AS term
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.incidents dli
  ON co.student_number = dli.student_school_id
 AND co.academic_year = gabby.utilities.DATE_TO_SY(CONVERT(DATE,JSON_VALUE(dli.create_ts, '$.date')))
JOIN gabby.deanslist.incidents_penalties dlip
  ON dli.incident_id = dlip.IncidentID
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND ISNULL(dlip.startdate, JSON_VALUE(dli.close_ts, '$.date')) BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.schoolid != 999999
  AND co.rn_year = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity

      ,r.roster_name AS dl_rostername
           
      ,dlb.dlsaid AS dl_id
      ,NULL AS status
      ,NULL AS notes
      ,dlb.staff_first_name + ' ' + dlb.staff_last_name AS referring_teacher_name
      ,NULL AS reviewed_by
      ,dlb.behavior_date AS dl_timestamp
      ,dlb.behavior AS dl_behavior
      ,dlb.behavior_category AS dl_category
      
      ,d.alt_name AS term
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.behavior dlb 
  ON co.student_number = dlb.student_school_id
 AND co.academic_year = gabby.utilities.DATE_TO_SY(behavior_date)
 AND dlb.is_deleted = 0
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND dlb.behavior_date BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.rn_year = 1
  AND co.schoolid = 73253