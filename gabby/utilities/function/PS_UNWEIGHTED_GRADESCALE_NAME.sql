CREATE
OR ALTER
FUNCTION utilities.[PS_UNWEIGHTED_GRADESCALE_NAME] (
  @academic_year INT,
  @gradescale_name VARCHAR(125)
) RETURNS VARCHAR(125)
WITH
  SCHEMABINDING AS BEGIN
SET
ANSI_NULLS ON;

SET
QUOTED_IDENTIFIER ON;

RETURN CASE
/* unweighted pre-2016 */
  WHEN (
    @academic_year < 2016
    AND @gradescale_name = 'NCA Honors'
  ) THEN 'NCA 2011'
  /* unweighted 2016-2018 */
  WHEN (
    @academic_year >= 2016
    AND @gradescale_name = 'NCA Honors'
  ) THEN 'KIPP NJ 2016 (5-12)'
  /* unweighted 2019+ */
  WHEN (
    @academic_year >= 0
    AND @gradescale_name = 'KIPP NJ 2019 (5-12) Weighted'
  ) THEN 'KIPP NJ 2019 (5-12) Unweighted'
  /* MISSING GRADESCALE - default pre-2016 */
  WHEN (
    @academic_year < 2016
    AND (
      ISNULL(@gradescale_name, '') = ''
      OR @gradescale_name = 'NULL'
    )
  ) THEN 'NCA 2011'
  /* MISSING GRADESCALE - default 2016+ */
  WHEN (
    @academic_year >= 2016
    AND (
      ISNULL(@gradescale_name, '') = ''
      OR @gradescale_name = 'NULL'
    )
  ) THEN 'KIPP NJ 2016 (5-12)'
  /* return original grade scale */
  ELSE @gradescale_name
END;

END;
