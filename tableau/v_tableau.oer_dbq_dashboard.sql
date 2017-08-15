USE gabby
GO

ALTER VIEW tableau.oer_dbq_dashboard AS

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,REPLACE(enr.COURSE_NUMBER,'ENG11','ENG10') AS course_number
        ,enr.course_name
        ,enr.expression AS course_period
        ,enr.teacher_name      
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year, course_number
             ORDER BY section_enroll_status DESC, dateenrolled DESC) AS rn
  FROM gabby.powerschool.course_enrollments_static enr
  WHERE enr.academic_year >= 2015
    AND enr.credittype = 'ENG'      
    AND enr.schoolid = 73253
  
  UNION ALL

  SELECT enr.student_number
        ,enr.academic_year
        ,'ENG' AS course_number
        ,enr.course_name
        ,enr.expression AS course_period
        ,enr.teacher_name      
        ,1 AS rn
  FROM gabby.powerschool.course_enrollments_static enr 
  WHERE enr.academic_year <= 2014
    AND enr.credittype = 'ENG'  
    AND enr.section_enroll_status = 0
    AND enr.schoolid = 73253
    AND enr.rn_subject = 1    
 )  

,oer_repos AS (
  SELECT repository_id
        ,date_administered
        ,title
        ,student_number
        ,academic_year
        ,term
        ,unit_number
        ,series
        ,course_number
        ,repository_row_id
        ,field_label
        ,field_value

        ,SUBSTRING(field_label, CHARINDEX('_', field_label) + 1, 1) AS prompt_number
        ,SUBSTRING(field_label, CHARINDEX('_', field_label) + 3, LEN(field_label)) AS strand      
  FROM
      (
       SELECT r.repository_id
             ,r.date_administered
             ,r.title
      
             ,s.local_student_id AS student_number      

             ,LEFT(ur.[year], 4) AS academic_year
             ,CASE 
               WHEN gabby.utilities.DATE_TO_SY(r.date_administered) <= 2014 THEN REPLACE(ur.[quarter],'QE','Q') 
               ELSE rt.alt_name
              END AS term
             ,CASE 
               WHEN gabby.utilities.DATE_TO_SY(r.date_administered) <= 2014 THEN ur.[quarter]
               ELSE CONCAT('Unit ', RIGHT(r.title, 1)) 
              END AS unit_number
             ,CASE 
               WHEN gabby.utilities.DATE_TO_SY(r.date_administered) <= 2014 THEN RIGHT(ur.[quarter], 1)
               ELSE RIGHT(r.title, 1)
              END AS series
             ,CASE
               WHEN RIGHT(ur.[course], 1) = 'H' THEN CONCAT('ENG', LEFT(ur.[course], 1), 5)
               ELSE CONCAT('ENG',LEFT(ur.[course],2)) 
              END AS course_number

             ,ur.repository_row_id
             ,ur.prompt_1_analysis_of_evidence
             ,ur.prompt_1_choice_of_evidence
             ,ur.prompt_1_context_of_evidence
             ,ur.prompt_1_justification
             ,ur.prompt_1_overall
             ,ur.prompt_1_quality_of_ideas
             ,ur.prompt_2_analysis_of_evidence
             ,ur.prompt_2_choice_of_evidence
             ,ur.prompt_2_context_of_evidence
             ,ur.prompt_2_justification
             ,ur.prompt_2_overall
             ,ur.prompt_2_quality_of_ideas
             ,ur.prompt_3_analysis_of_evidence
             ,ur.prompt_3_choice_of_evidence
             ,ur.prompt_3_context_of_evidence
             ,ur.prompt_3_justification
             ,ur.prompt_3_overall
             ,ur.prompt_3_quality_of_ideas
             ,ur.prompt_4_analysis_of_evidence
             ,ur.prompt_4_choice_of_evidence
             ,ur.prompt_4_context_of_evidence
             ,ur.prompt_4_justification
             ,ur.prompt_4_overall
             ,ur.prompt_4_quality_of_ideas
       FROM gabby.illuminate_dna_repositories.oer_repositories ur
       JOIN gabby.illuminate_public.students s 
         ON ur.student_id = s.student_id
       JOIN gabby.illuminate_dna_repositories.repositories r
         ON ur.repository_id = r.repository_id
       LEFT OUTER JOIN gabby.reporting.reporting_terms rt
         ON r.date_administered BETWEEN CONVERT(DATE,rt.start_date) AND CONVERT(DATE,rt.end_date)
        AND rt.schoolid = 73253
        AND rt.identifier = 'RT'
      ) sub
  UNPIVOT(
    field_value
    FOR field_label IN (prompt_1_analysis_of_evidence
                       ,prompt_1_choice_of_evidence
                       ,prompt_1_context_of_evidence
                       ,prompt_1_justification
                       ,prompt_1_overall
                       ,prompt_1_quality_of_ideas
                       ,prompt_2_analysis_of_evidence
                       ,prompt_2_choice_of_evidence
                       ,prompt_2_context_of_evidence
                       ,prompt_2_justification
                       ,prompt_2_overall
                       ,prompt_2_quality_of_ideas
                       ,prompt_3_analysis_of_evidence
                       ,prompt_3_choice_of_evidence
                       ,prompt_3_context_of_evidence
                       ,prompt_3_justification
                       ,prompt_3_overall
                       ,prompt_3_quality_of_ideas
                       ,prompt_4_analysis_of_evidence
                       ,prompt_4_choice_of_evidence
                       ,prompt_4_context_of_evidence
                       ,prompt_4_justification
                       ,prompt_4_overall
                       ,prompt_4_quality_of_ideas)
   ) u
 )

