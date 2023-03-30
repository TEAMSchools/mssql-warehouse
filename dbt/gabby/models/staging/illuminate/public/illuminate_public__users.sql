select *
from {{ source("illuminate_public", "users") }}
where [user_id] in (select [user_id] from illuminate_public.users_validation)
