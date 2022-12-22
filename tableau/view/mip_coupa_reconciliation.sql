CREATE OR ALTER VIEW
  tableau.mip_coupa_reconciliation AS
WITH
  mip AS (
    SELECT
      fund,
      program,
      [function],
      [object],
      school,
      deptgroup,
      [subject],
      [budget period],
      [revised budget],
      [available budget],
      [remaining budget],
      [acctcode from valid segments],
      [acctcode valid],
      'KCNA' AS entity
    FROM
      [FINANCE01].[KIPP Cooper Norcross Academy].[dbo].[KCNA_Revised_And_Available_Budget]
    UNION ALL
    SELECT
      fund,
      program,
      [function],
      [object],
      school,
      deptgroup,
      [subject],
      [budget period],
      [revised budget],
      [available budget],
      [remaining budget],
      [acctcode from valid segments],
      [acctcode valid],
      'MIA' AS entity
    FROM
      [FINANCE01].[KIPP Miami, Inc.].[dbo].[KIPPMiami_Revised_And_Available_Budget]
    UNION ALL
    SELECT
      fund,
      program,
      [function],
      [object],
      school,
      deptgroup,
      [subject],
      [budget period],
      [revised budget],
      [available budget],
      [remaining budget],
      [acctcode from valid segments],
      [acctcode valid],
      'KIPP NJ' AS entity
    FROM
      [FINANCE01].[KIPP NEW JERSEY].[dbo].[KIPPNJ_Revised_And_Available_Budget]
    UNION ALL
    SELECT
      fund,
      program,
      [function],
      [object],
      school,
      deptgroup,
      [subject],
      [budget period],
      [revised budget],
      [available budget],
      [remaining budget],
      [acctcode from valid segments],
      [acctcode valid],
      'TEAM' AS entity
    FROM
      [FINANCE01].[Team Academy Charter School].[dbo].[TEAM_Revised_And_Available_Budget]
  ),
  coupa AS (
    SELECT
      code,
      owner_name,
      CAST(
        REPLACE(amount, ',', '') AS FLOAT
      ) AS amount,
      CAST(
        REPLACE(remaining, ',', '') AS FLOAT
      ) AS remaining,
      LEFT(period_name, 4) AS budget_period
    FROM
      gabby.coupa.budget_line_clean
  )
SELECT
  mip.[Fund],
  mip.[Program],
  mip.[Function],
  mip.[Object],
  mip.[School],
  mip.[DeptGroup],
  mip.[Subject],
  mip.[Budget Period],
  mip.[Revised Budget] AS revised_budget_mip,
  mip.[Available Budget] AS available_budget_mip,
  mip.[Remaining Budget] AS remaining_budget_mip,
  mip.[AcctCode From Valid Segments],
  mip.[AcctCode Valid],
  mip.entity,
  c.owner_name AS budget_owner,
  c.amount AS revised_budget_coupa,
  c.remaining AS available_budget_coupa,
  c.amount - c.remaining AS remaining_budget_coupa
FROM
  mip
  LEFT JOIN coupa AS c ON (
    mip.[AcctCode From Valid Segments] = c.code
    AND mip.[Budget Period] = c.budget_period
  )
