CREATE OR ALTER VIEW
  powerschool.contact_address AS
SELECT
  paa.personid,
  paa.addresspriorityorder AS priority_order,
  CASE
    WHEN paa.addresspriorityorder = 1 THEN 1
    ELSE 0
  END AS is_primary,
  acs.code AS address_type,
  pa.street,
  pa.unit,
  pa.city,
  pa.postalcode,
  scs.code AS [state_code]
FROM
  powerschool.personaddressassoc paa
  INNER JOIN powerschool.codeset acs ON paa.addresstypecodesetid = acs.codesetid
  INNER JOIN powerschool.personaddress pa ON paa.personaddressid = pa.personaddressid
  INNER JOIN powerschool.codeset scs ON pa.statescodesetid = scs.codesetid
