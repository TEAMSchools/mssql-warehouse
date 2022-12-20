CREATE
OR ALTER
FUNCTION utilities.DATE_TO_SY (@date DATE) RETURNS INT
WITH
  SCHEMABINDING AS BEGIN;

SET
ANSI_NULLS ON;

SET
QUOTED_IDENTIFIER ON;

RETURN CASE
  WHEN DATEPART(MONTH, @date) < 7 THEN (
    DATEPART(YEAR, @date) - 1
  )
  ELSE DATEPART(YEAR, @date)
END;

END;
