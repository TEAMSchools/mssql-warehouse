select *
from {{ source("illuminate_dna_assessments", "performance_bands") }}
where
    performance_band_id in (
        select performance_band_id
        from illuminate_dna_assessments.performance_bands_validation
    )
