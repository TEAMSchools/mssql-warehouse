CREATE OR ALTER VIEW
  illuminate_dna_assessments.performance_band_lookup AS
SELECT
  performance_band_set_id,
  [description],
  minimum_value,
  [label],
  label_number,
  is_mastery,
  LEAD(minimum_value, 1, 1001) OVER (
    PARTITION BY
      performance_band_set_id
    ORDER BY
      label_number
  ) - 0.1 AS maximum_value
FROM
  (
    SELECT
      pbs.performance_band_set_id,
      pb.[label],
      pb.label_number,
      pb.is_mastery,
      CAST(
        pbs.[description] AS VARCHAR(125)
      ) AS [description],
      CAST(pb.minimum_value AS FLOAT) AS minimum_value,
      ROW_NUMBER() OVER (
        PARTITION BY
          pbs.performance_band_set_id,
          pb.label_number
        ORDER BY
          pb._fivetran_synced DESC
      ) AS rn
    FROM
      gabby.illuminate_dna_assessments.performance_band_sets AS pbs
      INNER JOIN gabby.illuminate_dna_assessments.performance_bands AS pb ON pbs.performance_band_set_id = pb.performance_band_set_id
    WHERE
      pbs.deleted_at IS NULL
  ) AS sub
WHERE
  rn = 1
