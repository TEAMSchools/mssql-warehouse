{{-
    config(
        alias="stg_behavior",
        post_hook=[],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("deanslist", "behavior"),
        partition_by="dlsaid",
        order_by="_modified desc, _line desc",
    )
}}
