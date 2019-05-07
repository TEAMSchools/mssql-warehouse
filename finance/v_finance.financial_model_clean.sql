USE gabby
GO

CREATE OR ALTER VIEW finance.financial_model_clean AS

SELECT p.region
      ,p.fiscal_year
      ,p.snapshot_month
      ,p.snapshot_date

      ,p.[Unfinanced Capital Outlays per pupil]
      ,p.[Unfinanced Capital Outlays]
      ,p.[Total Revenue per pupil]
      ,p.[Total Revenue]
      ,p.[Total Expenses per pupil]
      ,p.[Total Expenses]
      ,p.[Student-Teacher+TiR ratio]
      ,p.[Student-Teacher ratio]
      ,p.[Student-Staff ratio]
      ,p.[SPED Enrollment (start of year)]
      ,p.Schools
      ,p.[School Expenses per pupil]
      ,p.[School Expense]
      ,p.[Rent Expense per pupil]
      ,p.[Rent Expense]
      ,p.[Regional Expenses per pupil]
      ,p.[Regional Expenses]
      ,p.[Private Grants/Contributions per pupil]
      ,p.[Private Grants/Contributions]
      ,p.[Principal Payments per pupil]
      ,p.[Principal Payments]
      ,p.[Other Revenue/Income per pupil]
      ,p.[Other Revenue/Income]
      ,p.[Other Occupancy Expense per pupil]
      ,p.[Other Occupancy Expense]
      ,p.[Other Expenses per pupil]
      ,p.[Other Expenses]
      ,p.[Other Cash Flow Adjustments per pupil]
      ,p.[Other Cash Flow Adjustments]
      ,p.[Operating Cash Flow per pupil]
      ,p.[Operating Cash Flow]
      ,p.[Number of Schools]
      ,p.[Net Income per pupil]
      ,p.[Net Income]
      ,p.[Management Fee Revenue - Total]
      ,p.[Management Fee Revenue - Newark]
      ,p.[Management Fee Revenue - Miami]
      ,p.[Management Fee Revenue - Camden]
      ,p.[Management Fee per pupil]
      ,p.[Management Fee % - Newark]
      ,p.[Management Fee % - Miami]
      ,p.[Management Fee % - Camden]
      ,p.[Management Fee]
      ,p.[Interest Expense per pupil]
      ,p.[Interest Expense]
      ,p.[FTEs - Total]
      ,p.[FTEs - TiR]
      ,p.[FTEs - Teachers]
      ,p.[FTEs - School]
      ,p.[FTEs - Region]
      ,p.FTEs
      ,p.[Enrollment (Year-End ADE)]
      ,p.[Enrollment (start of year)]
      ,p.[Ending Cash Balance]
      ,p.[EBITDA per pupil]
      ,p.EBITDA
      ,p.[Depreciation per pupil]
      ,p.Depreciation
      ,p.[Debt Service]
      ,p.[Days Cash on Hand]
      ,p.[Daily Operating Expenses]
      ,p.[Core Public Revenue - State, Local, Federal per pupil]
      ,p.[Core Public Revenue - State, Local, Federal]
      ,p.[Core Public Revenue - State, Local per pupil]
      ,p.[Core Public Revenue - State, Local - Total]
      ,p.[Core Public Revenue - State, Local - Newark]
      ,p.[Core Public Revenue - State, Local - Miami]
      ,p.[Core Public Revenue - State, Local - Camden]
      ,p.[Core Public Revenue - State, Local]
      ,p.[Core Public Revenue - Federal per pupil]
      ,p.[Core Public Revenue - Federal]
      ,p.[CMO Surplus / (Deficit) per pupil]
      ,p.[CMO Surplus / (Deficit)]
      ,p.[CMO Expenses - Total per pupil]
      ,p.[CMO Expenses - Total]
      ,p.[CMO Expenses - Personnel per pupil]
      ,p.[CMO Expenses - Personnel]
      ,p.[CMO Expenses - Non-Personnel per pupil]
      ,p.[CMO Expenses - Non-Personnel]
      ,p.[CMO Expenses - Grant to Regions per pupil]
      ,p.[CMO Expenses - Grant to Regions]
      ,p.[Cash Flow Margin]
      ,p.[Avg. Personnel Cost]
