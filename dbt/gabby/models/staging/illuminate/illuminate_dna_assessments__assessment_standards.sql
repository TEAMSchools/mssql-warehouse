select *
from {{ source("illuminate_dna_assessments", "assessment_standards") }}
where
    concat(assessment_id, '_', standard_id) in (
        select concat(assessment_id, '_', standard_id)
        from illuminate_dna_assessments.assessment_standards_validation
    )
