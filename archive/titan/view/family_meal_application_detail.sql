CREATE OR ALTER VIEW
  titan.family_meal_application_detail AS
SELECT
  fma.family_meal_application_id,
  fmas.[name] AS family_meal_application_status,
  COALESCE(ay.[name], ma.academic_year) AS academic_year,
  e.eligibility_benefit_type,
  e.eligibility_determination_reason,
  COALESCE(ma.covert_code, e.covert_code) AS covert_code,
  COALESCE(
    ma.pricing_level,
    e.pricing_level
  ) AS pricing_level,
  ma.application_source,
  ma.meal_application_identifier,
  ma.application_status AS meal_application_status
FROM
  titan.familymealapplication AS fma
  INNER JOIN titan.familymealapplicationstatus AS fmas ON fma.family_meal_application_status_id = fmas.family_meal_application_status_id
  INNER JOIN titan.academicyear AS ay ON fma.academic_year_id = ay.academic_year_id
  INNER JOIN titan.meal_application_detail AS ma ON fma.meal_application_id = ma.meal_application_id
  LEFT JOIN titan.eligibility_benefit_type_detail AS e ON fma.eligibility_benefit_type_id = e.eligibility_benefit_type_id
