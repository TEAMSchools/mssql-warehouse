{{-
    config(
        alias="stg_incidents",
        post_hook=[],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("deanslist", "incidents"),
        partition_by="incident_id",
        order_by="_modified desc, _line desc",
    )
}}
