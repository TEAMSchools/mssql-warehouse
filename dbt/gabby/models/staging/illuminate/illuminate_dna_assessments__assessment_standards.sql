{{-
    config(
        alias="stg_assessment_standards",
        post_hook=[
            "{{ create_clustered_index(columns=['assessment_id', 'standard_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['assessment_id', 'standard_id'], includes=['performance_band_set_id']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "assessment_standards") }}
where
    concat(assessment_id, '_', standard_id) in (
        select concat(assessment_id, '_', standard_id)
        from illuminate_dna_assessments.assessment_standards_validation
    )
