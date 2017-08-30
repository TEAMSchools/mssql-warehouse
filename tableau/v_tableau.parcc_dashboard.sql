USE gabby
GO

--ALTER VIEW tableau.parcc_dashboard AS

WITH external_prof AS (
  SELECT academic_year        
        ,test_code
        ,grade_level
        ,[NJ]
        ,[NPS]
        ,[CPS]
        ,[PARCC]        
  FROM
      (
       SELECT academic_year
             ,test_code
             ,grade_level
             ,entity
             ,pct_proficient
       FROM gabby.parcc.external_proficiency_rates
       WHERE (test_code IN ('ALG01','ALG02','GEO01') AND grade_level IS NULL)
          OR (test_code NOT IN ('ALG01','ALG02','GEO01') AND grade_level IS NOT NULL)
      ) sub
  PIVOT(
    MAX(pct_proficient)
    FOR entity IN ([NJ]
                  ,[NPS]
                  ,[PARCC]
                  ,[CPS])
   ) p
 ) 

--SELECT co.student_number
--      ,co.state_studentnumber 
--      ,co.lastfirst
--      ,co.academic_year
--      ,co.region      
--      ,co.school_level     
--      ,co.reporting_schoolid AS schoolid           
--      ,co.grade_level 
--      ,co.enroll_status
--      ,co.iep_status
--      ,co.lep_status
--      ,co.lunchstatus      
      
--      ,'PARCC' AS test_type
--      ,parcc.test_code
--      ,parcc.subject      
--      ,parcc.test_scale_score
--      ,parcc.test_performance_level
--      ,CASE
--        WHEN parcc.test_performance_level >= 4 THEN 1
--        WHEN parcc.test_performance_level < 4 THEN 0
--       END AS is_proficient

--      ,ext.nj AS pct_prof_nj
--      ,ext.nps AS pct_prof_nps
--      ,ext.cps AS pct_prof_cps
--      ,ext.parcc AS pct_prof_parcc       
--FROM gabby.powerschool.cohort_identifiers_static co
--JOIN gabby.parcc.summative_record_file_clean parcc
--  ON co.student_number = parcc.local_student_identifier
-- AND co.academic_year = LEFT(parcc.assessment_year, 4)
--LEFT OUTER JOIN external_prof ext
--  ON co.academic_year = ext.academic_year
-- AND parcc.test_code = ext.test_code
--WHERE co.rn_year = 1

--UNION ALL

SELECT co.student_number
      ,co.state_studentnumber 
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.school_level     
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level 
      ,co.enroll_status
      ,co.iep_status
      ,co.lep_status
      ,co.lunchstatus      
      
      ,'NJASK' AS test_type
      ,CONCAT(LEFT(njask.subject, 3), RIGHT(CONCAT('0', co.grade_level), 2)) AS test_code
      ,njask.subject      
      ,njask.scaled_score
      ,njask.performance_level
      ,CASE
        WHEN njask.scaled_score = 0 THEN NULL
        WHEN njask.scaled_score >= 200 THEN 1
        WHEN njask.scaled_score < 200 THEN 0
       END AS is_proficient

      --,ext.nj AS pct_prof_nj
      --,ext.nps AS pct_prof_nps
      --,ext.cps AS pct_prof_cps
      --,ext.parcc AS pct_prof_parcc       
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.njsmart.njask_clean njask
  ON co.student_number = njask.local_student_id
 AND co.academic_year = njask.academic_year
--LEFT OUTER JOIN external_prof ext
--  ON co.academic_year = ext.academic_year
-- AND parcc.test_code = ext.test_code
WHERE co.rn_year = 1

--/* NJASK & HSPA */
--SELECT co.student_number
--      ,co.SID
--      ,co.lastfirst
--      ,co.year AS academic_year
--      ,co.reporting_schoolid AS schoolid           
--      ,co.grade_level            
--      ,co.school_level     
--      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
--      ,co.SPEDLEP
--      ,co.LEP_STATUS
--      ,co.lunchstatus
--      ,co.enroll_status
      
--      ,CASE
--        WHEN co.schoolid = 73253 THEN 'HSPA'
--        ELSE 'NJASK' 
--       END AS test_type
--      ,CONCAT(nj.subject, ' ', co.grade_level)  AS testcode
--      ,nj.subject      
--      ,nj.scale_score AS summativescalescore      
--      ,CASE
--        WHEN nj.prof_level IN ('Below Proficient','Partially Proficient') THEN 1
--        WHEN nj.prof_level = 'Proficient' THEN 4
--        WHEN nj.prof_level = 'Advanced Proficient' THEN 5
--       END AS summativeperformancelevel      
--      ,NULL AS summativereadingscalescore            
--      ,NULL AS summativewritingscalescore                        

--      ,NULL AS pbatotaltestitems      
--      ,NULL AS pbatotaltestitemsattempted
--      ,NULL AS eoytotaltestitems                  
--      ,NULL AS eoytotaltestitemsattempted

--      ,NULL AS is_optout
--      ,nj.is_prof

--      ,ext.NJ AS pct_prof_NJ
--      ,ext.NPS AS pct_prof_NPS
--      ,ext.CPS AS pct_prof_CPS
--      ,ext.PARCC AS pct_prof_PARCC
--FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
--JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_hspa_scores nj WITH(NOLOCK)
--  ON co.student_number = nj.student_number
-- AND co.year = nj.academic_year 
-- AND nj.void_reason IS NULL
--LEFT OUTER JOIN external_prof ext
--  ON co.year = ext.academic_year
-- AND co.grade_level = ext.grade_level
-- AND nj.subject = ext.testcode
--WHERE co.rn = 1