CREATE OR ALTER VIEW
  powerschool.person_contacts AS
  /* address */
SELECT
  personid,
  priority_order,
  CASE
    WHEN priority_order = 1 THEN 1
    ELSE 0
  END AS is_primary,
  'Address' AS contact_category,
  address_type AS contact_type,
  CONCAT(
    street,
    CASE
      WHEN unit != '' THEN ' ' + unit
    END,
    ', ',
    city,
    ', ',
    state_code,
    ' ',
    postalcode
  ) AS contact
FROM
  powerschool.contact_address
UNION ALL
/* phone number */
SELECT
  ppna.personid,
  ppna.phonenumberpriorityorder AS priority_order,
  ppna.ispreferred AS is_primary,
  'Phone' AS contact_category,
  pncs.code AS contact_type,
  CONCAT(
    '(',
    LEFT(pn.phonenumber, 3),
    ') ',
    SUBSTRING(pn.phonenumber, 4, 3),
    '-',
    SUBSTRING(pn.phonenumber, 7, 4),
    CASE
      WHEN pn.phonenumberext != '' THEN ' x' + CAST(
        pn.phonenumberext AS NVARCHAR(16)
      )
    END
  ) AS contact
FROM
  powerschool.personphonenumberassoc AS ppna
  INNER JOIN powerschool.codeset AS pncs ON (
    ppna.phonetypecodesetid = pncs.codesetid
  )
  INNER JOIN powerschool.phonenumber AS pn ON (
    ppna.phonenumberid = pn.phonenumberid
  )
UNION ALL
/* email */
SELECT
  peaa.personid,
  peaa.emailaddresspriorityorder AS priority_order,
  peaa.isprimaryemailaddress AS is_primary,
  'Email' AS contact_category,
  CASE
    WHEN eacs.code = 'Not Set' THEN 'Current'
    ELSE eacs.code
  END AS contact_type,
  ea.emailaddress AS contact
FROM
  powerschool.personemailaddressassoc AS peaa
  INNER JOIN powerschool.codeset AS eacs ON (
    peaa.emailtypecodesetid = eacs.codesetid
  )
  INNER JOIN powerschool.emailaddress AS ea ON (
    peaa.emailaddressid = ea.emailaddressid
  )
