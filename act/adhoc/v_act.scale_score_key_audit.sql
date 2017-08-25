SELECT *
FROM
    (
     SELECT academic_year
           ,grade_level
           ,administration_round
           ,subject
           ,MAX(raw_score) + 1 AS max_score_adjusted
           ,MAX(scale_score) AS max_scale_score
           ,COUNT(subject) AS N_records
     FROM gabby.act.scale_score_key
     GROUP BY academic_year
             ,grade_level
             ,administration_round
             ,subject
    ) sub
WHERE (max_score_adjusted != N_records) OR (RIGHT(max_scale_score, 1) NOT IN (1,6))