CREATE OR ALTER VIEW
  extracts.clever_sections AS
WITH
  dsos AS (
    SELECT
      (
        df.ps_teachernumber
        COLLATE LATIN1_GENERAL_BIN
      ) AS [Teacher_id],
      COALESCE(
        ccw.ps_school_id,
        df.primary_site_schoolid
      ) AS [School_id]
    FROM
      gabby.people.staff_crosswalk_static AS df
      LEFT JOIN gabby.people.campus_crosswalk AS ccw ON (
        df.primary_site = ccw.campus_name
        AND ccw._fivetran_deleted = 0
        AND ccw.is_pathways = 0
      )
    WHERE
      df.[status] != 'TERMINATED'
      AND df.primary_job IN (
        'Director of Campus Operations',
        'Director Campus Operations',
        'Director School Operations',
        'School Leader'
      )
  ),
  teachers_long AS (
    SELECT
      sec.schoolid AS [School_id],
      sec.section_number AS [Section_number],
      sec.course_number AS [Course_number],
      sec.section_number AS [Period],
      r.sortorder,
      t.teachernumber AS [Teacher_id],
      c.course_name AS [Course_name],
      terms.abbreviation AS [Term_name],
      NULL AS [Name],
      NULL AS [Grade],
      NULL AS [Course_description],
      CONVERT(VARCHAR, terms.firstday, 101) AS [Term_start],
      CONVERT(VARCHAR, terms.lastday, 101) AS [Term_end],
      CONCAT(
        CASE
          WHEN sec.[db_name] = 'kippnewark' THEN 'NWK'
          WHEN sec.[db_name] = 'kippcamden' THEN 'CMD'
          WHEN sec.[db_name] = 'kippmiami' THEN 'MIA'
        END,
        sec.id
      ) AS [Section_id],
      CASE
        WHEN c.credittype = 'ART' THEN 'Arts and music'
        WHEN c.credittype = 'CAREER' THEN 'other'
        WHEN c.credittype = 'COCUR' THEN 'other'
        WHEN c.credittype = 'ELEC' THEN 'other'
        WHEN c.credittype = 'ENG' THEN 'English/language arts'
        WHEN c.credittype = 'LOG' THEN 'other'
        WHEN c.credittype = 'MATH' THEN 'Math'
        WHEN c.credittype = 'NULL' THEN 'Homeroom/advisory'
        WHEN c.credittype = 'PHYSED' THEN 'PE and health'
        WHEN c.credittype = 'RHET' THEN 'English/language arts'
        WHEN c.credittype = 'SCI' THEN 'Science'
        WHEN c.credittype = 'SOC' THEN 'Social studies'
        WHEN c.credittype = 'STUDY' THEN 'other'
        WHEN c.credittype = 'WLANG' THEN 'Language'
      END AS [Subject]
    FROM
      gabby.powerschool.sections AS sec
      INNER JOIN gabby.powerschool.sectionteacher AS st ON (
        sec.id = st.sectionid
        AND sec.[db_name] = st.[db_name]
      )
      INNER JOIN gabby.powerschool.roledef AS r ON (
        st.roleid = r.id
        AND st.[db_name] = r.[db_name]
      )
      INNER JOIN gabby.powerschool.teachers_static AS t ON (
        st.teacherid = t.id
        AND sec.schoolid = t.schoolid
        AND sec.[db_name] = t.[db_name]
      )
      INNER JOIN gabby.powerschool.courses AS c ON (
        sec.course_number = c.course_number
        AND sec.[db_name] = c.[db_name]
      )
      INNER JOIN gabby.powerschool.terms ON (
        sec.termid = terms.id
        AND sec.schoolid = terms.schoolid
        AND sec.[db_name] = terms.[db_name]
        AND (
          CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN terms.firstday AND terms.lastday
        )
      )
    WHERE
      sec.no_of_students > 0
    UNION ALL
    SELECT
      dsos.[School_id],
      CONCAT(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        s.abbreviation,
        r.n
      ) AS [Section_number],
      'ENR' AS [Course_number],
      CONCAT(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        s.abbreviation,
        r.n
      ) AS [Period],
      CONCAT(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990,
        dsos.[School_id],
        RIGHT(CONCAT(0, r.n), 2)
      ) AS [Section_id],
      1 AS sortorder,
      dsos.[Teacher_id],
      'Enroll' AS [Course_name],
      'Homeroom/advisory' AS [Subject],
      CONCAT(
        RIGHT(
          gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
          2
        ),
        '-',
        RIGHT(
          gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1,
          2
        )
      ) AS [Term_name],
      CONVERT(
        VARCHAR,
        DATEFROMPARTS(
          gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
          7,
          1
        ),
        101
      ) AS [Term_start],
      CONVERT(
        VARCHAR,
        DATEFROMPARTS(
          gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1,
          6,
          30
        ),
        101
      ) AS [Term_end],
      NULL AS [Name],
      CASE
        WHEN r.n = 0 THEN 'Kindergarten'
        ELSE CAST(r.n AS VARCHAR(5))
      END AS [Grade],
      NULL AS [Course_description]
    FROM
      dsos
      INNER JOIN gabby.powerschool.schools AS s ON (
        dsos.[School_id] = s.school_number
      )
      INNER JOIN gabby.utilities.row_generator_smallint AS r ON (
        r.n BETWEEN s.low_grade AND s.high_grade
      )
  ),
  pre_pivot AS (
    SELECT
      [School_id],
      [Section_id],
      [Name],
      [Section_number],
      [Grade],
      [Course_name],
      [Course_number],
      [Course_description],
      [Period],
      [Subject],
      [Term_name],
      [Term_start],
      [Term_end],
      [Teacher_id],
      CONCAT(
        'Teacher_',
        ROW_NUMBER() OVER (
          PARTITION BY
            [Section_id]
          ORDER BY
            sortorder ASC
        ),
        '_id'
      ) AS pivot_field
    FROM
      teachers_long
  )
SELECT
  [School_id],
  [Section_id],
  [Teacher_1_id] AS [Teacher_id],
  [Teacher_2_id],
  [Teacher_3_id],
  [Teacher_4_id],
  [Teacher_5_id],
  [Teacher_6_id],
  [Teacher_7_id],
  [Teacher_8_id],
  [Teacher_9_id],
  [Teacher_10_id],
  [Name],
  [Section_number],
  [Grade],
  [Course_name],
  [Course_number],
  [Course_description],
  [Period],
  [Subject],
  [Term_name],
  [Term_start],
  [Term_end]
FROM
  pre_pivot PIVOT (
    MAX([Teacher_id]) FOR pivot_field IN (
      [Teacher_1_id],
      [Teacher_2_id],
      [Teacher_3_id],
      [Teacher_4_id],
      [Teacher_5_id],
      [Teacher_6_id],
      [Teacher_7_id],
      [Teacher_8_id],
      [Teacher_9_id],
      [Teacher_10_id]
    )
  ) AS p
