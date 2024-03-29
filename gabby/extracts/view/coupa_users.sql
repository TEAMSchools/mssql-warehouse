CREATE OR ALTER VIEW
  extracts.coupa_users AS
WITH
  roles AS (
    SELECT
      [user_id],
      dbo.GROUP_CONCAT (role_name) AS roles
    FROM
      (
        SELECT
          urm.[user_id],
          r.[name] AS role_name
        FROM
          coupa.user_role_mapping AS urm
          INNER JOIN coupa.[role] AS r ON (urm.role_id = r.id)
        UNION
        SELECT
          u.id AS [user_id],
          'Expense User' AS role_name
        FROM
          coupa.[user] AS u
      ) AS sub
    GROUP BY
      [user_id]
  ),
  business_groups AS (
    SELECT
      ubgm.[user_id],
      dbo.GROUP_CONCAT_D (bg.[name], ', ') AS business_group_names
    FROM
      coupa.user_business_group_mapping AS ubgm
      INNER JOIN coupa.business_group AS bg ON (ubgm.business_group_id = bg.id)
    GROUP BY
      ubgm.[user_id]
  ),
  all_users AS (
    /* existing users */
    SELECT
      sr.employee_number,
      sr.first_name,
      sr.last_name,
      sr.position_status,
      sr.business_unit_code,
      sr.home_department,
      sr.job_title,
      sr.[location],
      sr.worker_category,
      sr.wfmgr_pay_rule,
      cu.active,
      CASE
        WHEN cu.purchasing_user = 1 THEN 'Yes'
        WHEN cu.purchasing_user = 0 THEN 'No'
      END AS purchasing_user,
      r.roles,
      bg.business_group_names AS content_groups
    FROM
      people.staff_roster AS sr
      INNER JOIN coupa.[user] AS cu ON (
        sr.employee_number = cu.employee_number
      )
      INNER JOIN roles AS r ON (cu.id = r.[user_id])
      LEFT JOIN business_groups AS bg ON (cu.id = bg.[user_id])
    WHERE
      sr.position_status != 'Prestart'
      AND COALESCE(
        sr.termination_date,
        CAST(CURRENT_TIMESTAMP AS DATE)
      ) >= DATEFROMPARTS(
        utilities.GLOBAL_ACADEMIC_YEAR () - 1,
        7,
        1
      )
      AND ISNULL(sr.worker_category, '') NOT IN ('Intern', 'Part Time')
      AND ISNULL(sr.wfmgr_pay_rule, '') != 'PT Hourly'
    UNION ALL
    /* new users */
    SELECT
      sr.employee_number,
      sr.first_name,
      sr.last_name,
      sr.position_status,
      sr.business_unit_code,
      sr.home_department,
      sr.job_title,
      sr.[location],
      sr.worker_category,
      sr.wfmgr_pay_rule,
      1 AS active,
      'No' AS purchasing_user,
      'Expense User' AS roles,
      NULL AS content_groups
    FROM
      people.staff_roster AS sr
      LEFT JOIN coupa.[user] AS cu ON (
        sr.employee_number = cu.employee_number
      )
    WHERE
      sr.position_status NOT IN ('Prestart', 'Terminated')
      AND ISNULL(sr.worker_category, '') NOT IN ('Intern', 'Part Time')
      AND ISNULL(sr.wfmgr_pay_rule, '') != 'PT Hourly'
      AND cu.employee_number IS NULL
  )
