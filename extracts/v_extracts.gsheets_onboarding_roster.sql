USE gabby
GO

ALTER VIEW extracts.gsheets_onboarding_roster AS 

SELECT jp.name AS job_position_name        
      ,jp.position_name_c AS salesforce_position_name                    
      ,CASE                        
        WHEN ISNULL(CHARINDEX('_',jp.position_name_c), 0) = 0 THEN jp.position_name_c
        WHEN ISNULL(CHARINDEX('_', jp.position_name_c, (CHARINDEX('_',jp.position_name_c) + 1)) - (CHARINDEX('_',jp.position_name_c) - 1), 0) <= 0 
               THEN SUBSTRING(jp.position_name_c
                      ,(CHARINDEX('_',jp.position_name_c) + 1)
                      ,LEN(jp.position_name_c))
        ELSE SUBSTRING(jp.position_name_c
                      ,(CHARINDEX('_',jp.position_name_c) + 1)
                      ,(CHARINDEX('_', jp.position_name_c, (CHARINDEX('_',jp.position_name_c) + 1)) - CHARINDEX('_',jp.position_name_c) - 1))
       END AS salesforce_location               

       ,ja.contact_name_c AS salesforce_contact_name        
       ,CONVERT(NVARCHAR,ja.hired_status_date_c) AS hired_status_date__c       
       ,CASE WHEN ja.selection_status_c = 'Complete' THEN 'Accepted' ELSE ja.selection_status_c END AS selection_status__c 
       

       ,adp.first_name AS adp_first_name        
       ,adp.last_name AS adp_last_name    
       ,adp.preferred_name        
       ,adp.job_title_description AS adp_job_title        
       ,adp.job_title_custom AS adp_job_title_custom        
       ,CONVERT(NVARCHAR,adp.position_start_date) AS position_start_date
       ,adp.associate_id
       ,CONVERT(NVARCHAR,adp.hire_date) AS hire_date
       ,CASE WHEN adp.associate_id IS NOT NULL THEN 'Y' ELSE 'N' END AS in_adp
       
       ,CONVERT(NVARCHAR,ad.createtimestamp) AS ad_createdate
       ,ad.mail AS email_address        
       ,ad.samaccountname AS username        
       ,CASE
         WHEN ad.is_active IS NULL THEN 'New Hire'
         WHEN ad.is_active = 1 AND ad.createTimeStamp >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 6, 1) THEN 'New Hire'
         WHEN ad.is_active = 1 AND ad.createTimeStamp < DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 6, 1) THEN 'Returning Staff - Current'
         WHEN ad.is_active = 0 THEN 'Returning Staff - Departed'
        END AS ad_account_status
       ,CASE 
         WHEN ad.idautopersonalternateid IS NOT NULL THEN 'Y' 
         ELSE 'N' 
        END AS in_activedirectory

       ,ad.userprincipalname
       ,ad.displayname
       ,ad.givenname
       ,ad.sn
       ,ad.physicaldeliveryofficename
       ,ad.title
       ,ad.idautostatus

       ,jp.state_c status__c
       ,CONVERT(NVARCHAR,jp.created_date) AS createddate
       ,CONVERT(NVARCHAR,jp.date_position_filled_c) AS date_position_filled__c
FROM gabby.recruiting.job_position_c jp 
LEFT OUTER JOIN gabby.recruiting.job_application_c ja
  ON jp.id = ja.job_position_c
 AND ja.selection_status_c IN ('Complete','Withdrew')
 AND ja.stage_c = 'Hired'              
 AND ja.is_deleted = 0
LEFT OUTER JOIN gabby.adp.staff_roster adp
  ON jp.name = adp.salesforce_job_position_name_custom  
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
WHERE jp.region_c = 'New Jersey'
  AND jp.is_deleted = 0