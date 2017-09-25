USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_basic_contact_dump AS

WITH attending_enrollment AS (
  SELECT e.Id AS enrollment_id
        ,e.Student_c
        ,e.School_c
        ,e.Status_c
        ,e.Start_Date_c
        ,e.Actual_End_Date_c
        ,e.Major_c              
        ,e.Pursuing_Degree_Type_c        
        ,e.date_last_verified_c

        ,a.NCESid_c
        ,a.name AS account_name
        ,a.type AS account_type    

        ,ROW_NUMBER() OVER(
           PARTITION BY e.Student_c
             ORDER BY e.Start_Date_c DESC) AS rn  
  FROM gabby.alumni.Enrollment_c e WITH(NOLOCK)
  LEFT OUTER JOIN gabby.alumni.Account a WITH(NOLOCK)
    ON e.School_c = a.Id   
  WHERE e.status_c IN ('Attending','Matriculated')
    AND e.start_date_c < DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 7, 1)
    AND e.is_deleted = 0
 )

,next_yr_enrollment AS (
  SELECT student_c
        ,pursuing_degree_type_c
  FROM gabby.alumni.enrollment_c
  WHERE type_c = 'College'
    AND pursuing_degree_type_c IN ('Associate''s (2 year)','Bachelor''s (4-year)')
    AND start_date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 7, 1)
    AND status_c IN ('Attending','Matriculated')
    AND is_deleted = 0
 )

,checkins AS (
  SELECT contact_id        
        ,AAS
        ,PSC1
        ,PSC2
        ,REM        
  FROM
      (
       SELECT c.Contact_c AS contact_id
             ,CASE 
               WHEN c.subject_c LIKE 'AAS_' THEN 'AAS'               
               WHEN c.subject_c = 'PSC' AND MONTH(c.date_c) >= 7 THEN 'PSC1'
               WHEN c.subject_c = 'PSC' AND MONTH(c.date_c) < 7 THEN 'PSC2'
               ELSE c.subject_c
              END AS contact_subject
             ,c.Date_c AS contact_date             
       FROM gabby.alumni.Contact_Note_c c WITH(NOLOCK)       
       WHERE (c.Subject_c LIKE 'AAS_' OR c.Subject_c = 'PSC' OR c.Subject_c = 'REM')
         AND gabby.utilities.DATE_TO_SY(c.Date_c) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
         AND c.is_deleted = 0
      ) sub
  PIVOT(
    COUNT(contact_date)
    FOR contact_subject IN ([AAS]
                           ,[PSC1]
                           ,[PSC2]
                           ,[REM]
                           )
   ) p
 )

,marking_period AS (
  SELECT *
  FROM
      (
       SELECT enrollment_c
             ,CONCAT(field, '_MP', number_c) AS pivot_field
             ,value
       FROM
           (
            SELECT enrollment_c
                  ,school_year_c
                  ,number_c
                  ,CONVERT(FLOAT,report_card_transcript_received_c) AS transcript_collected
                  ,GPA_c AS GPA                
            FROM gabby.alumni.marking_period_c
            WHERE school_year_c = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
              AND is_deleted = 0
           ) sub
       UNPIVOT(
         value
         FOR field IN (transcript_collected
                      ,GPA)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([GPA_MP1] 
                       ,[GPA_MP2]
                       ,[transcript_collected_MP1] 
                       ,[transcript_collected_MP2])
   ) p
 )

,stipends AS (
  SELECT student_c
        ,[F] AS stipend_status_fall
        ,[S] AS stipend_status_spr
  FROM
      (
       SELECT a.Student_c        
             ,a.Status_c        
             ,CASE 
               WHEN DATEPART(MONTH, a.Date_c) BETWEEN 7 AND 12 THEN 'F'
               ELSE 'S'
              END AS semester             
             --,a.Amount_c
       FROM gabby.alumni.kipp_aid_c a 
       WHERE a.type_c = 'College Book Stipend Program'
         AND a.is_deleted = 0
         AND a.date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
      ) sub
  PIVOT(
    MAX(status_c)
    FOR semester IN ([F], [S])
   ) p
 )

,oot_roster AS (
  SELECT contact_id
        ,last_successful_contact_date
        ,missing_start_date
        ,found_date
        ,is_still_missing
        ,n_months_elapsed
        ,gabby.utilities.DATE_TO_SY(missing_start_date) AS missing_academic_year
        ,gabby.utilities.DATE_TO_SY(found_date) AS found_academic_year
  FROM
      (
       SELECT Contact_c AS contact_id
             ,Date_c AS last_successful_contact_date
             ,DATEADD(MONTH, 12, Date_c) AS missing_start_date
             ,COALESCE(LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c ASC), GETDATE()) AS found_date
             ,CASE WHEN LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c ASC) IS NULL THEN 1 END AS is_still_missing
             ,DATEDIFF(MONTH
                      ,Date_c
                      ,COALESCE(LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c), GETDATE())) AS n_months_elapsed
       FROM gabby.alumni.Contact_Note_c c WITH(NOLOCK)
       WHERE Status_c = 'Successful'
         AND is_deleted = 0
      ) sub
  WHERE n_months_elapsed >= 12
 ) 

