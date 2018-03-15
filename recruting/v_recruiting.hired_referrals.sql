--CREATE OR ALTER VIEW 'recruiting.hired_referrals' AS

USE Gabby
GO

WITH all_hires AS (
     SELECT a.contact_id_c AS 'id'
           ,a.name AS 'job_app'
           ,a.hired_status_date_c AS 'hire_date'
           ,a.stage_c AS 'selection_stage'
           ,a.selection_status_c AS 'selection_status'
           ,a.job_position_c AS 'job_position'
           ,a.cultivation_owner_c AS 'recruiter'
     FROM recruiting.job_application_c a

     WHERE a.stage_c = 'Hired'
)
,job_positions AS (
     SELECT id
           ,position_name_c
           ,status_c
           
     FROM recruiting.job_position_c
)    

SELECT c.created_date
      ,c.name AS 'cultivation_number'
      ,c.contact_name_c
      ,c.cultivation_stage_c              
      ,c.referred_by_c
      ,c.regional_source_detail_c
      ,c.regional_source_c
      ,c.cultivation_notes_c   
      ,h.Job_app
      ,h.hire_date
      ,h.selection_stage
      ,h.selection_status
      ,h.Recruiter
      ,p.position_name_c
      ,p.status_c AS position_status
      
FROM Recruiting.Cultivation_c c 
LEFT OUTER JOIN all_hires h
 ON LEFT(c.CONTACT_c,LEN(c.contact_c)-3) = h.id
LEFT OUTER JOIN job_positions p
 ON h.Job_Position = p.id

WHERE (c.cultivation_stage_c = 'Hired'
       OR h.selection_stage = 'Hired')
       AND c.regional_source_c = 'Referral' 