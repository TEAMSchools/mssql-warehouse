CREATE OR ALTER VIEW
  adp.workers_custom_field_group_wide AS
WITH
  grouped_data AS (
    SELECT
      associate_oid,
      worker_id,
      name_code_value,
      dbo.GROUP_CONCAT (item_value) AS item_value
    FROM
      adp.workers_custom_field_group
    GROUP BY
      associate_oid,
      worker_id,
      name_code_value
  )
SELECT
  associate_oid,
  worker_id,
  [Attended Relay],
  [COVID 19 Vaccine Type],
  [Date of last vaccine],
  [Employee Number],
  [KIPP Alumni Status],
  [NJ Pension Number],
  [Preferred Gender],
  [WFMgr Accrual Profile],
  [WFMgr Badge Number],
  [WFMgr EE Type],
  [WFMgr Home Hyperfind],
  [WFMgr LOA Return Date],
  [WFMgr Pay Rule],
  [WFMgr Trigger],
  [Years Teaching - In NJ or FL],
  [Years of Professional Experience before joining],
  [Years Teaching - In any State],
  [Life Experience in Communities We Serve],
  [Preferred Race/Ethnicity],
  [Professional Experience in Communities We Serve],
  [Teacher Prep Program],
  [Miami - ACES Number],
  CASE
    WHEN [WFMgr LOA] = 'true' THEN 1
    WHEN [WFMgr LOA] = 'false' THEN 0
  END AS [WFMgr LOA]
FROM
  grouped_data PIVOT (
    MAX(item_value) FOR name_code_value IN (
      [Attended Relay],
      [COVID 19 Vaccine Type],
      [Date of last vaccine],
      [Employee Number],
      [KIPP Alumni Status],
      [NJ Pension Number],
      [Preferred Gender],
      [WFMgr Accrual Profile],
      [WFMgr Badge Number],
      [WFMgr EE Type],
      [WFMgr Home Hyperfind],
      [WFMgr LOA Return Date],
      [WFMgr LOA],
      [WFMgr Pay Rule],
      [WFMgr Trigger],
      [Years Teaching - In NJ or FL],
      [Years of Professional Experience before joining],
      [Years Teaching - In any State],
      [Life Experience in Communities We Serve],
      [Preferred Race/Ethnicity],
      [Professional Experience in Communities We Serve],
      [Teacher Prep Program],
      [Miami - ACES Number]
    )
  ) AS p
