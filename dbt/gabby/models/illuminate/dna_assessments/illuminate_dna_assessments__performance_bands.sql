{{
    config(
        materialized="table",
        schema="illuminate_dna_assessments",
        alias="performance_bands",
        {# https://docs.getdbt.com/reference/resource-configs/mssql-configs#indices #}
    )
}}

select *
from {{ source("illuminate_dna_assessments", "performance_bands") }}
where
    performance_band_id in (
        select performance_band_id
        from illuminate_dna_assessments.performance_bands_validation
    )
