{{-
    config(
        alias="stg_assessments_reporting_groups",
        post_hook=[
            "{{ create_clustered_index(columns=['assessment_reporting_group_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['assessment_id', 'reporting_group_id'], includes=['performance_band_set_id']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "assessments_reporting_groups") }}
where
    assessment_reporting_group_id in (
        select assessment_reporting_group_id
        from illuminate_dna_assessments.assessments_reporting_groups_validation
    )
