USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.performance_band_lookup AS 

SELECT performance_band_set_id
      ,description
      ,minimum_value
      ,LEAD(minimum_value, 1, 1001) OVER(PARTITION BY performance_band_set_id ORDER BY label_number) - 1 AS maximum_value
      ,label_number
      ,is_mastery
FROM
    (
     SELECT pbs.performance_band_set_id
           ,pbs.description
      
           ,pb.minimum_value           
           ,pb.label_number
           ,pb.is_mastery
           ,pb._fivetran_deleted
           ,pb._fivetran_synced

           ,ROW_NUMBER() OVER(
              PARTITION BY pbs.performance_band_set_id, pb.label_number
                ORDER BY pb._fivetran_synced DESC) AS rn
     FROM gabby.illuminate_dna_assessments.performance_band_sets pbs
     JOIN gabby.illuminate_dna_assessments.performance_bands pb
       ON pbs.performance_band_set_id = pb.performance_band_set_id
     WHERE pbs.deleted_at IS NULL     
    ) sub
WHERE rn = 1