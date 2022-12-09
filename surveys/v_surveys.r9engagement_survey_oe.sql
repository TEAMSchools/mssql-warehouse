USE gabby GO
CREATE OR ALTER VIEW
  surveys.r9engagement_survey_oe AS
WITH
  survey_unpivoted AS (
    SELECT
      academic_year,
      reporting_term,
      term_name,
      participant_id,
      associate_id,
      email,
      location,
      n,
      REPLACE(question_code, '_', '') AS question_code,
      response_value
    FROM
      (
        SELECT
          academic_year,
          reporting_term,
          term_name,
          participant_id,
          associate_id,
          email,
          location,
          NULL AS n,
          CAST(region_6 AS NVARCHAR(MAX)) AS region_6,
          CAST(region_7 AS NVARCHAR(MAX)) AS region_7
        FROM
          gabby.surveys.r9engagement_survey_final
      ) sub UNPIVOT (response_value FOR question_code IN (region_6, region_7)) u
  )
SELECT
  su.academic_year,
  su.reporting_term,
  su.term_name,
  su.participant_id,
  su.associate_id,
  su.email,
  su.location,
  su.n,
  su.question_code,
  su.response_value,
  CASE
    WHEN su.location = 'Rise' THEN 73252
    WHEN su.location = 'Rise Academy' THEN 73252
    WHEN su.location = 'KIPP Rise Academy' THEN 73252
    WHEN su.location = 'NCA' THEN 73253
    WHEN su.location = 'Newark Collegiate Academy' THEN 73253
    WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 73253
    WHEN su.location = 'SPARK' THEN 73254
    WHEN su.location = 'SPARK Academy' THEN 73254
    WHEN su.location = 'KIPP SPARK Academy' THEN 73254
    WHEN su.location = 'THRIVE' THEN 73255
    WHEN su.location = 'THRIVE Academy' THEN 73255
    WHEN su.location = 'KIPP THRIVE Academy' THEN 73255
    WHEN su.location = 'Seek' THEN 73256
    WHEN su.location = 'Seek Academy' THEN 73256
    WHEN su.location = 'KIPP Seek Academy' THEN 73256
    WHEN su.location = 'Life Upper' THEN 73257
    WHEN su.location = 'Life Lower' THEN 73257
    WHEN su.location = 'Life' THEN 73257
    WHEN su.location = 'Life Academy' THEN 73257
    WHEN su.location = 'KIPP Life Academy' THEN 73257
    WHEN su.location = 'Bold' THEN 73258
    WHEN su.location = 'Bold Academy' THEN 73258
    WHEN su.location = 'KIPP BOLD Academy' THEN 73258
    WHEN su.location = 'Revolution' THEN 179901
    WHEN su.location = 'LSP' THEN 179901
    WHEN su.location = 'Lanning Square Primary' THEN 179901
    WHEN su.location = 'KIPP Lanning Square Primary' THEN 179901
    WHEN su.location = 'Lanning Square MS' THEN 179902
    WHEN su.location = 'LSMS' THEN 179902
    WHEN su.location = 'KIPP Lanning Square Middle' THEN 179902
    WHEN su.location = 'Whittier Elementary' THEN 179903
    WHEN su.location = 'KIPP Whittier Elementary' THEN 179903
    WHEN su.location = 'Whittier Middle' THEN 179903
    WHEN su.location = 'Whitter MS' THEN 179903
    WHEN su.location = 'KIPP Whittier Middle' THEN 179903
    WHEN su.location = 'TEAM' THEN 133570965
    WHEN su.location = 'TEAM Academy' THEN 133570965
    WHEN su.location = 'KIPP TEAM Academy' THEN 133570965
    WHEN su.location = 'Pathways' THEN 732574573
    WHEN su.location = 'KIPP Pathways at Bragaw' THEN 732574573
    WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 732585074
    WHEN su.location = 'KIPP Sunrise Academy' THEN 30200801
    WHEN su.location = 'Whitter ES' THEN 1799015075
  END AS reporting_schoolid,
  CASE
    WHEN su.location = 'Revolution' THEN 'KCNA'
    WHEN su.location = 'LSP' THEN 'KCNA'
    WHEN su.location = 'Lanning Square Primary' THEN 'KCNA'
    WHEN su.location = 'Lanning Square MS' THEN 'KCNA'
    WHEN su.location = 'LSMS' THEN 'KCNA'
    WHEN su.location = 'Whittier Elementary' THEN 'KCNA'
    WHEN su.location = 'Whittier Middle' THEN 'KCNA'
    WHEN su.location = 'Whitter MS' THEN 'KCNA'
    WHEN su.location = 'Whitter ES' THEN 'KCNA'
    WHEN su.location = 'Lanning Square Campus' THEN 'KCNA'
    WHEN su.location = 'KCNA' THEN 'KCNA'
    WHEN su.location = 'KIPP NJ' THEN 'KNJ'
    WHEN su.location = 'SL''s' THEN 'KNJ'
    WHEN su.location = 'Room9' THEN 'KNJ'
    WHEN su.location = 'Overall' THEN 'KNJ'
    WHEN su.location = 'Room 9' THEN 'KNJ'
    WHEN su.location = 'Rise' THEN 'TEAM'
    WHEN su.location = 'Rise Academy' THEN 'TEAM'
    WHEN su.location = 'NCA' THEN 'TEAM'
    WHEN su.location = 'Newark Collegiate Academy' THEN 'TEAM'
    WHEN su.location = 'SPARK' THEN 'TEAM'
    WHEN su.location = 'SPARK Academy' THEN 'TEAM'
    WHEN su.location = 'THRIVE' THEN 'TEAM'
    WHEN su.location = 'THRIVE Academy' THEN 'TEAM'
    WHEN su.location = 'Seek' THEN 'TEAM'
    WHEN su.location = 'Seek Academy' THEN 'TEAM'
    WHEN su.location = 'Life Upper' THEN 'TEAM'
    WHEN su.location = 'Life Lower' THEN 'TEAM'
    WHEN su.location = 'Life' THEN 'TEAM'
    WHEN su.location = 'Life Academy' THEN 'TEAM'
    WHEN su.location = 'Bold' THEN 'TEAM'
    WHEN su.location = 'Bold Academy' THEN 'TEAM'
    WHEN su.location = 'TEAM' THEN 'TEAM'
    WHEN su.location = 'TEAM Academy' THEN 'TEAM'
    WHEN su.location = 'Pathways' THEN 'TEAM'
    WHEN su.location = 'TEAM Schools' THEN 'TEAM'
    WHEN su.location = '18th Avenue Campus' THEN 'TEAM'
    WHEN su.location = 'KIPP SPARK Academy' THEN 'TEAM'
    WHEN su.location = 'Room 10 - 740 Chestnut St' THEN 'KCNA'
    WHEN su.location = 'KIPP Whittier Middle' THEN 'KCNA'
    WHEN su.location = 'Room 11 - 6745 NW 23rd Ave' THEN 'KNJ'
    WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 'TEAM'
    WHEN su.location = 'KIPP BOLD Academy' THEN 'TEAM'
    WHEN su.location = 'KIPP Lanning Sq Campus' THEN 'KCNA'
    WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 'TEAM'
    WHEN su.location = 'KIPP Seek Academy' THEN 'TEAM'
    WHEN su.location = 'Room 9 - 60 Park Pl' THEN 'KNJ'
    WHEN su.location = 'KIPP TEAM Academy' THEN 'TEAM'
    WHEN su.location = '18th Ave Campus' THEN 'TEAM'
    WHEN su.location = 'KIPP Pathways at Bragaw' THEN 'TEAM'
    WHEN su.location = 'KIPP Life Academy' THEN 'TEAM'
    WHEN su.location = 'KIPP Lanning Square Middle' THEN 'KCNA'
    WHEN su.location = 'KIPP Lanning Square Primary' THEN 'KCNA'
    WHEN su.location = 'KIPP Sunrise Academy' THEN 'KMS'
    WHEN su.location = 'KIPP THRIVE Academy' THEN 'TEAM'
    WHEN su.location = 'KIPP Rise Academy' THEN 'TEAM'
    WHEN su.location = 'KIPP Whittier Elementary' THEN 'KCNA'
  END AS region,
  CASE
    WHEN su.location = 'Revolution' THEN 'ES'
    WHEN su.location = 'LSP' THEN 'ES'
    WHEN su.location = 'Lanning Square Primary' THEN 'ES'
    WHEN su.location = 'Whitter ES' THEN 'ES'
    WHEN su.location = 'SPARK' THEN 'ES'
    WHEN su.location = 'SPARK Academy' THEN 'ES'
    WHEN su.location = 'THRIVE' THEN 'ES'
    WHEN su.location = 'THRIVE Academy' THEN 'ES'
    WHEN su.location = 'Seek' THEN 'ES'
    WHEN su.location = 'Seek Academy' THEN 'ES'
    WHEN su.location = 'Life Upper' THEN 'ES'
    WHEN su.location = 'Life Lower' THEN 'ES'
    WHEN su.location = 'Life' THEN 'ES'
    WHEN su.location = 'Life Academy' THEN 'ES'
    WHEN su.location = 'Pathways' THEN 'ES'
    WHEN su.location = 'NCA' THEN 'HS'
    WHEN su.location = 'Newark Collegiate Academy' THEN 'HS'
    WHEN su.location = 'Lanning Square MS' THEN 'MS'
    WHEN su.location = 'LSMS' THEN 'MS'
    WHEN su.location = 'Whittier Elementary' THEN 'MS'
    WHEN su.location = 'Whittier Middle' THEN 'MS'
    WHEN su.location = 'Whitter MS' THEN 'MS'
    WHEN su.location = 'Rise' THEN 'MS'
    WHEN su.location = 'Rise Academy' THEN 'MS'
    WHEN su.location = 'Bold' THEN 'MS'
    WHEN su.location = 'Bold Academy' THEN 'MS'
    WHEN su.location = 'TEAM' THEN 'MS'
    WHEN su.location = 'TEAM Academy' THEN 'MS'
    WHEN su.location = 'KIPP SPARK Academy' THEN 'ES'
    WHEN su.location = 'KIPP Whittier Middle' THEN 'MS'
    WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 'HS'
    WHEN su.location = 'KIPP BOLD Academy' THEN 'HS'
    WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 'MS'
    WHEN su.location = 'KIPP Seek Academy' THEN 'ES'
    WHEN su.location = 'KIPP TEAM Academy' THEN 'MS'
    WHEN su.location = 'KIPP Pathways at Bragaw' THEN 'ES'
    WHEN su.location = 'KIPP Life Academy' THEN 'ES'
    WHEN su.location = 'KIPP Lanning Square Middle' THEN 'MS'
    WHEN su.location = 'KIPP Lanning Square Primary' THEN 'ES'
    WHEN su.location = 'KIPP Sunrise Academy' THEN 'ES'
    WHEN su.location = 'KIPP THRIVE Academy' THEN 'ES'
    WHEN su.location = 'KIPP Rise Academy' THEN 'MS'
    WHEN su.location = 'KIPP Whittier Elementary' THEN 'ES'
  END AS school_level,
  qk.survey_type,
  qk.competency,
  qk.question_text
FROM
  survey_unpivoted su
  LEFT JOIN gabby.surveys.question_key qk ON su.question_code = qk.question_code
  AND su.academic_year = qk.academic_year
  AND qk.survey_type = 'R9'
