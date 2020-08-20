USE gabby
GO

CREATE OR ALTER VIEW alumni.enrollment_identifiers AS

WITH enrollments AS (
  SELECT sub.student_c
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'College' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS college_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Vocational' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS vocational_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Secondary' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS secondary_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Graduate' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS graduate_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'College' AND sub.rn_degree_asc = 1 AND sub.is_ecc_dated = 1 THEN sub.enrollment_id END) AS ecc_enrollment_id
        ,MAX(CASE WHEN sub.rn_current = 1 THEN sub.enrollment_id END) AS curr_enrollment_id
  FROM
      (
       SELECT sub.student_c
             ,sub.enrollment_id
             ,sub.pursuing_degree_level
             ,CASE WHEN sub.ecc_date BETWEEN sub.start_date_c AND sub.actual_end_date_c THEN 1 ELSE 0 END AS is_ecc_dated
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c, sub.pursuing_degree_level
                  ORDER BY sub.start_date_c ASC, sub.actual_end_date_c ASC) AS rn_degree_asc
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c, sub.pursuing_degree_level
                  ORDER BY sub.start_date_c DESC, sub.actual_end_date_c DESC) AS rn_degree_desc
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c
                  ORDER BY sub.start_date_c DESC, sub.actual_end_date_c DESC) AS rn_current
       FROM
           (
            SELECT e.student_c
                  ,e.id AS enrollment_id
                  ,e.start_date_c
                  ,COALESCE(e.actual_end_date_c, CONVERT(DATE, GETDATE())) AS actual_end_date_c
                  ,CASE
                    WHEN e.pursuing_degree_type_c IN ('Bachelor''s (4-year)', 'Associate''s (2 year)') THEN 'College'
                    WHEN e.pursuing_degree_type_c IN ('Master''s', 'MBA') THEN 'Graduate'
                    WHEN e.pursuing_degree_type_c IN ('High School Diploma', 'GED') THEN 'Secondary'
                    WHEN e.pursuing_degree_type_c = 'Elementary Certificate' THEN 'Primary'
                    WHEN e.pursuing_degree_type_c = 'Certificate'
                     AND e.account_type_c NOT IN ('Traditional Public School', 'Alternative High School', 'KIPP School')
                         THEN 'Vocational'
                   END AS pursuing_degree_level
                  
                  ,DATEFROMPARTS(DATEPART(YEAR,c.actual_hs_graduation_date_c), 10, 31) AS ecc_date
            FROM gabby.alumni.enrollment_c e
            JOIN gabby.alumni.contact c
              ON e.student_c = c.id
             AND c.is_deleted = 0
            WHERE e.is_deleted = 0
              AND e.status_c != 'Did Not Enroll'
           ) sub
      ) sub
  GROUP BY sub.student_c
 )

SELECT e.student_c
      ,e.college_enrollment_id AS ugrad_enrollment_id
      ,e.ecc_enrollment_id
      ,e.secondary_enrollment_id AS hs_enrollment_id
      ,e.vocational_enrollment_id AS cte_enrollment_id
      ,e.graduate_enrollment_id

      ,ug.[name] AS ugrad_school_name
      ,ug.pursuing_degree_type_c AS ugrad_pursuing_degree_type
      ,ug.status_c AS ugrad_status
      ,ug.start_date_c AS ugrad_start_date
      ,ug.actual_end_date_c AS ugrad_actual_end_date      
      ,ug.anticipated_graduation_c AS ugrad_anticipated_graduation
      ,ug.account_type_c AS ugrad_account_type
      ,ug.major_c AS ugrad_major
      ,ug.major_area_c AS ugrad_major_area
      ,ug.college_major_declared_c AS ugrad_college_major_declared
      ,ug.date_last_verified_c AS ugrad_date_last_verified
      ,ug.of_credits_required_for_graduation_c AS ugrad_credits_required_for_graduation
      ,uga.[name] AS ugrad_account_name
      ,uga.billing_state AS ugrad_billing_state
      ,uga.ncesid_c AS ugrad_ncesid

      ,ecc.[name] AS ecc_school_name      
      ,ecc.pursuing_degree_type_c AS ecc_pursuing_degree_type
      ,ecc.status_c AS ecc_status
      ,ecc.start_date_c AS ecc_start_date
      ,ecc.actual_end_date_c AS ecc_actual_end_date      
      ,ecc.anticipated_graduation_c AS ecc_anticipated_graduation
      ,ecc.account_type_c AS ecc_account_type
      ,ecc.of_credits_required_for_graduation_c AS ecc_credits_required_for_graduation
      ,ecca.[name] AS ecc_account_name
      ,ecca.adjusted_6_year_minority_graduation_rate_c AS ecc_adjusted_6_year_minority_graduation_rate

      ,hs.name AS hs_school_name      
      ,hs.pursuing_degree_type_c AS hs_pursuing_degree_type
      ,hs.status_c AS hs_status
      ,hs.start_date_c AS hs_start_date
      ,hs.actual_end_date_c AS hs_actual_end_date
      ,hs.anticipated_graduation_c AS hs_anticipated_graduation
      ,hs.account_type_c AS hs_account_type
      ,hs.of_credits_required_for_graduation_c AS hs_credits_required_for_graduation
      ,hsa.[name] AS hs_account_name

      ,cte.pursuing_degree_type_c AS cte_pursuing_degree_type
      ,cte.status_c AS cte_status
      ,cte.start_date_c AS cte_start_date
      ,cte.actual_end_date_c AS cte_actual_end_date      
      ,cte.anticipated_graduation_c AS cte_anticipated_graduation
      ,cte.account_type_c AS cte_account_type
      ,cte.of_credits_required_for_graduation_c AS cte_credits_required_for_graduation
      ,ctea.[name] AS cte_school_name
      ,ctea.billing_state AS cte_billing_state
      ,ctea.ncesid_c AS cte_ncesid

      ,cur.pursuing_degree_type_c AS cur_pursuing_degree_type
      ,cur.status_c AS cur_status
      ,cur.start_date_c AS cur_start_date
      ,cur.actual_end_date_c AS cur_actual_end_date      
      ,cur.anticipated_graduation_c AS cur_anticipated_graduation
      ,cur.account_type_c AS cur_account_type
      ,cur.of_credits_required_for_graduation_c AS cur_credits_required_for_graduation
      ,cura.[name] AS cur_school_name
      ,cura.billing_state AS cur_billing_state
      ,cura.ncesid_c AS cur_ncesid
      ,cura.adjusted_6_year_minority_graduation_rate_c AS cur_adjusted_6_year_minority_graduation_rate
FROM enrollments e
LEFT JOIN gabby.alumni.enrollment_c ug
  ON e.college_enrollment_id = ug.id
LEFT JOIN gabby.alumni.account uga
  ON ug.school_c = uga.id
LEFT JOIN gabby.alumni.enrollment_c ecc
  ON e.ecc_enrollment_id = ecc.id
LEFT JOIN gabby.alumni.account ecca
  ON ecc.school_c = ecca.id
LEFT JOIN gabby.alumni.enrollment_c hs
  ON e.secondary_enrollment_id = hs.id
LEFT JOIN gabby.alumni.account hsa
  ON hs.school_c = hsa.id
LEFT JOIN gabby.alumni.enrollment_c cte
  ON e.vocational_enrollment_id = cte.id
LEFT JOIN gabby.alumni.account ctea
  ON cte.school_c = ctea.id
LEFT JOIN gabby.alumni.enrollment_c cur
  ON e.curr_enrollment_id = cur.id
LEFT JOIN gabby.alumni.account cura
  ON cur.school_c = cura.id
