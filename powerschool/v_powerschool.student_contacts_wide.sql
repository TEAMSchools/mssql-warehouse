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

  UNION ALL

  SELECT c.student_number
        ,c.personid
        ,'pickup' AS person_type
        ,c.relationship_type
        ,CONCAT(LTRIM(RTRIM(c.firstname)), ' ', LTRIM(RTRIM(c.lastname))) AS contact_name
        ,ROW_NUMBER() OVER(
           PARTITION BY c.student_number
             ORDER BY c.contactpriorityorder) AS contactpriorityorder
  FROM powerschool.contacts c
  WHERE c.person_type <> 'self'
    AND c.contactpriorityorder > 2
    AND c.schoolpickupflg = 1
    AND c.isemergency = 0
 )

,contacts AS (
  SELECT sub.student_number
        ,sub.person_type + '_' + sub.contact_category_type AS pivot_field
        ,CONVERT(VARCHAR(250), sub.contact) AS pivot_value
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
       JOIN powerschool.person_contacts pc
         ON c.personid = pc.personid

       UNION ALL

       SELECT c.student_number
             ,CONCAT(c.person_type, '_', c.contactpriorityorder) AS person_type

             ,'phone_primary' AS contact_category_type
             ,pc.contact
             ,ROW_NUMBER() OVER(
                PARTITION BY c.student_number, c.personid
                  ORDER BY pc.is_primary DESC, pc.priority_order ASC) AS contact_category_type_priority
       FROM people c
       JOIN powerschool.person_contacts pc
         ON c.personid = pc.personid
        AND pc.contact_category = 'Phone'

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
      ,contact_1_phone_primary
      ,contact_2_name
      ,contact_2_relationship
      ,contact_2_phone_home
      ,contact_2_phone_mobile
      ,contact_2_phone_daytime
      ,contact_2_phone_work
      ,contact_2_address_home
      ,contact_2_email_current
      ,contact_2_phone_primary
      ,emerg_1_name
      ,emerg_1_relationship
      ,emerg_1_phone_home
      ,emerg_1_phone_mobile
      ,emerg_1_phone_daytime
      ,emerg_1_phone_work
      ,emerg_1_address_home
      ,emerg_1_email_current
      ,emerg_1_phone_primary
      ,emerg_2_name
      ,emerg_2_relationship
      ,emerg_2_phone_home
      ,emerg_2_phone_mobile
      ,emerg_2_phone_daytime
      ,emerg_2_phone_work
      ,emerg_2_address_home
      ,emerg_2_email_current
      ,emerg_2_phone_primary
      ,emerg_3_name
      ,emerg_3_relationship
      ,emerg_3_phone_home
      ,emerg_3_phone_mobile
      ,emerg_3_phone_daytime
      ,emerg_3_phone_work
      ,emerg_3_address_home
      ,emerg_3_email_current
      ,emerg_3_phone_primary
      ,pickup_1_name
      ,pickup_1_relationship
      ,pickup_1_phone_home
      ,pickup_1_phone_mobile
      ,pickup_1_phone_daytime
      ,pickup_1_phone_work
      ,pickup_1_address_home
      ,pickup_1_email_current
      ,pickup_1_phone_primary
      ,pickup_2_name
      ,pickup_2_relationship
      ,pickup_2_phone_home
      ,pickup_2_phone_mobile
      ,pickup_2_phone_daytime
      ,pickup_2_phone_work
      ,pickup_2_address_home
      ,pickup_2_email_current
      ,pickup_2_phone_primary
      ,pickup_3_name
      ,pickup_3_relationship
      ,pickup_3_phone_home
      ,pickup_3_phone_mobile
      ,pickup_3_phone_daytime
      ,pickup_3_phone_work
      ,pickup_3_address_home
      ,pickup_3_email_current
      ,pickup_3_phone_primary
FROM contacts c WITH(FORCESEEK)
PIVOT(
  MAX(pivot_value)
  FOR pivot_field IN (contact_1_name,contact_1_relationship,contact_1_address_home,contact_1_email_current
                     ,contact_1_phone_primary,contact_1_phone_daytime,contact_1_phone_home,contact_1_phone_mobile,contact_1_phone_work
                     ,contact_2_name,contact_2_relationship,contact_2_address_home,contact_2_email_current
                     ,contact_2_phone_primary,contact_2_phone_daytime,contact_2_phone_home,contact_2_phone_mobile,contact_2_phone_work
                     ,emerg_1_name,emerg_1_relationship,emerg_1_address_home,emerg_1_email_current
                     ,emerg_1_phone_primary,emerg_1_phone_daytime,emerg_1_phone_home,emerg_1_phone_mobile,emerg_1_phone_work
                     ,emerg_2_name,emerg_2_relationship,emerg_2_address_home,emerg_2_email_current
                     ,emerg_2_phone_primary,emerg_2_phone_daytime,emerg_2_phone_home,emerg_2_phone_mobile,emerg_2_phone_work
                     ,emerg_3_name,emerg_3_relationship,emerg_3_address_home,emerg_3_email_current
                     ,emerg_3_phone_primary,emerg_3_phone_daytime,emerg_3_phone_home,emerg_3_phone_mobile,emerg_3_phone_work
                     ,pickup_1_name,pickup_1_relationship,pickup_1_address_home,pickup_1_email_current
                     ,pickup_1_phone_primary,pickup_1_phone_daytime,pickup_1_phone_home,pickup_1_phone_mobile,pickup_1_phone_work
                     ,pickup_2_name,pickup_2_relationship,pickup_2_address_home,pickup_2_email_current
                     ,pickup_2_phone_primary,pickup_2_phone_daytime,pickup_2_phone_home,pickup_2_phone_mobile,pickup_2_phone_work
                     ,pickup_3_name,pickup_3_relationship,pickup_3_address_home,pickup_3_email_current
                     ,pickup_3_phone_primary,pickup_3_phone_daytime,pickup_3_phone_home,pickup_3_phone_mobile,pickup_3_phone_work
                     ,pickup_4_name,pickup_4_relationship,pickup_4_address_home,pickup_4_email_current
                     ,pickup_4_phone_primary,pickup_4_phone_daytime,pickup_4_phone_home,pickup_4_phone_mobile,pickup_4_phone_work
                     ,pickup_5_name,pickup_5_relationship,pickup_5_address_home,pickup_5_email_current
                     ,pickup_5_phone_primary,pickup_5_phone_daytime,pickup_5_phone_home,pickup_5_phone_mobile,pickup_5_phone_work)
 ) p