FROM
    (
     SELECT u.region
           ,CONVERT(INT,'20' + RIGHT(u.field, 2)) AS fiscal_year
           ,u.snapshot_month
           ,u.snapshot_date

           ,u.metric
           ,u.value
     FROM
         (
          SELECT sub.region
                ,sub.metric
                ,sub.snapshot_month
                ,sub.snapshot_date
                ,sub.fy_17
                ,sub.fy_18
                ,sub.fy_19
                ,sub.fy_20
                ,sub.fy_21
                ,sub.fy_22
                ,sub.fy_23
                ,sub.fy_24
                ,sub.fy_25
                ,sub.fy_26
                ,sub.fy_27
                ,sub.fy_28
                ,sub.fy_29
                ,sub.fy_30
                ,sub.fy_31
                ,sub.fy_32
                ,sub.fy_33
                ,sub.fy_34
                ,sub.fy_35
          FROM
              (
               SELECT region
                     ,metric
                     ,DATENAME(MONTH, snapshot_date) AS snapshot_month
                     ,snapshot_date
                     ,fy_17
                     ,fy_18
                     ,fy_19
                     ,fy_20
                     ,fy_21
                     ,fy_22
                     ,fy_23
                     ,fy_24
                     ,fy_25
                     ,fy_26
                     ,fy_27
                     ,fy_28
                     ,fy_29
                     ,fy_30
                     ,fy_31
                     ,fy_32
                     ,fy_33
                     ,fy_34
                     ,fy_35
                     ,ROW_NUMBER() OVER(
                        PARTITION BY region, metric, DATENAME(MONTH, snapshot_date)
                          ORDER BY snapshot_date DESC) AS rn_month
               FROM gabby.finance.financial_model
               WHERE _fivetran_deleted = 0
              ) sub
          WHERE sub.rn_month = 1
         ) sub
     UNPIVOT(
       value
       FOR field IN (fy_17
                    ,fy_18
                    ,fy_19
                    ,fy_20
                    ,fy_21
                    ,fy_22
                    ,fy_23
                    ,fy_24
                    ,fy_25
                    ,fy_26
                    ,fy_27
                    ,fy_28
                    ,fy_29
                    ,fy_30
                    ,fy_31
                    ,fy_32
                    ,fy_33
                    ,fy_34
                    ,fy_35)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR metric IN ([Avg. Personnel Cost]
                ,[Cash Flow Margin]
                ,[CMO Expenses - Grant to Regions]
                ,[CMO Expenses - Grant to Regions per pupil]
                ,[CMO Expenses - Non-Personnel]
                ,[CMO Expenses - Non-Personnel per pupil]
                ,[CMO Expenses - Personnel]
                ,[CMO Expenses - Personnel per pupil]
                ,[CMO Expenses - Total]
                ,[CMO Expenses - Total per pupil]
                ,[CMO Surplus / (Deficit)]
                ,[CMO Surplus / (Deficit) per pupil]
                ,[Core Public Revenue - Federal]
                ,[Core Public Revenue - Federal per pupil]
                ,[Core Public Revenue - State, Local]
                ,[Core Public Revenue - State, Local - Camden]
                ,[Core Public Revenue - State, Local - Miami]
                ,[Core Public Revenue - State, Local - Newark]
                ,[Core Public Revenue - State, Local - Total]
                ,[Core Public Revenue - State, Local per pupil]
                ,[Core Public Revenue - State, Local, Federal]
                ,[Core Public Revenue - State, Local, Federal per pupil]
                ,[Daily Operating Expenses]
                ,[Days Cash on Hand]
                ,[Debt Service]
                ,[Depreciation]
                ,[Depreciation per pupil]
                ,[EBITDA]
                ,[EBITDA per pupil]
                ,[Ending Cash Balance]
                ,[Enrollment (start of year)]
                ,[Enrollment (Year-End ADE)]
                ,[FTEs]
                ,[FTEs - Region]
                ,[FTEs - School]
                ,[FTEs - Teachers]
                ,[FTEs - TiR]
                ,[FTEs - Total]
                ,[Interest Expense]
                ,[Interest Expense per pupil]
                ,[Management Fee]
                ,[Management Fee % - Camden]
                ,[Management Fee % - Miami]
                ,[Management Fee % - Newark]
                ,[Management Fee per pupil]
                ,[Management Fee Revenue - Camden]
                ,[Management Fee Revenue - Miami]
                ,[Management Fee Revenue - Newark]
                ,[Management Fee Revenue - Total]
                ,[Net Income]
                ,[Net Income per pupil]
                ,[Number of Schools]
                ,[Operating Cash Flow]
                ,[Operating Cash Flow per pupil]
                ,[Other Cash Flow Adjustments]
                ,[Other Cash Flow Adjustments per pupil]
                ,[Other Expenses]
                ,[Other Expenses per pupil]
                ,[Other Occupancy Expense]
                ,[Other Occupancy Expense per pupil]
                ,[Other Revenue/Income]
                ,[Other Revenue/Income per pupil]
                ,[Principal Payments]
                ,[Principal Payments per pupil]
                ,[Private Grants/Contributions]
                ,[Private Grants/Contributions per pupil]
                ,[Regional Expenses]
                ,[Regional Expenses per pupil]
                ,[Rent Expense]
                ,[Rent Expense per pupil]
                ,[School Expense]
                ,[School Expenses per pupil]
                ,[Schools]
                ,[SPED Enrollment (start of year)]
                ,[Student-Staff ratio]
                ,[Student-Teacher ratio]
                ,[Student-Teacher+TiR ratio]
                ,[Total Expenses]
                ,[Total Expenses per pupil]
                ,[Total Revenue]
                ,[Total Revenue per pupil]
                ,[Unfinanced Capital Outlays]
                ,[Unfinanced Capital Outlays per pupil])
 ) p