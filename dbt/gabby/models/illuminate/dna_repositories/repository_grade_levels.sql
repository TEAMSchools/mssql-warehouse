select *
from {{ source("illuminate_dna_repositories", "repository_grade_levels") }}
where
    repo_grade_level_id in (
        select repo_grade_level_id
        from illuminate_dna_repositories.repository_grade_levels_validation
    )
