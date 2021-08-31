CREATE OR ALTER VIEW titan.eligibility_benefit_type_detail AS

SELECT ebt.eligibility_benefit_type_id
      ,ebt.[name] AS eligibility_benefit_type

      ,esd.covert_code
      ,esd.pricing_level

      ,edr.[name] AS eligibility_determination_reason
FROM titan.eligibilitybenefittype ebt
JOIN titan.eligibilitystatusdata esd
  ON ebt.eligibility_status_id = esd.eligibility_status_id
JOIN titan.eligibilitydeterminationreason edr
  ON ebt.eligibility_determination_reason_id = edr.eligibility_determination_reason_id
