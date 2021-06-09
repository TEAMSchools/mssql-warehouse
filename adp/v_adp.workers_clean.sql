USE gabby
GO

CREATE OR ALTER VIEW adp.workers_clean AS

SELECT CONVERT(NVARCHAR(32), associate_oid) AS associate_oid
      ,CONVERT(NVARCHAR(32), worker_id) AS worker_id
      ,CONVERT(NVARCHAR(32), legal_name_formatted) AS legal_name_formatted
      ,CONVERT(NVARCHAR(8), legal_name_preferred_salutations) AS legal_name_preferred_salutations
      ,CONVERT(NVARCHAR(64), legal_name_given) AS legal_name_given
      ,CONVERT(NVARCHAR(64), legal_name_nick) AS legal_name_nick
      ,CONVERT(NVARCHAR(64), legal_name_middle) AS legal_name_middle
      ,CONVERT(NVARCHAR(64), legal_name_family) AS legal_name_family
      ,CONVERT(NVARCHAR(8), legal_name_generation_affix_code) AS legal_name_generation_affix_code
      ,CONVERT(NVARCHAR(8), legal_name_qualification_affix_code) AS legal_name_qualification_affix_code
      ,CONVERT(NVARCHAR(64), preferred_name_given) AS preferred_name_given
      ,CONVERT(NVARCHAR(64), preferred_name_middle) AS preferred_name_middle
      ,CONVERT(NVARCHAR(64), preferred_name_family) AS preferred_name_family
FROM
    (
     SELECT associate_oid
           ,JSON_VALUE(worker_id, '$.idValue') AS worker_id

           ,JSON_VALUE(person, '$.legalName.formattedName') AS legal_name_formatted
           ,JSON_VALUE(person, '$.legalName.preferredSalutations[0].salutationCode.codeValue') AS legal_name_preferred_salutations
           ,JSON_VALUE(person, '$.legalName.givenName') AS legal_name_given
           ,JSON_VALUE(person, '$.legalName.nickName') AS legal_name_nick
           ,JSON_VALUE(person, '$.legalName.middleName') AS legal_name_middle
           ,JSON_VALUE(person, '$.legalName.familyName1') AS legal_name_family
           ,JSON_VALUE(person, '$.legalName.generationAffixCode.codeValue') AS legal_name_generation_affix_code
           ,JSON_VALUE(person, '$.legalName.qualificationAffixCode.codeValue') AS legal_name_qualification_affix_code

           ,JSON_VALUE(person, '$.preferredName.givenName') AS preferred_name_given
           ,JSON_VALUE(person, '$.preferredName.middleName') AS preferred_name_middle
           ,JSON_VALUE(person, '$.preferredName.familyName1') AS preferred_name_family
     FROM gabby.adp.workers
    ) sub
