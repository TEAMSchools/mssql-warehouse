USE gabby
GO

CREATE OR ALTER VIEW recruiting.prospects_report AS

SELECT candidate_id
      ,candidate_email
      ,candidate_first_name
      ,candidate_last_name
      ,candidate_source
      ,candidate_tags_values
      ,current_employer
      ,community_name
      ,community_application_status
      ,community_application_source
      ,community_application_state_added_date
      ,community_application_state_contacted_date
      ,community_application_state_not_interested_date
      ,community_application_state_not_selected_date
      ,brand_org_field_value
FROM gabby.smartrecruiters.report_prospects
WHERE community_name LIKE 'New Jami%'
