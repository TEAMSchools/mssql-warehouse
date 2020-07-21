CREATE OR ALTER VIEW powerschool.student_contacts_wide AS

WITH people AS (
  SELECT c.student_number
        ,c.personid
        ,'contact' AS person_type
        ,c.relationship_type
        ,CONCAT(LTRIM(RTRIM(c.firstname)), ' ', LTRIM(RTRIM(c.lastname))) AS contact_name
        ,c.contactpriorityorder
  FROM powerschool.contacts c
  WHERE c.person_type <> 'self'
    AND c.contactpriorityorder <= 2

  UNION ALL

  SELECT c.student_number
        ,c.personid
        ,'emerg' AS person_type
        ,c.relationship_type
        ,CONCAT(LTRIM(RTRIM(c.firstname)), ' ', LTRIM(RTRIM(c.lastname))) AS contact_name
        ,ROW_NUMBER() OVER(
           PARTITION BY c.student_number
             ORDER BY c.contactpriorityorder) AS contactpriorityorder
  FROM powerschool.contacts c
  WHERE c.person_type <> 'self'
    AND c.contactpriorityorder > 2
    AND c.isemergency = 1
 )

,contacts AS (
  SELECT sub.student_number
        ,sub.person_type + '_' + sub.contact_category_type AS pivot_field
        ,sub.contact AS pivot_value
  FROM
      (
       SELECT c.student_number
             ,CONCAT(c.person_type, '_', c.contactpriorityorder) AS person_type

             ,LOWER(pc.contact_category) + '_' + LOWER(pc.contact_type) AS contact_category_type
             ,pc.contact
             ,ROW_NUMBER() OVER(
                PARTITION BY c.student_number, c.personid, pc.contact_category, pc.contact_type
                  ORDER BY pc.priority_order) AS contact_category_type_priority
       FROM people c
       LEFT JOIN powerschool.person_contacts pc
         ON c.personid = pc.personid

       UNION ALL

       SELECT c.student_number
             ,CONCAT(c.person_type, '_', c.contactpriorityorder) AS person_type
             ,'name' AS contact_category_type
             ,LTRIM(RTRIM(c.contact_name)) AS contact
             ,1 AS contact_category_type_priority
       FROM people c

       UNION ALL

       SELECT c.student_number
             ,CONCAT(c.person_type, '_', c.contactpriorityorder) AS person_type
             ,'relationship' AS contact_category_type
             ,c.relationship_type AS contact
             ,1 AS contact_category_type_priority
       FROM people c
      ) sub
  WHERE sub.contact_category_type_priority = 1
 )

SELECT student_number
      ,contact_1_name
      ,contact_1_relationship
      ,contact_1_phone_home
      ,contact_1_phone_mobile
      ,contact_1_phone_daytime
      ,contact_1_phone_work
      ,contact_1_address_home
      ,contact_1_email_current
      ,contact_2_name
      ,contact_2_relationship
      ,contact_2_phone_home
      ,contact_2_phone_mobile
      ,contact_2_phone_daytime
      ,contact_2_phone_work
      ,contact_2_address_home
      ,contact_2_email_current
      ,emerg_1_name
      ,emerg_1_relationship
      ,emerg_1_phone_home
      ,emerg_1_phone_mobile
      ,emerg_1_phone_daytime
      ,emerg_1_phone_work
      ,emerg_1_address_home
      ,emerg_1_email_current
      ,emerg_2_name
      ,emerg_2_relationship
      ,emerg_2_phone_home
      ,emerg_2_phone_mobile
      ,emerg_2_phone_daytime
      ,emerg_2_phone_work
      ,emerg_2_address_home
      ,emerg_2_email_current
      ,emerg_3_name
      ,emerg_3_relationship
      ,emerg_3_phone_home
      ,emerg_3_phone_mobile
      ,emerg_3_phone_daytime
      ,emerg_3_phone_work
      ,emerg_3_address_home
      ,emerg_3_email_current
FROM contacts c
PIVOT(
  MAX(pivot_value)
  FOR pivot_field IN (contact_1_address_home,contact_1_email_current,contact_1_name,contact_1_phone_daytime
                     ,contact_1_phone_home,contact_1_phone_mobile,contact_1_phone_work,contact_1_relationship
                     ,contact_2_address_home,contact_2_email_current,contact_2_name,contact_2_phone_daytime
                     ,contact_2_phone_home,contact_2_phone_mobile,contact_2_phone_work,contact_2_relationship
                     ,emerg_1_address_home,emerg_1_email_current,emerg_1_name,emerg_1_phone_daytime
                     ,emerg_1_phone_home,emerg_1_phone_mobile,emerg_1_phone_work,emerg_1_relationship
                     ,emerg_2_address_home,emerg_2_email_current,emerg_2_name,emerg_2_phone_daytime
                     ,emerg_2_phone_home,emerg_2_phone_mobile,emerg_2_phone_work,emerg_2_relationship
                     ,emerg_3_address_home,emerg_3_email_current,emerg_3_name,emerg_3_phone_daytime
                     ,emerg_3_phone_home,emerg_3_phone_mobile,emerg_3_phone_work,emerg_3_relationship)
 ) p
