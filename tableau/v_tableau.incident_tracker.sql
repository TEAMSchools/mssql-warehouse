USE gabby
GO

CREATE OR ALTER VIEW tableau.incident_tracker AS

WITH dlrosters AS (
  SELECT CONVERT(INT,student_school_id) AS student_school_id
        ,CONVERT(VARCHAR(125),roster_name) AS roster_name
  FROM gabby.deanslist.roster_assignments
  WHERE roster_name = 'Comeback Scholars (1)'
 )

,custom_fields AS (
  SELECT p.incident_id
        ,p.[Restraint Used]
        ,p.[Perceived Motivation]
        ,p.[Parent Contacted?]
        ,p.[Others Involved]
        ,p.[NJ State Reporting]
        ,p.[Behavior Category]
        ,p.[SSDS Incident ID]
  FROM
      (
       SELECT incident_id
             ,field_name
             ,value
       FROM gabby.deanslist.incidents_custom_fields
       WHERE field_name IN ('Behavior Category'
                           ,'NJ State Reporting'
                           ,'Others Involved'
                           ,'Parent Contacted?'
                           ,'Perceived Motivation'
                           ,'Restraint Used'
                           ,'SSDS Incident ID')
      ) sub
  PIVOT(
    MAX(value)
    FOR field_name IN ([Behavior Category]
                      ,[NJ State Reporting]
                      ,[Others Involved]
                      ,[Parent Contacted?]
                      ,[Perceived Motivation]
                      ,[Restraint Used]
                      ,[SSDS Incident ID])
   ) p
 )

SELECT co.student_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity
      ,co.region
      
      ,r.roster_name AS dl_rostername
      
      ,dli.student_id AS dl_student_id
      ,dli.incident_id AS dl_id            
      ,dli.status
      ,dli.location
      ,dli.reported_details
      ,dli.admin_summary
      ,dli.context
      ,dli.create_first + ' ' + dli.create_last AS referring_teacher_name
      ,dli.update_first + ' ' + dli.update_last AS reviewed_by            
      ,dli.create_ts AS dl_timestamp      
      ,dli.infraction
      ,ISNULL(dli.category, 'Referral') AS dl_behavior
      ,NULL AS dl_numdays
      ,'Referral' AS dl_category
      ,NULL AS dl_point_value
      
      ,CONVERT(VARCHAR(5),d.alt_name) AS term

      ,cf.[Behavior Category]
      ,cf.[NJ State Reporting]
      ,cf.[Others Involved]
      ,cf.[Parent Contacted?]
      ,cf.[Perceived Motivation]
      ,cf.[Restraint Used]
      ,cf.[SSDS Incident ID]

FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.incidents_clean_static dli
  ON co.student_number = dli.student_school_id
 AND co.academic_year = dli.create_academic_year
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND CONVERT(DATE,dli.create_ts) BETWEEN d.start_date AND d.end_date
 AND d.identifier = 'RT'
 AND d._fivetran_deleted = 0
LEFT JOIN custom_fields cf
  ON dli.incident_id = cf.incident_id
WHERE co.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.rn_year = 1
  AND co.grade_level != 99 

UNION ALL

SELECT co.student_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity
      ,co.region

      ,r.roster_name AS dl_rostername

      ,dli.student_id AS dl_student_id
      ,dlip.incidentpenaltyid AS dl_id
      ,dli.status
      ,dli.location
      ,dli.reported_details
      ,dli.admin_summary
      ,dli.context
      ,dli.create_first + ' ' + dli.create_last AS referring_teacher_name
      ,dli.update_first + ' ' + dli.update_last AS reviewed_by
      ,ISNULL(dlip.startdate, dli.create_ts) AS dl_timestamp
      ,dli.infraction
      ,dlip.penaltyname AS dl_behavior
      ,dlip.numdays AS dl_numdays
      ,'Consequence' AS dl_category
      ,NULL AS dl_point_value

      ,CONVERT(VARCHAR(5),d.alt_name) AS term

      ,NULL AS [Behavior Category]
      ,NULL AS [NJ State Reporting]
      ,NULL AS [Others Involved]
      ,NULL AS [Parent Contacted?]
      ,NULL AS [Perceived Motivation]
      ,NULL AS [Restraint Used]
      ,NULL AS [SSDS Incident ID]

FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.incidents_clean_static dli
  ON co.student_number = dli.student_school_id
 AND co.academic_year = dli.create_academic_year
JOIN gabby.deanslist.incidents_penalties_static dlip
  ON dli.incident_id = dlip.incident_id
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND ISNULL(dlip.startdate, CONVERT(DATE,dli.create_ts)) BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
 AND d._fivetran_deleted = 0
WHERE co.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.rn_year = 1
  AND co.grade_level != 99  

UNION ALL

SELECT co.student_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.iep_status
      ,co.gender
      ,co.ethnicity
      ,co.region

      ,r.roster_name AS dl_rostername

      ,dlb.dlstudent_id AS dl_student_id
      ,CONVERT(INT,dlb.dlsaid) AS dl_id
      ,NULL AS status
      ,NULL location
      ,NULL AS reported_details
      ,NULL AS admin_summary
      ,NULL AS context
      ,CONVERT(VARCHAR(125),dlb.staff_first_name + ' ' + dlb.staff_last_name) AS referring_teacher_name
      ,NULL AS reviewed_by
      ,dlb.behavior_date AS dl_timestamp
      ,NULL AS infraction
      ,CONVERT(VARCHAR(250),dlb.behavior) AS dl_behavior
      ,NULL AS dl_numdays
      ,CONVERT(VARCHAR(125),dlb.behavior_category) AS dl_category
      ,dlb.point_value AS dl_point_value
      
      ,CONVERT(VARCHAR(5),d.alt_name) AS term

      ,NULL AS [Behavior Category]
      ,NULL AS [NJ State Reporting]
      ,NULL AS [Others Involved]
      ,NULL AS [Parent Contacted?]
      ,NULL AS [Perceived Motivation]
      ,NULL AS [Restraint Used]
      ,NULL AS [SSDS Incident ID]

FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN dlrosters r
  ON co.student_number = r.student_school_id
JOIN gabby.deanslist.behavior dlb 
  ON co.student_number = dlb.student_school_id
 AND co.academic_year = gabby.utilities.DATE_TO_SY(dlb.behavior_date)
 AND dlb.is_deleted = 0
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND dlb.behavior_date BETWEEN d.start_date AND d.end_date 
 AND d.identifier = 'RT'
 AND d._fivetran_deleted = 0
WHERE co.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.rn_year = 1
  AND co.schoolid = 73253