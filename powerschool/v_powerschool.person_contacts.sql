CREATE OR ALTER VIEW powerschool.person_contacts AS

/* address */
SELECT paa.personid
      ,paa.addresspriorityorder AS priority_order
      ,'Address' AS contact_category
      ,acs.code AS contact_type
      ,pa.street
        + CASE WHEN pa.unit <> '' THEN ' ' + pa.unit ELSE '' END + ', ' 
        + pa.city + ', ' 
        + scs.code + ' ' 
        + pa.postalcode AS contact
FROM powerschool.personaddressassoc paa
LEFT JOIN powerschool.codeset acs
  ON paa.addresstypecodesetid = acs.codesetid
LEFT JOIN powerschool.personaddress pa
  ON paa.personaddressid = pa.personaddressid
LEFT JOIN powerschool.codeset scs
  ON pa.statescodesetid = scs.codesetid

UNION ALL

/* phone number */
SELECT ppna.personid
      ,ppna.phonenumberpriorityorder AS priority_order
      ,'Phone' AS contact_category
      ,pncs.code AS contact_type
      ,'(' + LEFT(pn.phonenumber, 3) + ') '
        + SUBSTRING(pn.phonenumber, 4, 3) + '-'
        + SUBSTRING(pn.phonenumber, 7, 4)
        + CASE WHEN pn.phonenumberext <> '' THEN ' x' + CONVERT(VARCHAR(5), pn.phonenumberext) ELSE '' END AS contact
FROM powerschool.personphonenumberassoc ppna
LEFT JOIN powerschool.codeset pncs
  ON ppna.phonetypecodesetid = pncs.codesetid
LEFT JOIN powerschool.phonenumber pn
  ON ppna.phonenumberid = pn.phonenumberid

UNION ALL

/* email */
SELECT peaa.personid
      ,peaa.emailaddresspriorityorder AS priority_order
      ,'Email' AS contact_category
      ,eacs.code AS contact_type
      ,ea.emailaddress AS contact
FROM powerschool.personemailaddressassoc peaa
LEFT JOIN powerschool.codeset eacs
  ON peaa.emailtypecodesetid = eacs.codesetid
LEFT JOIN powerschool.emailaddress ea
  ON peaa.emailaddressid = ea.emailaddressid
