CREATE OR ALTER VIEW
  tableau.family_contact_dashboard AS
WITH
  contacts_repivot AS (
    SELECT
      student_number,
      family_ident,
      person_type AS person,
      person_name AS [name],
      person_relationship AS relation,
      NULL AS registeredtovote,
      [db_name],
      [mobile] AS cell,
      [home],
      daytime AS [day]
    FROM
      gabby.powerschool.student_contacts_static PIVOT (
        MAX(contact) FOR contact_type IN (
          [mobile],
          [home],
          [daytime]
        )
      ) AS p
  ),
  contacts_grouped AS (
    SELECT
      family_ident,
      person,
      [name],
      [db_name],
      gabby.dbo.GROUP_CONCAT_D (
        DISTINCT cell,
        CHAR(10)
      ) AS cell,
      gabby.dbo.GROUP_CONCAT_D (
        DISTINCT home,
        CHAR(10)
      ) AS home,
      gabby.dbo.GROUP_CONCAT_D (
        DISTINCT [day],
        CHAR(10)
      ) AS [day]
    FROM
      contacts_repivot
    WHERE
      family_ident IS NOT NULL
    GROUP BY
      family_ident,
      person,
      [name],
      [db_name]
  )
SELECT
  co.student_number,
  co.lastfirst AS student_name,
  co.reporting_schoolid AS schoolid,
  co.school_name,
  co.grade_level,
  co.team,
  co.enroll_status,
  co.[db_name],
  CONCAT(
    co.STREET,
    ' - ',
    co.city,
    ', ',
    co.state,
    ' ',
    co.zip
  ) AS street_address,
  s.family_ident,
  suf.infosnap_opt_in,
  c.person AS contact_type,
  c.[name] AS contact_name,
  c.registeredtovote AS contact_registered_to_vote,
  ISNULL(c.relation, c.person) AS contact_relation,
  cg.cell AS contact_cell_phone,
  cg.home AS contact_home_phone,
  cg.[day] AS contact_day_phone,
  co.guardianemail AS contact_email
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.students AS s ON co.student_number = s.student_number
  AND co.[db_name] = s.[db_name]
  LEFT JOIN gabby.powerschool.u_studentsuserfields AS suf ON s.dcid = suf.studentsdcid
  AND s.[db_name] = suf.[db_name]
  LEFT JOIN contacts_repivot AS c ON co.student_number = c.student_number
  AND co.[db_name] = c.[db_name]
  LEFT JOIN contacts_grouped AS cg ON s.family_ident = cg.family_ident
  AND s.[db_name] = cg.[db_name]
  AND c.person = cg.person
  AND c.[name] = cg.[name]
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
