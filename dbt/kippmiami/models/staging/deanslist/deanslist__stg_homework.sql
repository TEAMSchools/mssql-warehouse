{{-
    config(
        alias="stg_homework",
        post_hook=["{{ create_clustered_index(columns=['dlsaid'], unique=True) }}"],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("deanslist", "homework"),
        partition_by="dlsaid",
        order_by="_modified desc, _line desc",
    )
}}
