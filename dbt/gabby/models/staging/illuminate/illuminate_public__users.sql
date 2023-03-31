{{-
    config(
        alias="stg_users",
        post_hook=[
            "{{ create_clustered_index(columns=[''user_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=[''state_id'], includes=[''user_id']) }}",
            "{{ create_nonclustered_index(columns=[''user_id'], includes=[''local_user_id', 'username', 'email1', 'first_name', 'last_name']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_public", "users") }}
where [user_id] in (select [user_id] from illuminate_public.users_validation)
