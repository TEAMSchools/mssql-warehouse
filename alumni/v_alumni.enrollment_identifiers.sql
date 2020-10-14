USE gabby
GO

CREATE OR ALTER VIEW alumni.enrollment_identifiers AS

WITH enrollments AS (
  SELECT sub.student_c
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'BA' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS ba_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'AA' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS aa_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Vocational' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS vocational_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Secondary' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS secondary_enrollment_id
        ,MAX(CASE WHEN sub.pursuing_degree_level = 'Graduate' AND sub.rn_degree_desc = 1 THEN sub.enrollment_id END) AS graduate_enrollment_id
        ,MAX(CASE WHEN sub.is_ecc_degree_type = 1 AND sub.is_ecc_dated = 1 AND sub.rn_ecc_asc = 1 THEN sub.enrollment_id END) AS ecc_enrollment_id
        ,MAX(CASE WHEN sub.rn_current = 1 THEN sub.enrollment_id END) AS curr_enrollment_id
  FROM
      (
       SELECT sub.student_c
             ,sub.enrollment_id
             ,sub.pursuing_degree_level
             ,sub.is_ecc_degree_type
             ,sub.is_ecc_dated
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c, sub.pursuing_degree_level
                  ORDER BY sub.start_date_c ASC, sub.actual_end_date_c ASC) AS rn_degree_asc
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c, sub.is_ecc_degree_type, sub.is_ecc_dated
                  ORDER BY sub.start_date_c ASC, sub.actual_end_date_c ASC) AS rn_ecc_asc
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c, sub.pursuing_degree_level
                  ORDER BY sub.is_graduated DESC, sub.start_date_c DESC, sub.actual_end_date_c DESC) AS rn_degree_desc
             ,ROW_NUMBER() OVER(
                PARTITION BY sub.student_c
                  ORDER BY sub.start_date_c DESC, sub.actual_end_date_c DESC) AS rn_current
       FROM
           (
            SELECT e.student_c
                  ,e.id AS enrollment_id
                  ,e.start_date_c
                  ,COALESCE(e.actual_end_date_c, DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 6, 30)) AS actual_end_date_c
                  ,CASE
                    WHEN e.pursuing_degree_type_c = 'Bachelor''s (4-year)' THEN 'BA'
                    WHEN e.pursuing_degree_type_c = 'Associate''s (2 year)' THEN 'AA'
                    WHEN e.pursuing_degree_type_c IN ('Master''s', 'MBA') THEN 'Graduate'
                    WHEN e.pursuing_degree_type_c IN ('High School Diploma', 'GED') THEN 'Secondary'
                    WHEN e.pursuing_degree_type_c = 'Elementary Certificate' THEN 'Primary'
                    WHEN e.pursuing_degree_type_c = 'Certificate'
                     AND e.account_type_c NOT IN ('Traditional Public School', 'Alternative High School', 'KIPP School')
                         THEN 'Vocational'
                   END AS pursuing_degree_level
                  ,CASE WHEN e.status_c = 'Graduated' THEN 1 ELSE 0 END AS is_graduated
                  ,CASE WHEN e.pursuing_degree_type_c IN ('Bachelor''s (4-year)', 'Associate''s (2 year)') THEN 1 END AS is_ecc_degree_type
                  ,CASE 
                    WHEN DATEFROMPARTS(DATEPART(YEAR, c.actual_hs_graduation_date_c), 10, 31) 
                           BETWEEN e.start_date_c AND COALESCE(e.actual_end_date_c, DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 6, 30)) THEN 1 
                    ELSE 0 
                   END AS is_ecc_dated
            FROM gabby.alumni.enrollment_c e
            JOIN gabby.alumni.contact c
              ON e.student_c = c.id
             AND c.is_deleted = 0
            WHERE e.is_deleted = 0
              AND e.status_c <> 'Did Not Enroll'
           ) sub
      ) sub
  GROUP BY sub.student_c
 )

