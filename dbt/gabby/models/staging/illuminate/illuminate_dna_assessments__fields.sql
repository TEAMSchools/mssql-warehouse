{{-
    config(
        alias="stg_fields",
        post_hook=[
            "{{ create_clustered_index(columns=['field_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['field_id', 'assessment_id', 'deleted_at'], includes=['maximum', 'is_rubric', 'sheet_label', 'extra_credit']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "fields") }}
where field_id in (select field_id from illuminate_dna_assessments.fields_validation)
