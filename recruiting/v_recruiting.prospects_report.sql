USE gabby
GO

CREATE OR ALTER TABLE gabby.recruiting.prospects_report AS

SELECT community_name
      ,candidate_first_name
      ,candidate_last_name
      ,candidate_email
      ,current_employer
      ,community_application_status
      ,community_application_source
      ,candidate_source
      ,community_application_state_added_date
      ,community_application_state_contacted_date
      ,community_application_state_not_interested_date
      ,community_application_state_not_selected_date
      ,candidate_tags_values
      ,brand_org_field_value
      ,candidate_id
FROM smartrecruiters.report_prospects
WHERE community_name LIKE '%Jami%'
