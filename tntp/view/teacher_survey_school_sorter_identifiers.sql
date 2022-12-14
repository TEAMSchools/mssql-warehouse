USE gabby GO
CREATE OR ALTER VIEW
  tntp.teacher_survey_school_sorter_identifiers AS
SELECT
  school,
  academic_year,
  survey_round,
  field,
  VALUE,
  CASE
    WHEN school IN ('KIPP Rise Academy', 'Rise Academy') THEN 73252
    WHEN school IN (
      'KIPP Newark Collegiate Academy',
      'Newark Collegiate Academy'
    ) THEN 73253
    WHEN school IN ('KIPP SPARK Academy', 'SPARK Academy') THEN 73254
    WHEN school IN ('KIPP THRIVE Academy', 'THRIVE Academy') THEN 73255
    WHEN school IN ('KIPP Seek Academy', 'Seek Academy') THEN 73256
    WHEN school IN (
      'KIPP Life Academy',
      'Life Academy - Lower',
      'Life Academy - Upper',
      'Life Academy at Bragaw'
    ) THEN 73257
    WHEN school IN ('BOLD Academy', 'KIPP BOLD Academy') THEN 73258
    WHEN school IN (
      'KIPP Lanning Square Primary',
      'KIPP Lanning Square Primary School',
      'Revolution Primary'
    ) THEN 179901
    WHEN school IN ('KIPP TEAM Academy', 'TEAM Academy') THEN 133570965
    WHEN school = 'KIPP Lanning Square Middle School' THEN 179902
    WHEN school = 'KIPP Whittier Middle School' THEN 179903
    WHEN school = 'KIPP Whittier Elementary' THEN 1799015075
    WHEN school = 'KIPP Pathways' THEN 732574573
  END AS reporting_schoolid,
  CASE
    WHEN school IN (
      'KIPP SPARK Academy',
      'SPARK Academy',
      'KIPP THRIVE Academy',
      'THRIVE Academy',
      'KIPP Seek Academy',
      'Seek Academy',
      'KIPP Life Academy',
      'Life Academy - Lower',
      'Life Academy - Upper',
      'Life Academy at Bragaw',
      'KIPP Lanning Square Primary',
      'KIPP Lanning Square Primary School',
      'Revolution Primary',
      'KIPP Whittier Elementary',
      'KIPP Pathways'
    ) THEN 'ES'
    WHEN school IN (
      'KIPP Rise Academy',
      'Rise Academy',
      'BOLD Academy',
      'KIPP BOLD Academy',
      'KIPP TEAM Academy',
      'TEAM Academy',
      'KIPP Lanning Square Middle School',
      'KIPP Whittier Middle School'
    ) THEN 'MS'
    WHEN school IN (
      'KIPP Newark Collegiate Academy',
      'Newark Collegiate Academy'
    ) THEN 'HS'
  END AS school_level,
  CASE
    WHEN school IN (
      'KIPP Rise Academy',
      'Rise Academy',
      'KIPP Newark Collegiate Academy',
      'Newark Collegiate Academy',
      'KIPP SPARK Academy',
      'SPARK Academy',
      'KIPP THRIVE Academy',
      'THRIVE Academy',
      'KIPP Seek Academy',
      'Seek Academy',
      'KIPP Life Academy',
      'Life Academy - Lower',
      'Life Academy - Upper',
      'Life Academy at Bragaw',
      'BOLD Academy',
      'KIPP BOLD Academy',
      'KIPP Pathways',
      'KIPP TEAM Academy',
      'TEAM Academy'
    ) THEN 'TEAM'
    WHEN school IN (
      'KIPP Lanning Square Primary',
      'KIPP Lanning Square Primary School',
      'Revolution Primary',
      'KIPP Lanning Square Middle School',
      'KIPP Whittier Middle School',
      'KIPP Whittier Elementary'
    ) THEN 'KCNA'
  END AS region
FROM
  (
    SELECT
      school,
      academic_year,
      survey_round,
      field,
      VALUE
    FROM
      gabby.tntp.teacher_survey_school_sorter
    UNION ALL
    SELECT
      school,
      academic_year,
      survey_round,
      CONCAT(field, ': Top-Quartile') AS field,
      MAX(
        CASE
          WHEN school IN (
            'National Charter Top-Quartile Average',
            'National Charters Top Quartile Average',
            'KIPP Foundation Top Quartile',
            'KIPP Top Quartile Schools',
            'KIPP Network Top Quartile',
            'KIPP Top Quartile Average - Aggregated by School'
          ) THEN VALUE
        END
      ) OVER (
        PARTITION BY
          academic_year,
          survey_round,
          field
      ) AS VALUE
    FROM
      gabby.tntp.teacher_survey_school_sorter
  ) sub
