CREATE OR ALTER VIEW
  powerschool.student_contacts AS
SELECT
  c.student_number,
  c.family_ident,
  c.person_type,
  c.relationship_type AS person_relationship,
  CONCAT(c.firstname, ' ', c.lastname) AS person_name,
  c.isemergency,
  c.schoolpickupflg,
  pc.contact_category,
  CASE
    WHEN pc.contact_category IN ('Email', 'Address') THEN LOWER(pc.contact_category)
    ELSE LOWER(pc.contact_type)
  END AS contact_type,
  pc.contact,
  pc.priority_order AS contact_priority_order
FROM
  powerschool.contacts AS c
  INNER JOIN powerschool.person_contacts AS pc ON c.personid = pc.personid
  AND pc.contact_type IN (
    'Current',
    'Daytime',
    'Home',
    'Mobile',
    'Not Set',
    'Work'
  )
  AND (
    (
      pc.contact_category IN ('Address', 'Email')
      AND pc.priority_order = 1
    )
    OR (pc.contact_category = 'Phone')
  )
