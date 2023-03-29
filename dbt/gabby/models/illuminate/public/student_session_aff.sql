select *
from {{ source("illuminate_public", "student_session_aff") }}
where
    stu_sess_id
    in (select stu_sess_id from illuminate_public.student_session_aff_validation)
