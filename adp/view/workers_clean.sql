CREATE OR ALTER VIEW
  adp.workers_clean AS
SELECT
  CAST(associate_oid AS NVARCHAR(32)) AS associate_oid,
  CAST(worker_id AS NVARCHAR(32)) AS worker_id,
  CAST(
    legal_name_formatted AS NVARCHAR(32)
  ) AS legal_name_formatted,
  CAST(
    legal_name_preferred_salutations AS NVARCHAR(8)
  ) AS legal_name_preferred_salutations,
  CAST(legal_name_given AS NVARCHAR(64)) AS legal_name_given,
  CAST(legal_name_nick AS NVARCHAR(64)) AS legal_name_nick,
  CAST(
    legal_name_middle AS NVARCHAR(64)
  ) AS legal_name_middle,
  CAST(
    legal_name_family AS NVARCHAR(64)
  ) AS legal_name_family,
  CAST(
    legal_name_generation_affix_code AS NVARCHAR(8)
  ) AS legal_name_generation_affix_code,
  CAST(
    legal_name_qualification_affix_code AS NVARCHAR(8)
  ) AS legal_name_qualification_affix_code,
  CAST(
    preferred_name_given AS NVARCHAR(64)
  ) AS preferred_name_given,
  CAST(
    preferred_name_middle AS NVARCHAR(64)
  ) AS preferred_name_middle,
  CAST(
    preferred_name_family AS NVARCHAR(64)
  ) AS preferred_name_family,
  CAST(original_hire_date AS DATE) AS original_hire_date,
  CAST(termination_date AS DATE) AS termination_date,
  CAST(rehire_date AS DATE) AS rehire_date
FROM
  (
    SELECT
      associate_oid,
      JSON_VALUE(worker_id, '$.idValue') AS worker_id,
      JSON_VALUE(
        person,
        '$.legalName.formattedName'
      ) AS legal_name_formatted,
      JSON_VALUE(
        person,
        '$.legalName.preferredSalutations[0].salutationCode.codeValue'
      ) AS legal_name_preferred_salutations,
      JSON_VALUE(person, '$.legalName.givenName') AS legal_name_given,
      JSON_VALUE(person, '$.legalName.nickName') AS legal_name_nick,
      JSON_VALUE(person, '$.legalName.middleName') AS legal_name_middle,
      JSON_VALUE(
        person,
        '$.legalName.familyName1'
      ) AS legal_name_family,
      JSON_VALUE(
        person,
        '$.legalName.generationAffixCode.codeValue'
      ) AS legal_name_generation_affix_code,
      JSON_VALUE(
        person,
        '$.legalName.qualificationAffixCode.codeValue'
      ) AS legal_name_qualification_affix_code,
      JSON_VALUE(
        person,
        '$.preferredName.givenName'
      ) AS preferred_name_given,
      JSON_VALUE(
        person,
        '$.preferredName.middleName'
      ) AS preferred_name_middle,
      JSON_VALUE(
        person,
        '$.preferredName.familyName1'
      ) AS preferred_name_family,
      JSON_VALUE(
        worker_dates,
        '$.originalHireDate'
      ) AS original_hire_date,
      JSON_VALUE(
        worker_dates,
        '$.terminationDate'
      ) AS termination_date,
      JSON_VALUE(worker_dates, '$.rehireDate') AS rehire_date
    FROM
      gabby.adp.workers
  ) AS sub
