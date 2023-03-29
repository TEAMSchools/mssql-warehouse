select *
from {{ source("illuminate_dna_assessments", "fields") }}
where field_id in (select field_id from illuminate_dna_assessments.fields_validation)
