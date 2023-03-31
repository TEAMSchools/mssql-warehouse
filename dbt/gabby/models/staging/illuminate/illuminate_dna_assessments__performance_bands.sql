{# "{{ create_nonclustered_index(columns=['performance_band_id'], includes=['performance_band_set_id', 'minimum_value', 'label', 'label_number', 'color', 'is_mastery']) }}", #}
{{-
    config(
        alias="stg_performance_bands",
        post_hook=[
            "{{ create_clustered_index(columns=['performance_band_id'], unique=True) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "performance_bands") }}
where
    performance_band_id in (
        select performance_band_id
        from illuminate_dna_assessments.performance_bands_validation
    )
