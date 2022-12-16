USE gabby GO
CREATE OR ALTER VIEW
  finance.financial_model_clean AS
WITH
  clean_data AS (
    SELECT
      sub.region,
      sub.metric,
      sub.snapshot_month,
      sub.snapshot_date,
      sub.fy_17,
      sub.fy_18,
      sub.fy_19,
      sub.fy_20,
      sub.fy_21,
      sub.fy_22,
      sub.fy_23,
      sub.fy_24,
      sub.fy_25,
      sub.fy_26,
      sub.fy_27,
      sub.fy_28,
      sub.fy_29,
      sub.fy_30,
      sub.fy_31,
      sub.fy_32,
      sub.fy_33,
      sub.fy_34,
      sub.fy_35
    FROM
      (
        SELECT
          region,
          metric,
          DATENAME(MONTH, snapshot_date) AS snapshot_month,
          snapshot_date,
          fy_17,
          fy_18,
          fy_19,
          fy_20,
          fy_21,
          fy_22,
          fy_23,
          fy_24,
          fy_25,
          fy_26,
          fy_27,
          fy_28,
          fy_29,
          fy_30,
          fy_31,
          fy_32,
          fy_33,
          fy_34,
          fy_35,
          ROW_NUMBER() OVER (
            PARTITION BY
              region,
              metric,
              DATENAME(MONTH, snapshot_date)
            ORDER BY
              snapshot_date DESC
          ) AS rn_month
        FROM
          gabby.finance.financial_model
        WHERE
          _fivetran_deleted = 0
      ) AS sub
    WHERE
      sub.rn_month = 1
  ),
  unpivoted AS (
    SELECT
      u.region,
      CAST('20' + RIGHT(u.field, 2) AS INT) AS fiscal_year,
      u.snapshot_month,
      u.snapshot_date,
      u.metric,
      u.value
    FROM
      clean_data UNPIVOT (
        VALUE FOR field IN (
          fy_17,
          fy_18,
          fy_19,
          fy_20,
          fy_21,
          fy_22,
          fy_23,
          fy_24,
          fy_25,
          fy_26,
          fy_27,
          fy_28,
          fy_29,
          fy_30,
          fy_31,
          fy_32,
          fy_33,
          fy_34,
          fy_35
        )
      ) u
  )
SELECT
  p.region,
  p.fiscal_year,
  p.snapshot_month,
  p.snapshot_date,
  p.[Unfinanced Capital Outlays Per Pupil],
  p.[Unfinanced Capital Outlays],
  p.[Total Revenue Per Pupil],
  p.[Total Revenue],
  p.[Total Expenses Per Pupil],
  p.[Total Expenses],
  p.[Student-Teacher+TiR Ratio],
  p.[Student-Teacher Ratio],
  p.[Student-Staff Ratio],
  p.[SPED Enrollment (Start Of Year)],
  p.[Schools],
  p.[School Expenses Per Pupil],
  p.[School Expense],
  p.[Rent Expense Per Pupil],
  p.[Rent Expense],
  p.[Regional Expenses Per Pupil],
  p.[Regional Expenses],
  p.[Private Grants/Contributions Per Pupil],
  p.[Private Grants/Contributions],
  p.[Principal Payments Per Pupil],
  p.[Principal Payments],
  p.[Other Revenue/Income Per Pupil],
  p.[Other Revenue/Income],
  p.[Other Occupancy Expense Per Pupil],
  p.[Other Occupancy Expense],
  p.[Other Expenses Per Pupil],
  p.[Other Expenses],
  p.[Other Cash Flow Adjustments Per Pupil],
  p.[Other Cash Flow Adjustments],
  p.[Operating Cash Flow Per Pupil],
  p.[Operating Cash Flow],
  p.[Number of Schools],
  p.[Net Income Per Pupil],
  p.[Net Income],
  p.[Management Fee Revenue - Total],
  p.[Management Fee Revenue - Newark],
  p.[Management Fee Revenue - Miami],
  p.[Management Fee Revenue - Camden],
  p.[Management Fee Per Pupil],
  p.[Management Fee % - Newark],
  p.[Management Fee % - Miami],
  p.[Management Fee % - Camden],
  p.[Management Fee],
  p.[Interest Expense Per Pupil],
  p.[Interest Expense],
  p.[FTEs - Total],
  p.[FTEs - TiR],
  p.[FTEs - Teachers],
  p.[FTEs - School],
  p.[FTEs - Region],
  p.[FTEs],
  p.[Enrollment (Year-End ADE)],
  p.[Enrollment (Start Of Year)],
  p.[Ending Cash Balance],
  p.[EBITDA Per Pupil],
  p.[EBITDA],
  p.[Depreciation Per Pupil],
  p.[Depreciation],
  p.[Debt Service],
  p.[Days Cash On Hand],
  p.[Daily Operating Expenses],
  p.[Core Public Revenue - State, Local, Federal Per Pupil],
  p.[Core Public Revenue - State, Local, Federal],
  p.[Core Public Revenue - State, Local Per Pupil],
  p.[Core Public Revenue - State, Local - Total],
  p.[Core Public Revenue - State, Local - Newark],
  p.[Core Public Revenue - State, Local - Miami],
  p.[Core Public Revenue - State, Local - Camden],
  p.[Core Public Revenue - State, Local],
  p.[Core Public Revenue - Federal Per Pupil],
  p.[Core Public Revenue - Federal],
  p.[CMO Surplus / (Deficit) Per Pupil],
  p.[CMO Surplus / (Deficit)],
  p.[CMO Expenses - Total Per Pupil],
  p.[CMO Expenses - Total],
  p.[CMO Expenses - Personnel Per Pupil],
  p.[CMO Expenses - Personnel],
  p.[CMO Expenses - Non-Personnel Per Pupil],
  p.[CMO Expenses - Non-Personnel],
  p.[CMO Expenses - Grant To Regions Per Pupil],
  p.[CMO Expenses - Grant To Regions],
  p.[Cash Flow Margin],
  p.[Avg. Personnel Cost]
