CREATE OR ALTER VIEW
  titan.meal_application_detail AS
SELECT
  ma.meal_application_id,
  ma.application_source,
  ma.identifier AS meal_application_identifier,
  ma.application_type,
  ma.application_status,
  ay.[name] AS academic_year,
  esd.covert_code,
  esd.pricing_level
FROM
  titan.mealapplication ma
  JOIN titan.academicyear ay ON ma.academic_year_id = ay.academic_year_id
  LEFT JOIN titan.eligibilitystatusdata esd ON ma.eligibility_status_id = esd.eligibility_status_id
