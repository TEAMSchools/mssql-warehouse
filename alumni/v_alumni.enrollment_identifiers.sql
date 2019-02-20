USE gabby
GO

CREATE OR ALTER VIEW alumni.enrollment_identifiers AS

WITH enrollments AS (
  SELECT student_c
        ,MAX(CASE WHEN is_ugrad_degree_type = 1 AND rn_recent_ugrad_enrollment = 1 THEN enrollment_c END) AS recent_ugrad_enrollment_c
        ,MAX(CASE WHEN is_ugrad_degree_type = 1 AND rn_ecc_enrollment = 1 THEN enrollment_c END) AS ecc_enrollment_c
        ,MAX(CASE WHEN is_hs_degree_type = 1 AND rn_hs_enrollment = 1 THEN enrollment_c END) AS hs_enrollment_c
  FROM
      (
       SELECT student_c
             ,enrollment_c
             ,is_ugrad_degree_type
             ,is_hs_degree_type
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c, is_ugrad_degree_type
                  ORDER BY start_date_c DESC, actual_end_date_c DESC) AS rn_recent_ugrad_enrollment
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c, is_ecc_enrollment
                  ORDER BY start_date_c ASC, actual_end_date_c ASC) AS rn_ecc_enrollment
             ,ROW_NUMBER() OVER(
                PARTITION BY student_c, is_hs_degree_type
                  ORDER BY start_date_c ASC, actual_end_date_c ASC) AS rn_hs_enrollment
       FROM
           (
            SELECT e.student_c
                  ,e.id AS enrollment_c
                  ,e.start_date_c
                  ,e.actual_end_date_c
                  ,CASE WHEN e.pursuing_degree_type_c = 'High School Diploma' THEN 1 ELSE 0 END AS is_hs_degree_type
                  ,CASE WHEN e.pursuing_degree_type_c IN ('Associate''s (2 year)', 'Bachelor''s (4-year)') THEN 1 ELSE 0 END AS is_ugrad_degree_type
                  ,CASE
                    WHEN e.pursuing_degree_type_c IN ('Associate''s (2 year)', 'Bachelor''s (4-year)')
                     AND DATEFROMPARTS(DATEPART(YEAR,c.actual_hs_graduation_date_c), 10, 31) BETWEEN e.start_date_c AND COALESCE(e.actual_end_date_c, GETDATE())
                         THEN 1
                    ELSE 0
                   END AS is_ecc_enrollment
            FROM gabby.alumni.enrollment_c e
            JOIN gabby.alumni.contact c
              ON e.student_c = c.id
             AND c.is_deleted = 0
            WHERE e.is_deleted = 0
              AND e.status_c != 'Did Not Enroll'
              AND ISNULL(e.pursuing_degree_type_c, '') NOT IN ('Graduate Degree', 'Master''s', 'MBA')
           ) sub
      ) sub
  GROUP BY student_c
 )

SELECT e.student_c
      ,e.recent_ugrad_enrollment_c
      ,e.ecc_enrollment_c
      ,e.hs_enrollment_c

      ,ug.name AS ugrad_school_name      
      ,ug.pursuing_degree_type_c AS ugrad_pursuing_degree_type
      ,ug.status_c AS ugrad_status
      ,ug.start_date_c AS ugrad_start_date
      ,ug.actual_end_date_c AS ugrad_actual_end_date      
      ,ug.anticipated_graduation_c AS ugrad_anticipated_graduation
      ,ug.account_type_c AS ugrad_account_type

      ,ecc.name AS ecc_school_name      
      ,ecc.pursuing_degree_type_c AS ecc_pursuing_degree_type
      ,ecc.status_c AS ecc_status
      ,ecc.start_date_c AS ecc_start_date
      ,ecc.actual_end_date_c AS ecc_actual_end_date      
      ,ecc.anticipated_graduation_c AS ecc_anticipated_graduation
      ,ecc.account_type_c AS ecc_account_type

      ,ecca.adjusted_6_year_minority_graduation_rate_c AS ecc_adjusted_6_year_minority_graduation_rate

      ,hs.name AS hs_school_name      
      ,hs.pursuing_degree_type_c AS hs_pursuing_degree_type
      ,hs.status_c AS hs_status
      ,hs.start_date_c AS hs_start_date
      ,hs.actual_end_date_c AS hs_actual_end_date
      ,hs.anticipated_graduation_c AS hs_anticipated_graduation
      ,hs.account_type_c AS hs_account_type
FROM enrollments e
LEFT JOIN gabby.alumni.enrollment_c ug
  ON e.recent_ugrad_enrollment_c = ug.id
LEFT JOIN gabby.alumni.enrollment_c ecc
  ON e.ecc_enrollment_c = ecc.id
LEFT JOIN gabby.alumni.account ecca
  ON ecc.school_c = ecca.id
LEFT JOIN gabby.alumni.enrollment_c hs
  ON e.hs_enrollment_c = hs.id