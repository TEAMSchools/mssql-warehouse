USE Gabby
GO

CREATE OR ALTER VIEW 'recruiting.hired_referrals' AS


WITH all_hires AS (
     SELECT a.contact_id_c AS id
           ,a.name AS job_app
           ,a.hired_status_date_c AS hire_date
           ,a.stage_c AS selection_stage
           ,a.selection_status_c AS selection_status
           ,a.job_position_c AS job_position
           ,a.cultivation_owner_c AS recruiter
           ,pa.name AS profile_id
     FROM gabby.recruiting.job_application_c a 
     LEFT JOIN gabby.recruiting.profile_application_c pa
       ON a.profile_application_c = pa.id
     WHERE a.stage_c = 'Hired'
)
,job_positions AS (
     SELECT id
           ,name AS position_number
           ,status_c
           ,position_name_c AS position_name
           
     FROM gabby.recruiting.job_position_c
) 
,df AS (
     SELECT df_employee_number
           ,salesforce_id
           ,COALESCE(rehire_date,original_hire_date) AS most_recent_hire_date
           ,termination_date 
           ,status
     FROM gabby.dayforce.staff_roster   
)

SELECT c.created_date
      ,c.name AS cultivation_number
      ,c.contact_name_c
      ,c.cultivation_stage_c              
      ,c.referred_by_c
      ,c.regional_source_detail_c
      ,c.regional_source_c
      ,c.cultivation_notes_c
      ,h.profile_id
      ,h.Job_app
      ,h.hire_date
      ,h.selection_stage
      ,h.selection_status
      ,h.Recruiter
      ,p.position_number
      ,p.status_c AS position_status
      ,p.position_name
      ,df.df_employee_number
      ,df.most_recent_hire_date
      ,df.termination_date 
      ,df.status
      ,DATEDIFF(dd,df.most_recent_hire_date,COALESCE(df.termination_date,GETDATE())) AS days_at_kipp
      ,CASE WHEN df_employee_number IS NULL THEN 'Not matched in Dayforce - need to look up manually to verify' ELSE NULL END AS dayforce_notes
      
FROM Recruiting.Cultivation_c c 
LEFT OUTER JOIN all_hires h
 ON LEFT(c.CONTACT_c,LEN(c.contact_c)-3) = h.id
LEFT OUTER JOIN job_positions p
 ON h.Job_Position = p.id
LEFT OUTER JOIN df
 ON p.position_number = df.salesforce_id

WHERE (c.cultivation_stage_c = 'Hired'
       OR h.selection_stage = 'Hired')
       AND c.regional_source_c = 'Referral' 