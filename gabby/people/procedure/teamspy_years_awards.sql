SELECT r.employee_number,
       r.preferred_first_name,
       r.preferred_last_name,
       r.userprincipalname,
       r.position_status,
       r.business_unit,
       r.location,
       r.home_department,
       r.job_title,
       r.original_hire_date,
       r.rehire_date,
       y.years_at_kipp_total,
       y.years_active_at_kipp
FROM people.staff_roster AS r
LEFT JOIN people.years_experience AS y
  ON (r.employee_number = y.employee_number)
WHERE r.position_status != 'Terminated'