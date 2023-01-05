CREATE OR ALTER VIEW
  coupa.budget_line_clean AS
SELECT
  b.amount,
  b.remaining,
  p.[name] AS period_name,
  u.fullname AS owner_name,
  CONCAT(
    b.segment_1,
    '-' + b.segment_2,
    '-' + b.segment_3,
    '-' + b.segment_4,
    '-' + b.segment_5,
    '-' + b.segment_6,
    '-' + b.segment_7,
    '-' + b.segment_8,
    '-' + b.segment_9,
    '-' + b.segment_10,
    '-' + b.segment_11,
    '-' + b.segment_12,
    '-' + b.segment_13,
    '-' + b.segment_14,
    '-' + b.segment_15,
    '-' + b.segment_16,
    '-' + b.segment_17,
    '-' + b.segment_18,
    '-' + b.segment_19,
    '-' + b.segment_20
  ) AS code
FROM
  coupa.budget_line AS b
  INNER JOIN coupa.[period] AS p ON (b.period_id = p.id)
  LEFT JOIN coupa.[user] AS u ON (b.owner_id = u.id)
