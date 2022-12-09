SELECT
  s.student_number AS "Student Identifier",
  s.first_name AS "First Name",
  s.middle_name AS "Middle Name",
  s.last_name AS "Last Name",
  s.state_studentnumber AS "State Identifier",
  s.dob AS "Date of Birth",
  s.gender AS "Gender"
  --,rc.racecd_agg AS "Race"
,
  s.fedethnicity AS "Ethnicity",
  sch.name AS "School (Site)",
  s.grade_level AS "Grade",
  s.entrydate AS "Start Date",
  s.exitdate AS "Drop Date",
  s.team AS "Homeroom (Teacher Name)",
  s.family_ident AS "Household ID"
  --,s.street AS "Home Address (Street)"
,
  s.city AS "City",
  s.state AS "State",
  s.zip AS "Zip",
  hoh.contacts_firstname AS "Head of Household First Name",
  hoh.contacts_lastname AS "Head of Household Last name",
  hoh.mobile_phone AS "Head of Household Cell Phone",
  hoh.home_phone AS "Head of Household Home Phone",
  hoh.work_phone AS "Head of Household Work Phone",
  hoh.emails_emailaddress AS "Head of Household Email",
  c2.contacts_firstname AS "ContactTwo First Name",
  c2.contacts_lastname AS "ContactTwo Last name",
  c2.mobile_phone AS "ContactTwo Cell Phone",
  c2.home_phone AS "ContactTwo Home Phone",
  c2.work_phone AS "ContactTwo Work Phone",
  c2.emails_emailaddress AS "ContactTwo Email"
FROM
  students s
  JOIN schools sch ON s.schoolid = sch.school_number
  LEFT JOIN (
    SELECT
      studentid AS race_studentid,
      LISTAGG (racecd, ',') WITHIN GROUP (
        ORDER BY
          racecd
      ) AS racecd_agg
    FROM
      studentrace
    GROUP BY
      studentid
  ) rc ON s.id = rc.race_studentid
  LEFT JOIN (
    SELECT
      c.contacts_studentdcid,
      c.contacts_firstname,
      c.contacts_lastname,
      p1.p1_phonenumberasentered AS mobile_phone,
      p2.p2_phonenumberasentered AS home_phone,
      p3.p3_phonenumberasentered AS work_phone,
      em.emails_emailaddress
    FROM
      (
        SELECT
          sca.studentdcid AS contacts_studentdcid,
          sca.personid AS contacts_personid,
          p.firstname AS contacts_firstname,
          p.lastname AS contacts_lastname,
          ROW_NUMBER() OVER (
            PARTITION BY
              sca.studentdcid
            ORDER BY
              sca.contactpriorityorder
          ) AS contacts_rn
        FROM
          studentcontactassoc sca
          JOIN person p ON sca.personid = p.id
          AND p.isactive = 1
      ) c
      LEFT JOIN (
        SELECT
          ppna.personid AS p1_personid,
          ppna.phonenumberasentered AS p1_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p1_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Mobile'
      ) p1 ON c.contacts_personid = p1.p1_personid
      AND p1.p1_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          ppna.personid AS p2_personid,
          ppna.phonenumberasentered AS p2_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p2_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Home'
      ) p2 ON c.contacts_personid = p2.p2_personid
      AND p2.p2_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          ppna.personid AS p3_personid,
          ppna.phonenumberasentered AS p3_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p3_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Work'
      ) p3 ON c.contacts_personid = p3.p3_personid
      AND p3.p3_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          peaa.personid AS emails_personid,
          e.emailaddress AS emails_emailaddress,
          c.code AS emailtype,
          ROW_NUMBER() OVER (
            PARTITION BY
              peaa.personid,
              c.code
            ORDER BY
              peaa.emailaddresspriorityorder
          ) AS emails_filteredpriorityorder
        FROM
          personemailaddressassoc peaa
          JOIN emailaddress e ON peaa.emailaddressid = e.emailaddressid
          JOIN codeset c ON peaa.emailtypecodesetid = c.codesetid
      ) em ON c.contacts_personid = em.emails_personid
      AND em.emails_filteredpriorityorder = 1
      AND em.emailtype = 'Current'
    WHERE
      c.contacts_rn = 1
  ) hoh ON s.dcid = hoh.contacts_studentdcid
  LEFT JOIN (
    SELECT
      c.contacts_studentdcid,
      c.contacts_firstname,
      c.contacts_lastname,
      p1.p1_phonenumberasentered AS mobile_phone,
      p2.p2_phonenumberasentered AS home_phone,
      p3.p3_phonenumberasentered AS work_phone,
      em.emails_emailaddress
    FROM
      (
        SELECT
          sca.studentdcid AS contacts_studentdcid,
          sca.personid AS contacts_personid,
          p.firstname AS contacts_firstname,
          p.lastname AS contacts_lastname,
          ROW_NUMBER() OVER (
            PARTITION BY
              sca.studentdcid
            ORDER BY
              sca.contactpriorityorder
          ) AS contacts_rn
        FROM
          studentcontactassoc sca
          JOIN person p ON sca.personid = p.id
          AND p.isactive = 1
      ) c
      LEFT JOIN (
        SELECT
          ppna.personid AS p1_personid,
          ppna.phonenumberasentered AS p1_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p1_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Mobile'
      ) p1 ON c.contacts_personid = p1.p1_personid
      AND p1.p1_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          ppna.personid AS p2_personid,
          ppna.phonenumberasentered AS p2_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p2_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Home'
      ) p2 ON c.contacts_personid = p2.p2_personid
      AND p2.p2_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          ppna.personid AS p3_personid,
          ppna.phonenumberasentered AS p3_phonenumberasentered,
          ROW_NUMBER() OVER (
            PARTITION BY
              ppna.personid,
              c.code
            ORDER BY
              ppna.phonenumberpriorityorder
          ) AS p3_filteredpriorityorder
        FROM
          personphonenumberassoc ppna
          JOIN codeset c ON ppna.phonetypecodesetid = c.codesetid
          AND c.code = 'Work'
      ) p3 ON c.contacts_personid = p3.p3_personid
      AND p3.p3_filteredpriorityorder = 1
      LEFT JOIN (
        SELECT
          peaa.personid AS emails_personid,
          e.emailaddress AS emails_emailaddress,
          c.code AS emailtype,
          ROW_NUMBER() OVER (
            PARTITION BY
              peaa.personid,
              c.code
            ORDER BY
              peaa.emailaddresspriorityorder
          ) AS emails_filteredpriorityorder
        FROM
          personemailaddressassoc peaa
          JOIN emailaddress e ON peaa.emailaddressid = e.emailaddressid
          JOIN codeset c ON peaa.emailtypecodesetid = c.codesetid
      ) em ON c.contacts_personid = em.emails_personid
      AND em.emails_filteredpriorityorder = 1
      AND em.emailtype = 'Current'
    WHERE
      c.contacts_rn = 2
  ) c2 ON s.dcid = c2.contacts_studentdcid
WHERE
  s.enroll_status = 0
