/*
--Demographics: all grades for 2014/15 � 2016/17 school years
---- Student identifier (can be scrambled if scrambled same way each year)
---- Gender
---- Race/ethnicity
---- ELL/LEP
---- Free/Reduced Price Lunch
---- Eligible for Special Education Services

SELECT student_number      
      ,academic_year
      ,reporting_schoolid
      ,grade_level
      ,gender
      ,ethnicity
      ,lep_status
      ,lunchstatus
      ,iep_status
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year BETWEEN 2014 AND 2016
  AND rn_year = 1
  AND schoolid <> 999999
--*/
/*
--Assessment Data: all applicable grades for 2014/15  � 2016/17 school years
----Student identifier (can be scrambled if scrambled same way each year)
----State summative test data (ELA, Math, Science, Social Studies)
----Test name
----Overall score in each subject
----Test characteristics data, such AS standard errors of measurement (SEMs)
----Regents exam scores in all subjects
----Interim assessment scores (e.g. MAP data)
SELECT student_number
      ,academic_year
      ,test_type      
      ,subject
      ,test_code
      ,test_scale_score      
      ,NULL AS test_percentile
      ,test_standard_error
      ,test_performance_level
FROM gabby.tableau.state_assessment_dashboard
WHERE academic_year BETWEEN 2014 AND 2016

UNION ALL

SELECT student_id  AS student_number
      ,academic_year
      ,'MAP' AS test_type
      ,measurement_scale AS subject
      ,NULL AS test_code
      ,test_ritscore AS test_scale_score
      ,test_percentile
      ,test_standard_error
      ,NULL AS test_performance_level      
FROM gabby.nwea.assessment_result_identifiers
WHERE academic_year BETWEEN 2014 AND 2016

UNION ALL

SELECT local_student_id AS student_number
      ,academic_year
      ,'KIPP NJ Interim Assessment' AS test_type
      ,subject_area AS subject
      ,COALESCE(module_number, term_administered) AS test_code
      ,percent_correct AS test_scale_score
      ,NULL AS test_percentile
      ,NULL AS test_standard_error
      ,performance_band_number AS test_performance_level      
FROM gabby.illuminate_dna_assessments.agg_student_responses_all
WHERE academic_year BETWEEN 2014 AND 2016
  AND scope = 'CMA - End-of-Module'
  AND response_type = 'O'
  AND percent_correct IS NOT NULL
--*/
-- /*
-- Teacher-Student Data Linkages 
-- --Student identifier  (can be scrambled if scrambled same way each year) linked to
-- courses
-- --Teacher identifier linked to courses
-- --Courses linked to assessment content area
select
    student_number,
    teachernumber,
    academic_year,
    course_name,
    credittype,
    illuminate_subject as parcc_subject,
    illuminate_subject as interim_subject,
    map_measurementscale
from gabby.powerschool.course_enrollments_static
-- */
/*
--Teacher Data
----ID crosswalk from HR data to Linkage data
----Teacher Name
----District hire date or years of teaching experience
----District email address 
----School name 
----School mailing address
----Grade level taught (if available)
----Subject area taught (if available)
----Relay Indicator

SELECT COALESCE(CAST(link.teachernumber AS VARCHAR), adp.associate_id) AS teacher_id
      ,CONCAT(adp.preferred_first, ' ', adp.preferred_last) AS teacher_name
      ,adp.hire_date AS district_hire_date
      ,ad.mail AS district_email_address
      ,adp.location_custom AS school_name
      ,adp.grades_taught_custom
      ,adp.subject_dept_custom            
FROM gabby.adp.staff_roster adp
LEFT JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
LEFT JOIN gabby.people.adp_ps_id_link link
  ON adp.associate_id = link.associate_id
 AND link.is_master = 1
WHERE adp.rn_curr = 1
--*/
where academic_year between 2014 and 2016 and illuminate_subject is not null
