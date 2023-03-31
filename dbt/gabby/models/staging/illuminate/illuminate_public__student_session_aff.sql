{{-
    config(
        alias="stg_student_session_aff",
        post_hook=[
            "{{ create_clustered_index(columns=['stu_sess_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['student_id', 'grade_level_id', 'entry_date', 'leave_date']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_public", "student_session_aff") }}
where
    stu_sess_id
    in (select stu_sess_id from illuminate_public.student_session_aff_validation)