SELECT co.schoolid
      ,co.grade_level      
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.iep_status  
      ,'OER' AS test_type

      ,w.title
      ,w.academic_year
      ,w.term
      ,w.unit_number
      ,w.course_number            
      ,w.strand
      ,w.prompt_number
      ,w.field_value AS score     
      
      ,enr.course_name
      ,enr.course_period
      ,enr.teacher_name
FROM oer_repos w
JOIN gabby.powerschool.cohort_identifiers_static co
  ON w.student_number = co.student_number
 AND w.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.academic_year = enr.academic_year 
 AND w.course_number = enr.course_number 
 AND enr.rn = 1

UNION ALL

/* DBQs */
SELECT sub.schoolid
      ,sub.grade_level
      ,sub.student_number
      ,sub.lastfirst
      ,sub.team
      ,sub.iep_status
      ,'DBQ' AS test_type
      ,sub.title
      ,sub.academic_year
      ,sub.term
      ,CONCAT('DBQ',RIGHT(sub.unit_number,1)) AS unit_number
      ,sub.course_number
      ,sub.strand
      ,sub.prompt_number
      ,sub.score
      ,enr.course_name
      ,enr.expression AS course_period
      ,enr.teacher_name
FROM
    (
     SELECT co.student_number
           ,co.lastfirst
           ,co.academic_year
           ,co.schoolid
           ,co.grade_level           
           ,co.team
           ,co.iep_status

           ,dts.alt_name AS term      

           ,a.title
           ,LEFT(a.title, 6) AS course_number           
           ,CASE
             WHEN co.academic_year <= 2015 THEN SUBSTRING(a.title, PATINDEX('%QE_%', a.title), 3)
             ELSE SUBSTRING(a.title, PATINDEX('%DBQ _%', a.title), 5) 
            END AS unit_number
           
           ,std.description AS strand
           
           ,CONVERT(FLOAT,r.percent_correct) AS score

           ,1 AS prompt_number
     FROM gabby.illuminate_dna_assessments.assessments a
     JOIN gabby.illuminate_codes.dna_scopes dsc
       ON a.code_scope_id = dsc.code_id
      AND dsc.code_translation = 'DBQ'
     JOIN gabby.illuminate_codes.dna_subject_areas dsu
       ON a.code_subject_area_id = dsu.code_id
      AND dsu.code_translation = 'History'
     JOIN gabby.reporting.reporting_terms dts
       ON a.administered_at BETWEEN CONVERT(DATE,dts.start_date) AND CONVERT(DATE,dts.end_date)
      AND dts.schoolid = 73253
      AND dts.identifier = 'RT'     
     JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard r
       ON a.assessment_id = r.assessment_id      
     JOIN gabby.illuminate_public.students s
       ON r.student_id = s.student_id     
     JOIN gabby.powerschool.cohort_identifiers_static co
       ON s.local_student_id = co.student_number
      AND (a.academic_year - 1) = co.academic_year
      AND co.rn_year = 1
     JOIN gabby.illuminate_standards.standards std
       ON r.standard_id = std.standard_id
     WHERE (a.academic_year - 1) >= 2016
    ) sub
LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr
  ON sub.student_number = enr.student_number
 AND sub.academic_year = enr.academic_year
 AND sub.course_number = enr.course_number
 AND enr.section_enroll_status = 0