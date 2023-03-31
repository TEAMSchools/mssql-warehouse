{{-
    config(
        alias="stg_assessment_grade_levels",
        post_hook=[
            "{{ create_clustered_index(columns=['assessment_grade_level_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['assessment_id'], includes=['grade_level_id']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "assessment_grade_levels") }}
where
    assessment_grade_level_id in (
        select assessment_grade_level_id
        from illuminate_dna_assessments.assessment_grade_levels_validation
    )
