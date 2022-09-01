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
      ,CAST(JSON_VALUE(return_date, '$.date') AS DATE) AS return_date
      ,CAST(JSON_VALUE(issue_ts, '$.date') AS DATETIME2) AS issue_ts
      ,CAST(JSON_VALUE(update_ts, '$.date') AS DATETIME2) AS update_ts
      ,CAST(JSON_VALUE(close_ts, '$.date') AS DATETIME2) AS close_ts
      ,CAST(JSON_VALUE(review_ts, '$.date') AS DATETIME2) AS review_ts
      ,CAST(JSON_VALUE(create_ts, '$.date') AS DATETIME2) AS create_ts
      ,CAST(JSON_VALUE(dl_lastupdate, '$.date') AS DATETIME2) AS dl_lastupdate
      ,gabby.utilities.DATE_TO_SY(CAST(JSON_VALUE(create_ts, '$.date')) AS DATETIME2) AS create_academic_year
FROM deanslist.incidents
