{{-
    config(
        alias="stg_repository_grade_levels",
        post_hook=[
            "{{ create_clustered_index(columns=['repo_grade_level_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['repository_id'], includes=['grade_level_id']) }}",
        ],
    )
-}}

select *
from {{ source("illuminate_dna_repositories", "repository_grade_levels") }}
where
    repo_grade_level_id in (
        select repo_grade_level_id
        from illuminate_dna_repositories.repository_grade_levels_validation
    )
