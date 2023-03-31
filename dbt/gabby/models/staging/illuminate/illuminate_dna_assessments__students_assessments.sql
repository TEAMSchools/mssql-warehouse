{# "{{ create_nonclustered_index(columns=['student_assessment_id'], includes=['assessment_id', 'student_id', 'date_taken', 'version_id', 'created_at', 'updated_at']) }}",
"{{ create_nonclustered_index(columns=['assessment_id'], includes=['student_id', 'date_taken']) }}",
"{{ create_nonclustered_index(columns=['student_id', 'assessment_id'], includes=['student_assessment_id', 'date_taken']) }}", #}
{{-
    config(
        alias="stg_students_assessments",
        post_hook=[
            "{{ create_clustered_index(columns=['student_assessment_id'], unique=True) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_assessments", "students_assessments") }}
where
    student_assessment_id not in (
        select student_assessment_id
        from {{ source("illuminate_dna_assessments", "students_assessments_archive") }}
    )
