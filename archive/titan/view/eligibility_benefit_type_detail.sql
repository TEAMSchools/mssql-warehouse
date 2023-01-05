CREATE OR ALTER VIEW
  titan.eligibility_benefit_type_detail AS
SELECT
  ebt.eligibility_benefit_type_id,
  ebt.[name] AS eligibility_benefit_type,
  esd.covert_code,
  esd.pricing_level,
  edr.[name] AS eligibility_determination_reason
FROM
  titan.eligibilitybenefittype AS ebt
  INNER JOIN titan.eligibilitystatusdata AS esd ON ebt.eligibility_status_id = esd.eligibility_status_id
  INNER JOIN titan.eligibilitydeterminationreason AS edr ON ebt.eligibility_determination_reason_id = edr.eligibility_determination_reason_id
