USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_outcomes_dashboard AS

SELECT c.id AS contact_id
      ,c.name
      ,c.kipp_hs_class_c
      ,c.kipp_ms_graduate_c
      ,c.kipp_hs_graduate_c
      ,c.expected_hs_graduation_c
      ,c.actual_hs_graduation_date_c
      ,c.expected_college_graduation_c
      ,c.actual_college_graduation_date_c
      ,c.current_kipp_student_c
      ,c.highest_act_score_c

      ,rt.name AS record_type_name

      ,u.name AS user_name

      ,ei.ugrad_school_name
      ,ei.ugrad_pursuing_degree_type
      ,ei.ugrad_status
      ,ei.ugrad_start_date
      ,ei.ugrad_actual_end_date
      ,ei.ugrad_anticipated_graduation
      ,ei.ecc_school_name
      ,ei.ecc_pursuing_degree_type
      ,ei.ecc_status
      ,ei.ecc_start_date
      ,ei.ecc_actual_end_date
      ,ei.ecc_anticipated_graduation
      ,ei.ecc_adjusted_6_year_minority_graduation_rate
      ,ei.hs_school_name
      ,ei.hs_pursuing_degree_type
      ,ei.hs_status
      ,ei.hs_start_date
      ,ei.hs_actual_end_date
      ,ei.hs_anticipated_graduation
FROM gabby.alumni.contact c
JOIN gabby.alumni.record_type rt
  ON c.record_type_id = rt.id
JOIN gabby.alumni.[user] u
  ON c.owner_id = u.id
LEFT JOIN gabby.alumni.enrollment_identifiers ei
  ON c.id = ei.student_c
WHERE c.is_deleted = 0