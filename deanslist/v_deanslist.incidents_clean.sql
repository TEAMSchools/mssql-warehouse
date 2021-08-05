CREATE OR ALTER VIEW deanslist.incidents_clean AS

SELECT incident_id
      ,school_id
      ,student_id
      ,student_school_id
      ,infraction_type_id
      ,location_id
      ,[location]
      ,category_id
      ,category
      ,status_id
      ,[status]
      ,infraction
      ,reported_details
      ,admin_summary
      ,context
      ,addl_reqs
      ,family_meeting_notes
      ,create_by
      ,create_first
      ,create_middle
      ,create_last
      ,create_title
      ,update_by
      ,update_first
      ,update_middle
      ,update_last
      ,update_title
      ,is_referral
      ,is_active
      ,send_alert
      ,hearing_flag
      ,return_period
      ,reporting_incident_id
      ,CONVERT(DATE, JSON_VALUE(return_date, '$.date')) AS return_date
      ,CONVERT(DATETIME2, JSON_VALUE(issue_ts, '$.date')) AS issue_ts
      ,CONVERT(DATETIME2, JSON_VALUE(update_ts, '$.date')) AS update_ts
      ,CONVERT(DATETIME2, JSON_VALUE(close_ts, '$.date')) AS close_ts
      ,CONVERT(DATETIME2, JSON_VALUE(review_ts, '$.date')) AS review_ts
      ,CONVERT(DATETIME2, JSON_VALUE(create_ts, '$.date')) AS create_ts
      ,CONVERT(DATETIME2, JSON_VALUE(dl_lastupdate, '$.date')) AS dl_lastupdate
      ,gabby.utilities.DATE_TO_SY(CONVERT(DATETIME2, JSON_VALUE(create_ts, '$.date'))) AS create_academic_year
FROM deanslist.incidents
