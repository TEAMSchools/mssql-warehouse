USE gabby
GO

CREATE OR ALTER VIEW alumni.enrollment_identifiers AS

WITH enrollments AS (
  SELECT student_c
        ,MAX(CASE WHEN rn_recent_ugrad_enrollment = 1 THEN enrollment_c END) AS recent_ugrad_enrollment_c
        ,MAX(CASE WHEN is_ecc_degree_type = 1 AND rn_ecc_enrollment = 1 THEN enrollment_c END) AS ecc_enrollment_c      
        ,MAX(CASE WHEN is_hs_degree_type = 1 AND rn_hs_enrollment = 1 THEN enrollment_c END) AS hs_enrollment_c
  FROM
      (
       SELECT student_c      
             ,enrollment_c           
             ,is_ecc_degree_type
             ,is_hs_degree_type
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c
                  ORDER BY start_date_c DESC, actual_end_date_c DESC) AS rn_recent_ugrad_enrollment
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c, is_ecc_degree_type
                  ORDER BY start_date_c ASC, actual_end_date_c ASC) AS rn_ecc_enrollment
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c, is_hs_degree_type
                  ORDER BY start_date_c ASC, actual_end_date_c ASC) AS rn_hs_enrollment
       FROM
           (
            SELECT e.student_c
                  ,e.id AS enrollment_c                 
                  ,e.pursuing_degree_type_c
                  ,e.status_c
                  ,e.start_date_c
                  ,e.actual_end_date_c
                  ,CASE WHEN e.pursuing_degree_type_c IN ('Associate''s (2 year)', 'Bachelor''s (4-year)') THEN 1 ELSE 0 END AS is_ecc_degree_type      
                  ,CASE WHEN e.pursuing_degree_type_c = 'High School Diploma' THEN 1 ELSE 0 END AS is_hs_degree_type
            FROM gabby.alumni.enrollment_c e
            WHERE e.is_deleted = 0
              AND e.status_c != 'Did Not Enroll'
              AND ISNULL(e.pursuing_degree_type_c, '') NOT IN ('Graduate Degree', 'Master''s', 'MBA')
           ) sub
      ) sub
  GROUP BY student_c
 )

SELECT e.*

      ,ug.name AS ugrad_school_name      
      ,ug.pursuing_degree_type_c AS ugrad_pursuing_degree_type
      ,ug.status_c AS ugrad_status
      ,ug.start_date_c AS ugrad_start_date
      ,ug.actual_end_date_c AS ugrad_actual_end_date      

      ,ecc.name AS ecc_school_name      
      ,ecc.pursuing_degree_type_c AS ecc_pursuing_degree_type
      ,ecc.status_c AS ecc_status
      ,ecc.start_date_c AS ecc_start_date
      ,ecc.actual_end_date_c AS ecc_actual_end_date      

      ,ISNULL(ecca.adjusted_6_year_minority_graduation_rate_c, 0) AS ecc_adjusted_6_year_minority_graduation_rate

      ,hs.name AS hs_school_name      
      ,hs.pursuing_degree_type_c AS hs_pursuing_degree_type
      ,hs.status_c AS hs_status
      ,hs.start_date_c AS hs_start_date
      ,hs.actual_end_date_c AS hs_actual_end_date
FROM enrollments e
LEFT OUTER JOIN gabby.alumni.enrollment_c ug
  ON e.recent_ugrad_enrollment_c = ug.id
LEFT OUTER JOIN gabby.alumni.enrollment_c ecc
  ON e.ecc_enrollment_c = ecc.id
LEFT OUTER JOIN gabby.alumni.account ecca
  ON ecc.school_c = ecca.id
LEFT OUTER JOIN gabby.alumni.enrollment_c hs
  ON e.hs_enrollment_c = hs.id