USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_basic_contact_dump AS

WITH attending_enrollment AS (
  SELECT e.id AS enrollment_id
        ,e.student_c
        ,e.school_c
        ,e.status_c
        ,e.start_date_c
        ,e.actual_end_date_c
        ,e.major_c              
        ,e.pursuing_degree_type_c        
        ,e.date_last_verified_c

        ,a.ncesid_c
        ,a.name AS account_name
        ,a.type AS account_type    
        ,a.billing_state

        ,ROW_NUMBER() OVER(
           PARTITION BY e.student_c
             ORDER BY e.start_date_c DESC) AS rn  
  FROM gabby.alumni.enrollment_c e
  LEFT OUTER JOIN gabby.alumni.account a
    ON e.school_c = a.id   
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
    AND start_date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 1, 1)
    AND status_c IN ('Attending','Matriculated')
    AND is_deleted = 0
 )

,checkins AS (
  SELECT contact_id        
        ,AAS1F
        ,AAS2F
        ,AAS1S
        ,AAS2S
        ,PSC1
        ,PSC2
        ,REM        
  FROM
      (
       SELECT c.Contact_c AS contact_id
             ,CASE 
               WHEN c.category_c = 'Benchmark' AND MONTH(c.date_c) >= 7 THEN 'AAS1F'
               WHEN c.category_c = 'Benchmark' AND MONTH(c.date_c) < 7 THEN 'AAS1S'
               WHEN c.category_c = 'Benchmark Follow-Up' AND MONTH(c.date_c) >= 7 THEN 'AAS2F'
               WHEN c.category_c = 'Benchmark Follow-Up' AND MONTH(c.date_c) < 7 THEN 'AAS2S'               
               WHEN c.subject_c LIKE 'PSC%' AND MONTH(c.date_c) >= 7 THEN 'PSC1'
               WHEN c.subject_c LIKE 'PSC%' AND MONTH(c.date_c) < 7 THEN 'PSC2'
               ELSE c.subject_c
              END AS contact_subject
             ,c.Date_c AS contact_date             
       FROM gabby.alumni.Contact_Note_c c
       WHERE ((c.Subject_c LIKE 'PSC%' OR c.Subject_c = 'REM') OR (c.category_c IN ('Benchmark','Benchmark Follow-Up')))
         AND gabby.utilities.DATE_TO_SY(c.Date_c) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
         AND c.is_deleted = 0
      ) sub
  PIVOT(
    COUNT(contact_date)
    FOR contact_subject IN ([AAS1F]
                           ,[AAS2F]
                           ,[AAS1S]
                           ,[AAS2S]
                           ,[PSC1]
                           ,[PSC2]
                           ,[REM])
   ) p
 )

,gpa AS (
  SELECT student_c        
        ,[fall_semester_gpa]
        ,[fall_academic_status]
        ,[spring_semester_gpa]
        ,[spring_academic_status]
  FROM
      (
       SELECT student_c             
             ,semester + '_' + field AS pivot_field
             ,value
       FROM
           (
            SELECT student_c                  
                  ,CASE
                    WHEN MONTH(transcript_date_c) = 8 AND DAY(transcript_date_c) = 31 THEN 'spring'
                    WHEN MONTH(transcript_date_c) = 12 AND DAY(transcript_date_c) = 31 THEN 'fall'
                   END AS semester
                  ,CONVERT(VARCHAR,semester_gpa_c) AS semester_gpa
                  ,CONVERT(VARCHAR,academic_status_c) AS academic_status
            FROM gabby.alumni.gpa_c
            WHERE transcript_date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
           ) sub
       UNPIVOT(
         value
         FOR field IN (semester_gpa, academic_status)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([fall_semester_gpa]
                       ,[fall_academic_status]
                       ,[spring_semester_gpa]
                       ,[spring_academic_status])
   ) p
 )

,stipends AS (
  SELECT student_c
        ,CASE 
          WHEN [F] IS NOT NULL THEN 'Approved'
          WHEN [F] IS NULL THEN 'Not Picked Up'
        END AS stipend_status_fall
        ,CASE 
          WHEN [S] IS NOT NULL THEN 'Approved'
          WHEN [S] IS NULL THEN 'Not Picked Up'
        END AS stipend_status_spr
  FROM
      (
       SELECT a.student_c        
             ,a.date_c
             ,CASE 
               WHEN DATEPART(MONTH, a.created_date) BETWEEN 7 AND 12 THEN 'F'
               ELSE 'S'
              END AS semester             
       FROM gabby.alumni.kipp_aid_c a 
       WHERE a.type_c = 'College Book Stipend Program'
         AND a.Status_c = 'Approved'
         AND a.is_deleted = 0
         AND a.created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
      ) sub
  PIVOT(
    MAX(date_c)
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
        ,ROW_NUMBER() OVER(
           PARTITION BY contact_id, gabby.utilities.DATE_TO_SY(missing_start_date)
             ORDER BY last_successful_contact_date DESC) AS rn
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
       FROM gabby.alumni.contact_note_c c
       WHERE Status_c = 'Successful'
         AND is_deleted = 0
      ) sub
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
      ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1) - DATEPART(YEAR, c.actual_hs_graduation_date_c) AS years_out_of_HS
      ,c.college_status_c
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
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL) THEN 1
        ELSE 0 
       END AS is_oot_baseline
      ,CASE         
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL)
         AND oot.is_still_missing = 1 THEN 1
        ELSE 0 
       END AS is_out_of_touch            
      ,CASE         
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL)
         AND u.name = cc.new_value 
             THEN 1 
        ELSE 0 
       END AS is_oot_assigned
      ,CASE         
        WHEN oot.found_date IS NOT NULL THEN 1 
        ELSE 0 
       END AS is_found_this_term      
      
      ,u.name AS ktc_manager

      ,e.major_c
      ,e.pursuing_degree_type_c
      ,e.start_date_c
      ,e.status_c AS enrollment_status
      ,e.account_name
      ,e.account_type  
      ,e.billing_state
      ,e.ncesid_c
      ,e.date_last_verified_c

      ,cn.AAS1F
      ,cn.AAS2F
      ,cn.AAS1S
      ,cn.AAS2S
      ,cn.PSC1
      ,cn.PSC2
      ,cn.REM                 
      
      ,gpa.fall_academic_status 
      ,gpa.spring_academic_status
      ,gpa.fall_semester_gpa AS gpa_mp1
      ,gpa.spring_semester_gpa AS gpa_mp2      
      ,COALESCE(gpa.fall_academic_status, gpa.spring_academic_status) AS gpa_recent
      ,CASE
        WHEN gpa.fall_semester_gpa IS NOT NULL THEN 1        
        ELSE 0
       END AS transcript_collected_mp1
      ,CASE
        WHEN gpa.spring_semester_gpa IS NOT NULL THEN 1
        ELSE 0
       END AS transcript_collected_mp2

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
  ON c.id = cn.contact_id
LEFT OUTER JOIN gpa
  ON c.id = gpa.student_c
LEFT OUTER JOIN stipends s
  ON c.id = s.student_c
LEFT OUTER JOIN oot_roster oot
  ON c.Id = oot.contact_id
 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR() BETWEEN oot.missing_academic_year AND oot.found_academic_year
 AND oot.rn = 1
LEFT OUTER JOIN counselor_changes cc
  ON c.id = cc.contact_id
 AND cc.rn = 1
LEFT OUTER JOIN transfer_apps app
  ON c.id = app.applicant_c
LEFT OUTER JOIN next_yr_enrollment nye
  ON c.id = nye.student_c