,counselor_changes AS (
  SELECT contact_id      
        ,new_value
        ,ROW_NUMBER() OVER(
           PARTITION BY contact_id
             ORDER BY created_date DESC) AS rn
  FROM gabby.alumni.contact_history
  WHERE field = 'Owner'
    AND created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 07, 01)
    AND old_value IN ('Jessica Gersh','Eric Fisher','KNJ Admin')    
    AND is_deleted = 0
)

,transfer_apps AS (
  SELECT applicant_c
        ,[4YR]
        ,[2YR]
        ,[4YR_T]
        ,[2YR_T]
        ,[ALL]
  FROM
      (
       SELECT a.applicant_c      
             ,ISNULL(CASE 
                      WHEN s.type LIKE '%2 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '2YR'
                      WHEN s.type LIKE '%4 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '4YR'
                      WHEN s.type LIKE '%2 yr' AND a.transfer_application_c = 1 THEN '2YR_T'
                      WHEN s.type LIKE '%4 yr' AND a.transfer_application_c = 1 THEN '4YR_T'       
                     END,'ALL') AS school_type
             ,COUNT(a.id) AS N
       FROM gabby.alumni.application_c a
       JOIN gabby.alumni.account s
         ON a.school_c = s.id
       WHERE a.application_submission_status_c = 'Submitted'                  
         AND a.created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 07, 01)
         AND a.is_deleted = 0
       GROUP BY a.applicant_c      
               ,CUBE(CASE 
                      WHEN s.type LIKE '%2 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '2YR'
                      WHEN s.type LIKE '%4 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '4YR'
                      WHEN s.type LIKE '%2 yr' AND a.transfer_application_c = 1 THEN '2YR_T'
                      WHEN s.type LIKE '%4 yr' AND a.transfer_application_c = 1 THEN '4YR_T'
                     END)
      ) sub
  PIVOT(
    MAX(N)
    FOR school_type IN ([4YR],[2YR],[4YR_T],[2YR_T],[ALL]) 
   ) p
)

