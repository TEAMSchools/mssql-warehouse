select *
from {{ source("illuminate_dna_assessments", "assessments_reporting_groups") }}
where
    assessment_reporting_group_id in (
        select assessment_reporting_group_id
        from illuminate_dna_assessments.assessments_reporting_groups_validation
    )
