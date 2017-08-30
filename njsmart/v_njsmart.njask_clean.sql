USE gabby
GO

ALTER VIEW njsmart.njask_clean AS

WITH combined_unpivot AS (
  SELECT local_student_id
        ,academic_year
        ,field
        ,value
  FROM
      (
       SELECT local_student_id
             ,CONVERT(INT, SUBSTRING(_file, PATINDEX('%-[0-9]%', _file) + 1, 4)) AS academic_year
      
             ,CONVERT(NVARCHAR(MAX),scaled_score_lal) AS scaled_score_lal
             ,CONVERT(NVARCHAR(MAX),performance_level_lal) AS performance_level_lal
             ,CONVERT(NVARCHAR(MAX),invalid_scale_score_reason_lal) AS invalid_scale_score_reason_lal
             ,CONVERT(NVARCHAR(MAX),void_reason_lal) AS void_reason_lal

             ,CONVERT(NVARCHAR(MAX),scaled_score_math) AS scaled_score_math
             ,CONVERT(NVARCHAR(MAX),performance_level_math) AS performance_level_math
             ,CONVERT(NVARCHAR(MAX),invalid_scale_score_reason_math) AS invalid_scale_score_reason_math
             ,CONVERT(NVARCHAR(MAX),void_reason_math) AS void_reason_math

             ,CONVERT(NVARCHAR(MAX),scaled_score_science) AS scaled_score_science
             ,CONVERT(NVARCHAR(MAX),performance_level_science) AS performance_level_science
             ,CONVERT(NVARCHAR(MAX),invalid_scale_score_reason_science) AS invalid_scale_score_reason_science
             ,CONVERT(NVARCHAR(MAX),void_reason_science) AS void_reason_science
       FROM gabby.njsmart.njask_archive

       UNION ALL

       SELECT local_student_id
             ,CONVERT(INT,(testing_year - 1)) AS academic_year
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,CONVERT(NVARCHAR(MAX),science_scale_score) AS science_scale_score
             ,CONVERT(NVARCHAR(MAX),science_proficiency_level) AS science_proficiency_level
             ,CONVERT(NVARCHAR(MAX),CASE WHEN science_invalid_scale_score_reason = '' THEN NULL ELSE science_invalid_scale_score_reason END) AS science_invalid_scale_score_reason
             ,CONVERT(NVARCHAR(MAX),CASE WHEN void_reason_science = '' THEN NULL ELSE void_reason_science END) AS void_reason_science
       FROM gabby.njsmart.njask
      ) sub
  UNPIVOT(
    value
    FOR field IN (scaled_score_lal
                 ,performance_level_lal
                 ,invalid_scale_score_reason_lal
                 ,void_reason_lal
                 ,scaled_score_math
                 ,performance_level_math
                 ,invalid_scale_score_reason_math
                 ,void_reason_math
                 ,scaled_score_science
                 ,performance_level_science
                 ,invalid_scale_score_reason_science
                 ,void_reason_science)
   ) u
 )

,combined_repivot AS (
  SELECT local_student_id
        ,academic_year
        ,subject
        ,scaled_score
        ,performance_level
        ,invalid_scale_score_reason
        ,void_reason
  FROM
      (
       SELECT local_student_id
             ,academic_year
             ,value
             ,UPPER(REVERSE(LEFT(REVERSE(field), (CHARINDEX('_', REVERSE(field)) - 1)))) AS subject
             ,REVERSE(SUBSTRING(REVERSE(field), (CHARINDEX('_', REVERSE(field)) + 1), LEN(field))) AS field      
       FROM combined_unpivot
      ) sub
  PIVOT(
    MAX(value)
    FOR field IN (scaled_score
                 ,performance_level
                 ,invalid_scale_score_reason
                 ,void_reason)
   ) p
 )

SELECT local_student_id
      ,academic_year
      ,CASE WHEN subject = 'LAL' THEN 'ELA' ELSE subject END AS subject
      ,CASE WHEN scaled_score = 0 THEN NULL ELSE scaled_score END AS scaled_score
      ,performance_level
FROM combined_repivot
WHERE ISNULL(invalid_scale_score_reason, 'No') = 'No'
  AND ISNULL(void_reason, 'No') = 'No'