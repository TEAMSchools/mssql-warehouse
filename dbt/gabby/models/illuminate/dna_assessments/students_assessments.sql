select *
from {{ source("illuminate_dna_assessments", "students_assessments") }}
where
    student_assessment_id not in (
        select student_assessment_id
        from illuminate_dna_assessments.students_assessments_archive
    )
