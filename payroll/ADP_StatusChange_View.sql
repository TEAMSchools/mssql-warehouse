SELECT *
FROM adp.export_people_details d
JOIN payroll.status_change s
ON d.associate_id = s.employee_associate_id