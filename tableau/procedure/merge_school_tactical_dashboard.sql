CREATE
OR ALTER
PROCEDURE tableau.merge_school_tactical_dashboard AS
WITH
  MySource AS (
    SELECT
      academic_year,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      subject_area,
      term_name,
      DOMAIN,
      subdomain,
      field,
      [value],
      CASE
        WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR () THEN DATEFROMPARTS(academic_year, 6, 30)
        ELSE DATEADD(
          DAY,
          1 - (DATEPART(WEEKDAY, SYSDATETIME())),
          CAST(SYSDATETIME() AS DATE)
        )
      END AS week_of_date
    FROM
      gabby.tableau.school_tactical_dashboard
    WHERE
      academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  )
MERGE
  gabby.tableau.school_tactical_dashboard_archive AS MyTarget USING MySource ON MySource.academic_year = MyTarget.academic_year
  AND MySource.region = MyTarget.region
  AND MySource.school_level = MyTarget.school_level
  AND MySource.reporting_schoolid = MyTarget.reporting_schoolid
  AND MySource.grade_level = MyTarget.grade_level
  AND ISNULL(MySource.subject_area, '') = ISNULL(MyTarget.subject_area, '')
COLLATE Latin1_General_BIN
AND MySource.term_name = MyTarget.term_name
AND MySource.domain = MyTarget.domain
AND ISNULL(MySource.subdomain, '') = ISNULL(MyTarget.subdomain, '')
AND MySource.field = MyTarget.field
AND MySource.week_of_date = MyTarget.week_of_date
WHEN MATCHED THEN
UPDATE SET
  [value] = MySource.[value]
WHEN NOT MATCHED THEN
INSERT
  (
    academic_year,
    region,
    school_level,
    reporting_schoolid,
    grade_level,
    subject_area,
    term_name,
    DOMAIN,
    subdomain,
    field,
    [value],
    week_of_date
  )
VALUES
  (
    MySource.academic_year,
    MySource.region,
    MySource.school_level,
    MySource.reporting_schoolid,
    MySource.grade_level,
    MySource.subject_area,
    MySource.term_name,
    MySource.domain,
    MySource.subdomain,
    MySource.field,
    MySource.[value],
    MySource.week_of_date
  );
