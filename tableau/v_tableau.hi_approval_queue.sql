USE gabby
GO

CREATE OR ALTER VIEW tableau.hi_approval_queue AS

WITH custom_fields AS (
  SELECT p.incident_id
        ,p.[Final approval]
        ,p.[Approver name]
        ,p.[Instructor Source]
        ,p.[Instructor Name]
        ,p.[Hours per week]
        ,p.[Hourly rate]
        ,p.[Board Approval Date]
        ,p.[HI start date]
        ,p.[HI end date]
  FROM
      (
       SELECT incident_id
             ,field_name
             ,[value]
       FROM gabby.deanslist.incidents_custom_fields
       WHERE field_name IN ('Final approval'
                           ,'Approver name'
                           ,'Instructor Source'
                           ,'Instructor Name'
                           ,'Hours per week'
                           ,'Hourly rate'
                           ,'Board Approval Date'
                           ,'HI start date'
                           ,'HI end date')
      ) sub
  PIVOT(
    MAX([value])
    FOR field_name IN ([Final approval]
                      ,[Approver name]
                      ,[Instructor Source]
                      ,[Instructor Name]
                      ,[Hours per week]
                      ,[Hourly rate]
                      ,[Board Approval Date]
                      ,[HI start date]
                      ,[HI end date])
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
            
      ,dli.student_id AS dl_student_id
      ,dli.incident_id AS dl_id            
      ,dli.[status]
      ,dli.[location]
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

      ,cf.[Final approval]
      ,CONCAT(u.first_name,' ',u.last_name) AS [Approver Name]
      ,cf.[Instructor Source]
      ,cf.[Instructor Name]
      ,cf.[Hours per week]
      ,cf.[Hourly rate]
      ,cf.[Board Approval Date]
      ,cf.[HI start date]
      ,cf.[HI end date]
FROM gabby.deanslist.incidents_clean_static dli
LEFT JOIN custom_fields cf
  ON dli.incident_id = cf.incident_id
LEFT JOIN gabby.deanslist.users u
  ON u.dluser_id = cf.[Approver name]
JOIN gabby.powerschool.cohort_identifiers_static co
  ON dli.student_school_id= co.student_number
 AND dli.create_academic_year = co.academic_year
 AND co.rn_year = 1
JOIN gabby.reporting.reporting_terms d
  ON co.schoolid = d.schoolid
 AND CONVERT(DATE, dli.create_ts) BETWEEN d.[start_date] AND d.end_date
 AND d.identifier = 'RT'
 AND d._fivetran_deleted = 0
WHERE dli.create_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND dli.category LIKE 'Home Instruction Request -%'