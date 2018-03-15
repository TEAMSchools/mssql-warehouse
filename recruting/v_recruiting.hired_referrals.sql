--CREATE OR ALTER VIEW 'recruiting.hired_referrals' AS

USE Gabby
GO

WITH all_hires AS (
     SELECT A.contact_id_c AS 'id'
           ,A.name AS 'Job_app'
           ,A.hired_status_date_c AS 'Hire_date'
           ,stage_c AS 'selection_stage'
           ,selection_status_c AS 'selection_status'
           ,job_position_c AS 'Job_Position'
           ,cultivation_owner_c AS 'Recruiter'
     FROM recruiting.job_application_c A LEFT JOIN recruiting.profile_application_c P
          ON A.contact_id_c = P.id

     WHERE A.stage_c = 'Hired'
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
       
ORDER BY Hire_date DESC