SELECT
  sub.samaccountname AS [Login],
  sub.userprincipalname AS [Sso Identifier],
  sub.mail AS [Email],
  sub.first_name AS [First Name],
  sub.last_name AS [Last Name],
  sub.employee_number AS [Employee Number],
  sub.roles AS [User Role Names],
  sub.location_code AS [Default Address Location Code],
  sub.street_1 AS [Default Address Street 1],
  sub.street_2 AS [Default Address Street 2],
  sub.city AS [Default Address City],
  sub.[state] AS [Default Address State],
  sub.postal_code AS [Default Address Postal Code],
  'US' AS [Default Address Country Code],
  sub.attention AS [Default Address Attention],
  sub.address_name AS [Default Address Name],
  sub.coupa_status AS [Status],
  'SAML' AS [Authentication Method],
  'No' AS [Generate Password And Notify User],
  CASE
    WHEN sub.worker_category IN ('Part Time', 'Intern') THEN 'No'
    WHEN sub.wfmgr_pay_rule = 'PT Hourly' THEN 'No'
    WHEN sub.coupa_status = 'inactive' THEN 'No'
    ELSE 'Yes'
  END AS [Expense User],
  /* preserve Coupa, otherwise No */
  COALESCE(
    CASE
      WHEN sub.coupa_status = 'inactive' THEN 'No'
    END,
    sub.purchasing_user,
    'No'
  ) AS [Purchasing User],
  /* preserve Coupa, otherwise use HRIS */
  COALESCE(
    sub.content_groups,
    CASE
      WHEN sub.business_unit_code = 'KIPP_TAF' THEN 'KIPP NJ'
      WHEN sub.business_unit_code = 'KIPP_MIAMI' THEN 'MIA'
      ELSE sub.business_unit_code
    END
  ) AS [Content Groups],
  CONCAT(
    CASE
      WHEN sub.position_status = 'Terminated' THEN 'X'
    END,
    utilities.STRIP_CHARACTERS (
      CONCAT(sub.first_name, sub.last_name),
      '^A-Z'
    ),
    CASE
      WHEN ISNUMERIC(RIGHT(sub.samaccountname, 1)) = 1 THEN RIGHT(sub.samaccountname, 1)
    END
  ) AS [Mention Name],
  CASE
    WHEN sna.coupa_school_name = '<BLANK>' THEN NULL
    ELSE COALESCE(
      sna.coupa_school_name,
      sub.[coupa_school_name]
    )
  END AS [School Name]
FROM
  (
    SELECT
      au.employee_number,
      au.first_name,
      au.last_name,
      au.roles,
      au.position_status,
      au.active,
      au.purchasing_user,
      au.content_groups,
      au.business_unit_code,
      au.worker_category,
      au.wfmgr_pay_rule,
      a.location_code,
      a.street_1,
      a.city,
      a.[state],
      a.postal_code,
      a.[name] AS address_name,
      CASE
      /* no interns */
        WHEN au.worker_category = 'Intern' THEN 'inactive'
        /* keep Approvers active while on leave */
        WHEN (
          au.position_status = 'Leave'
          AND (
            au.roles LIKE '%Edit Expense Report AS Approver%'
            OR au.roles LIKE '%Edit Requisition AS Approver%'
          )
        ) THEN 'active'
        /* deactivate all others on leave */
        WHEN au.position_status = 'Leave' THEN 'inactive'
        WHEN ad.is_active = 1 THEN 'active'
        ELSE 'inactive'
      END AS coupa_status,
      LOWER(ad.samaccountname) AS samaccountname,
      LOWER(ad.userprincipalname) AS userprincipalname,
      LOWER(ad.mail) AS mail,
      CASE
        WHEN a.street_2 != '' THEN a.street_2
      END AS street_2,
      CASE
        WHEN a.attention != '' THEN a.attention
      END AS attention,
      /*
      override
      > lookup table (content group/department/job)
      > lookup table (content group/department)
      */
      COALESCE(
        x.coupa_school_name,
        CASE
          WHEN (
            sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>'
          ) THEN ad.physicaldeliveryofficename
          ELSE sn.coupa_school_name
        END,
        CASE
          WHEN (
            sn2.coupa_school_name = '<Use PhysicalDeliveryOfficeName>'
          ) THEN ad.physicaldeliveryofficename
          ELSE sn2.coupa_school_name
        END
      ) AS coupa_school_name
    FROM
      all_users AS au
      INNER JOIN adsi.user_attributes_static AS ad ON (
        au.employee_number = ad.employeenumber
        AND ISNUMERIC(ad.employeenumber) = 1
      )
      LEFT JOIN coupa.school_name_lookup AS sn ON (
        au.business_unit_code = sn.business_unit_code
        AND au.home_department = sn.home_department
        AND au.job_title = sn.job_title
      )
      LEFT JOIN coupa.school_name_lookup AS sn2 ON (
        au.business_unit_code = sn2.business_unit_code
        AND au.home_department = sn2.home_department
        AND sn2.job_title = 'Default'
      )
      LEFT JOIN coupa.user_exceptions AS x ON (
        au.employee_number = x.employee_number
      )
      LEFT JOIN coupa.address_name_crosswalk AS anc ON au.[location] = anc.adp_location
      LEFT JOIN coupa.[address] AS a ON (
        anc.coupa_address_name = a.[name]
        AND a.active = 1
      )
  ) AS sub
  LEFT JOIN coupa.school_name_aliases AS sna ON (
    sub.coupa_school_name = sna.physical_delivery_office_name
  )