FROM
  unpivoted PIVOT (
    MAX(VALUE) FOR metric IN (
      [Unfinanced Capital Outlays Per Pupil],
      [Unfinanced Capital Outlays],
      [Total Revenue Per Pupil],
      [Total Revenue],
      [Total Expenses Per Pupil],
      [Total Expenses],
      [Student-Teacher+TiR Ratio],
      [Student-Teacher Ratio],
      [Student-Staff Ratio],
      [SPED Enrollment (Start Of Year)],
      [Schools],
      [School Expenses Per Pupil],
      [School Expense],
      [Rent Expense Per Pupil],
      [Rent Expense],
      [Regional Expenses Per Pupil],
      [Regional Expenses],
      [Private Grants/Contributions Per Pupil],
      [Private Grants/Contributions],
      [Principal Payments Per Pupil],
      [Principal Payments],
      [Other Revenue/Income Per Pupil],
      [Other Revenue/Income],
      [Other Occupancy Expense Per Pupil],
      [Other Occupancy Expense],
      [Other Expenses Per Pupil],
      [Other Expenses],
      [Other Cash Flow Adjustments Per Pupil],
      [Other Cash Flow Adjustments],
      [Operating Cash Flow Per Pupil],
      [Operating Cash Flow],
      [Number of Schools],
      [Net Income Per Pupil],
      [Net Income],
      [Management Fee Revenue - Total],
      [Management Fee Revenue - Newark],
      [Management Fee Revenue - Miami],
      [Management Fee Revenue - Camden],
      [Management Fee Per Pupil],
      [Management Fee % - Newark],
      [Management Fee % - Miami],
      [Management Fee % - Camden],
      [Management Fee],
      [Interest Expense Per Pupil],
      [Interest Expense],
      [FTEs - Total],
      [FTEs - TiR],
      [FTEs - Teachers],
      [FTEs - School],
      [FTEs - Region],
      [FTEs],
      [Enrollment (Year-End ADE)],
      [Enrollment (Start Of Year)],
      [Ending Cash Balance],
      [EBITDA Per Pupil],
      [EBITDA],
      [Depreciation Per Pupil],
      [Depreciation],
      [Debt Service],
      [Days Cash On Hand],
      [Daily Operating Expenses],
      [Core Public Revenue - State, Local, Federal Per Pupil],
      [Core Public Revenue - State, Local, Federal],
      [Core Public Revenue - State, Local Per Pupil],
      [Core Public Revenue - State, Local - Total],
      [Core Public Revenue - State, Local - Newark],
      [Core Public Revenue - State, Local - Miami],
      [Core Public Revenue - State, Local - Camden],
      [Core Public Revenue - State, Local],
      [Core Public Revenue - Federal Per Pupil],
      [Core Public Revenue - Federal],
      [CMO Surplus / (Deficit) Per Pupil],
      [CMO Surplus / (Deficit)],
      [CMO Expenses - Total Per Pupil],
      [CMO Expenses - Total],
      [CMO Expenses - Personnel Per Pupil],
      [CMO Expenses - Personnel],
      [CMO Expenses - Non-Personnel Per Pupil],
      [CMO Expenses - Non-Personnel],
      [CMO Expenses - Grant To Regions Per Pupil],
      [CMO Expenses - Grant To Regions],
      [Cash Flow Margin],
      [Avg. Personnel Cost]
    )
  ) p
