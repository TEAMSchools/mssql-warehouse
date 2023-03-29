select *
from {{ source("illuminate_dna_assessments", "assessment_grade_levels") }}
where
    assessment_grade_level_id in (
        select assessment_grade_level_id
        from illuminate_dna_assessments.assessment_grade_levels_validation
    )