SELECT sub.student_c
      ,sub.ba_enrollment_id
      ,sub.aa_enrollment_id
      ,sub.ecc_enrollment_id
      ,sub.hs_enrollment_id
      ,sub.cte_enrollment_id
      ,sub.graduate_enrollment_id
      ,sub.ugrad_enrollment_id
      ,sub.ba_school_name
      ,sub.ba_pursuing_degree_type
      ,sub.ba_status
      ,sub.ba_start_date
      ,sub.ba_actual_end_date
      ,sub.ba_anticipated_graduation
      ,sub.ba_account_type
      ,sub.ba_major
      ,sub.ba_major_area
      ,sub.ba_college_major_declared
      ,sub.ba_date_last_verified
      ,sub.ba_credits_required_for_graduation
      ,sub.ba_account_name
      ,sub.ba_billing_state
      ,sub.ba_ncesid
      ,sub.aa_school_name
      ,sub.aa_pursuing_degree_type
      ,sub.aa_status
      ,sub.aa_start_date
      ,sub.aa_actual_end_date
      ,sub.aa_anticipated_graduation
      ,sub.aa_account_type
      ,sub.aa_major
      ,sub.aa_major_area
      ,sub.aa_college_major_declared
      ,sub.aa_date_last_verified
      ,sub.aa_credits_required_for_graduation
      ,sub.aa_account_name
      ,sub.aa_billing_state
      ,sub.aa_ncesid
      ,sub.ecc_school_name
      ,sub.ecc_pursuing_degree_type
      ,sub.ecc_status
      ,sub.ecc_start_date
      ,sub.ecc_actual_end_date
      ,sub.ecc_anticipated_graduation
      ,sub.ecc_account_type
      ,sub.ecc_credits_required_for_graduation
      ,sub.ecc_account_name
      ,sub.ecc_adjusted_6_year_minority_graduation_rate
      ,sub.hs_school_name
      ,sub.hs_pursuing_degree_type
      ,sub.hs_status
      ,sub.hs_start_date
      ,sub.hs_actual_end_date
      ,sub.hs_anticipated_graduation
      ,sub.hs_account_type
      ,sub.hs_credits_required_for_graduation
      ,sub.hs_account_name
      ,sub.cte_pursuing_degree_type
      ,sub.cte_status
      ,sub.cte_start_date
      ,sub.cte_actual_end_date
      ,sub.cte_anticipated_graduation
      ,sub.cte_account_type
      ,sub.cte_credits_required_for_graduation
      ,sub.cte_school_name
      ,sub.cte_billing_state
      ,sub.cte_ncesid
      ,sub.cur_pursuing_degree_type
      ,sub.cur_status
      ,sub.cur_start_date
      ,sub.cur_actual_end_date
      ,sub.cur_anticipated_graduation
      ,sub.cur_account_type
      ,sub.cur_credits_required_for_graduation
      ,sub.cur_school_name
      ,sub.cur_billing_state
      ,sub.cur_ncesid
      ,sub.cur_adjusted_6_year_minority_graduation_rate

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
FROM
    (
     SELECT e.student_c
           ,e.ba_enrollment_id
           ,e.aa_enrollment_id
           ,e.ecc_enrollment_id
           ,e.secondary_enrollment_id AS hs_enrollment_id
           ,e.vocational_enrollment_id AS cte_enrollment_id
           ,e.graduate_enrollment_id
           ,CASE 
             WHEN ba.start_date_c > aa.start_date_c THEN e.ba_enrollment_id
             WHEN aa.start_date_c IS NULL THEN e.ba_enrollment_id
             ELSE e.aa_enrollment_id
            END AS ugrad_enrollment_id

           ,ba.[name] AS ba_school_name
           ,ba.pursuing_degree_type_c AS ba_pursuing_degree_type
           ,ba.status_c AS ba_status
           ,ba.start_date_c AS ba_start_date
           ,ba.actual_end_date_c AS ba_actual_end_date      
           ,ba.anticipated_graduation_c AS ba_anticipated_graduation
           ,ba.account_type_c AS ba_account_type
           ,ba.major_c AS ba_major
           ,ba.major_area_c AS ba_major_area
           ,ba.college_major_declared_c AS ba_college_major_declared
           ,ba.date_last_verified_c AS ba_date_last_verified
           ,ba.of_credits_required_for_graduation_c AS ba_credits_required_for_graduation
           ,baa.[name] AS ba_account_name
           ,baa.billing_state AS ba_billing_state
           ,baa.ncesid_c AS ba_ncesid

           ,aa.[name] AS aa_school_name
           ,aa.pursuing_degree_type_c AS aa_pursuing_degree_type
           ,aa.status_c AS aa_status
           ,aa.start_date_c AS aa_start_date
           ,aa.actual_end_date_c AS aa_actual_end_date      
           ,aa.anticipated_graduation_c AS aa_anticipated_graduation
           ,aa.account_type_c AS aa_account_type
           ,aa.major_c AS aa_major
           ,aa.major_area_c AS aa_major_area
           ,aa.college_major_declared_c AS aa_college_major_declared
           ,aa.date_last_verified_c AS aa_date_last_verified
           ,aa.of_credits_required_for_graduation_c AS aa_credits_required_for_graduation
           ,aaa.[name] AS aa_account_name
           ,aaa.billing_state AS aa_billing_state
           ,aaa.ncesid_c AS aa_ncesid

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
     LEFT JOIN gabby.alumni.enrollment_c ba
       ON e.ba_enrollment_id = ba.id
      AND ba.is_deleted = 0
     LEFT JOIN gabby.alumni.account baa
       ON ba.school_c = baa.id
      AND baa.is_deleted = 0
     LEFT JOIN gabby.alumni.enrollment_c aa
       ON e.aa_enrollment_id = aa.id
      AND aa.is_deleted = 0
     LEFT JOIN gabby.alumni.account aaa
       ON aa.school_c = aaa.id
      AND aaa.is_deleted = 0
     LEFT JOIN gabby.alumni.enrollment_c ecc
       ON e.ecc_enrollment_id = ecc.id
      AND ecc.is_deleted = 0
     LEFT JOIN gabby.alumni.account ecca
       ON ecc.school_c = ecca.id
      AND ecca.is_deleted = 0
     LEFT JOIN gabby.alumni.enrollment_c hs
       ON e.secondary_enrollment_id = hs.id
      AND hs.is_deleted = 0
     LEFT JOIN gabby.alumni.account hsa
       ON hs.school_c = hsa.id
      AND hsa.is_deleted = 0
     LEFT JOIN gabby.alumni.enrollment_c cte
       ON e.vocational_enrollment_id = cte.id
      AND cte.is_deleted = 0
     LEFT JOIN gabby.alumni.account ctea
       ON cte.school_c = ctea.id
      AND ctea.is_deleted = 0
     LEFT JOIN gabby.alumni.enrollment_c cur
       ON e.curr_enrollment_id = cur.id
      AND cur.is_deleted = 0
     LEFT JOIN gabby.alumni.account cura
       ON cur.school_c = cura.id
      AND cura.is_deleted = 0
    ) sub
LEFT JOIN gabby.alumni.enrollment_c ug
  ON sub.ugrad_enrollment_id = ug.id
 AND ug.is_deleted = 0
LEFT JOIN gabby.alumni.account uga
  ON ug.school_c = uga.id
 AND uga.is_deleted = 0
