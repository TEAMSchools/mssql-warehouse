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
  titan.mealapplication AS ma
  INNER JOIN titan.academicyear AS ay ON ma.academic_year_id = ay.academic_year_id
  LEFT JOIN titan.eligibilitystatusdata AS esd ON ma.eligibility_status_id = esd.eligibility_status_id
