USE [gabby] GO
SET
ANSI_NULLS ON GO
SET
QUOTED_IDENTIFIER ON GO CREATE
OR ALTER
TRIGGER coupa.TR_budget_line_list_AI ON coupa.budget_line_list AFTER
INSERT
  AS BEGIN
SET
NOCOUNT ON;

IF (
  EXISTS (
    SELECT
      1
    FROM
      INSERTED
  )
) BEGIN
DELETE FROM coupa.budget_line_list
WHERE
  CONCAT(
    budget_line_list.period,
    '_',
    budget_line_list.code
  ) IN (
    SELECT
      CONCAT(period, '_', code)
    FROM
      INSERTED
  );

INSERT INTO
  coupa.budget_line_list
SELECT
  *
FROM
  INSERTED END;

END
