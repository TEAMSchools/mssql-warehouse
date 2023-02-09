SELECT kr.sf_contact_id
      ,CONCAT(kr.first_name, ' ', kr.last_name) AS [Full Name]
      ,kr.currently_enrolled_school AS [Currently Enrolled School]
      ,ei.ugrad_date_last_verified AS [EV Status]
      ,NULL AS [Tier]
      ,kr.counselor_name AS [Contact Owner]
      ,kr.ktc_cohort AS [KIPP HS Class]
FROM gabby.alumni.ktc_roster AS kr
LEFT JOIN gabby.alumni.enrollment_identifiers AS ei
  ON kr.sf_contact_id = ei.student_c