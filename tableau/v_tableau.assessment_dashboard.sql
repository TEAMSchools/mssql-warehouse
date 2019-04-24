USE gabby
GO

CREATE OR ALTER VIEW tableau.assessment_dashboard AS

WITH teacher_crosswalk AS (
  SELECT sr.df_employee_number
        ,sr.preferred_name        
        ,sr.primary_site
        ,sr.primary_on_site_department
        ,sr.grades_taught
        ,sr.primary_job
        ,sr.legal_entity_name        
        ,sr.is_active
        ,sr.primary_site_schoolid
        ,sr.manager_df_employee_number
        ,sr.manager_name
        ,CASE
          WHEN sr.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
          WHEN sr.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
          WHEN sr.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
         END AS db_name
      
        ,COALESCE(idps.ps_teachernumber, sr.adp_associate_id, CONVERT(VARCHAR(25),sr.df_employee_number)) AS ps_teachernumber

        ,ads.samaccountname AS staff_username

        ,adm.samaccountname AS manager_username
  FROM gabby.dayforce.staff_roster sr
  LEFT JOIN gabby.people.id_crosswalk_powerschool idps
    ON sr.df_employee_number = idps.df_employee_number
   AND idps.is_master = 1
  LEFT JOIN gabby.adsi.user_attributes_static ads
    ON CONVERT(VARCHAR(25),sr.df_employee_number) = ads.employeenumber
  LEFT JOIN gabby.adsi.user_attributes_static adm
    ON CONVERT(VARCHAR(25),sr.manager_df_employee_number) = adm.employeenumber
  WHERE sr.primary_job IN ('Teacher', 'Teacher Fellow', 'Teacher in Residence', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator')
    AND ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid AS schoolid     
      ,co.region
      ,co.grade_level
      ,co.team      
      ,co.enroll_status
      ,co.cohort
      ,co.iep_status
      ,co.lep_status
      ,co.c_504_status
      ,co.is_pathways

      ,asr.assessment_id
      ,asr.title
      ,asr.scope            
      ,asr.subject_area
      ,asr.term_administered
      ,asr.administered_at
      ,asr.term_taken      
      ,asr.date_taken
      ,asr.response_type      
      ,asr.module_type      
      ,asr.module_number      
      ,asr.standard_code
      ,asr.standard_description
      ,asr.domain_description
      ,asr.percent_correct
      ,asr.is_mastery
      ,asr.performance_band_number      
      ,asr.is_replacement
            
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.teacher_name
        ELSE enr.teacher_name
       END AS teacher_name      
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.course_name
        ELSE enr.course_name
       END AS course_name
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.expression
        ELSE enr.expression
       END AS expression
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.section_number
        ELSE enr.section_number
       END AS section_number
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.teachernumber
        ELSE enr.teachernumber
       END AS ps_teacher_number

      ,tcw.df_employee_number
      ,tcw.staff_username
      ,tcw.manager_df_employee_number
      ,tcw.manager_name
      ,tcw.manager_username

FROM gabby.powerschool.cohort_identifiers_static co 
JOIN gabby.illuminate_dna_assessments.agg_student_responses_all asr
  ON co.student_number = asr.local_student_id
 AND co.academic_year = asr.academic_year
LEFT JOIN gabby.powerschool.course_enrollments_static enr
  ON co.student_number = enr.student_number
 AND co.academic_year = enr.academic_year
 AND co.db_name = enr.db_name
 AND asr.subject_area = enr.illuminate_subject COLLATE Latin1_General_BIN
 AND enr.course_enroll_status = 0 
 AND enr.section_enroll_status = 0 
 AND enr.rn_illuminate_subject = 1
LEFT JOIN gabby.powerschool.course_enrollments_static hr
  ON co.student_number = hr.student_number
 AND co.academic_year = hr.academic_year
 AND co.db_name = hr.db_name
 AND hr.course_number = 'HR'    
 AND hr.course_enroll_status = 0 
 AND hr.section_enroll_status = 0 
 AND hr.rn_course_yr = 1
LEFT JOIN teacher_crosswalk tcw
  ON tcw.ps_teachernumber = CASE WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.teachernumber ELSE enr.teachernumber END COLLATE Latin1_General_BIN
WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.reporting_schoolid NOT IN (5173, 999999) /* exclude OoD Placements */
  AND co.rn_year = 1