SELECT c.id AS contact_id
      ,c.school_specific_id_c AS student_number
      ,CONCAT(c.first_name, ' ', c.last_name) AS Full_Name_c
      ,c.first_name AS FirstName
      ,c.last_name AS LastName
      ,c.kipp_hs_class_c
      ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1) - DATEPART(YEAR, c.expected_hs_graduation_c) AS years_out_of_HS
      ,c.currently_enrolled_school_c
      ,c.kipp_ms_graduate_c
      ,c.middle_school_attended_c
      ,c.kipp_hs_graduate_c
      ,c.high_school_graduated_from_c
      ,c.college_graduated_from_c      
      ,c.gender_c
      ,c.ethnicity_c      
      ,c.cumulative_gpa_c
      ,c.college_credits_attempted_c
      ,c.accumulated_credits_college_c            
      ,c.transcript_release_c
      ,c.latest_fafsa_date_c
      ,c.latest_state_financial_aid_app_date_c
      ,c.latest_resume_c     
      ,c.informed_consent_c 
      ,c.expected_college_graduation_c
      ,c.expected_hs_graduation_c
      ,c.post_hs_simple_admin_c
      ,c.last_outreach_c
      ,c.last_successful_contact_c
      ,c.actual_hs_graduation_date_c
      ,c.actual_college_graduation_date_c      

      ,rt.name AS record_type

      ,oot.n_months_elapsed
      ,CASE 
        --WHEN c.Post_HS_Simple_Admin_c IN ('College Grad - BA') THEN 0 /* exclude grads */
        --WHEN c.college_graduated_from_c IS NOT NULL THEN 0
        WHEN oot.contact_id IS NOT NULL THEN 1
        ELSE 0 
       END AS is_oot_baseline
      ,CASE 
        --WHEN c.Post_HS_Simple_Admin_c IN ('College Grad - BA') THEN 0 /* exclude grads */
        --WHEN c.college_graduated_from_c IS NOT NULL THEN 0
        WHEN oot.is_still_missing = 1 THEN 1
        ELSE 0 
       END AS is_out_of_touch            
      ,CASE 
        --WHEN c.Post_HS_Simple_Admin_c IN ('College Grad - BA') THEN 0 /* exclude grads */
        WHEN oot.contact_id IS NOT NULL AND u.name = cc.new_value THEN 1 ELSE 0 
       END AS is_oot_assigned
      ,CASE 
        --WHEN c.Post_HS_Simple_Admin_c IN ('College Grad - BA') THEN 0 /* exclude grads */
        WHEN oot.found_date IS NOT NULL THEN 1 
        ELSE 0 
       END AS is_found_this_term      
      
      ,u.name AS ktc_manager

      ,e.Major_c
      ,e.Pursuing_Degree_Type_c
      ,e.Start_Date_c
      ,e.Status_c AS enrollment_status
      ,e.account_name
      ,e.account_type  
      ,e.NCESid_c
      ,e.date_last_verified_c

      ,cn.AAS
      ,cn.PSC1
      ,cn.PSC2
      ,cn.REM      
           
      ,mp.transcript_collected_MP1
      ,mp.transcript_collected_MP2
      ,mp.GPA_MP1
      ,mp.GPA_MP2      
      ,COALESCE(mp.GPA_MP2, mp.GPA_MP1) AS GPA_recent      

      ,s.stipend_status_fall
      ,s.stipend_status_spr           

      ,app.[2YR] AS N_2YR_apps
      ,app.[4YR] AS N_4YR_apps
      ,app.[2YR_T] AS N_2YR_transfer_apps
      ,app.[4YR_T] AS N_4YR_transfer_apps
      ,app.[ALL] AS N_apps_all

      ,nye.pursuing_degree_type_c AS next_year_pursuing_degree_type
FROM gabby.alumni.contact c 
JOIN gabby.alumni.record_type rt
  ON c.record_type_id = rt.id
JOIN gabby.alumni.[user] u 
  ON c.owner_id = u.Id
LEFT OUTER JOIN attending_enrollment e
  ON c.id = e.student_c 
 AND e.rn = 1 
LEFT OUTER JOIN checkins cn
  ON c.Id = cn.contact_id
LEFT OUTER JOIN marking_period mp
  ON e.enrollment_id = mp.enrollment_c
LEFT OUTER JOIN stipends s
  ON c.id = s.student_c
LEFT OUTER JOIN oot_roster oot
  ON c.Id = oot.contact_id
 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR() BETWEEN oot.missing_academic_year AND oot.found_academic_year
LEFT OUTER JOIN counselor_changes cc
  ON c.id = cc.contact_id
 AND cc.rn = 1
LEFT OUTER JOIN transfer_apps app
  ON c.id = app.applicant_c
LEFT OUTER JOIN next_yr_enrollment nye
  ON c.id = nye.student_c