{{-
    config(
        schema="powerschool",
        alias="stg_assignmentsection",
        post_hook=[],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("powerschool", "assignmentsection"),
        partition_by="assignmentsectionid",
        order_by="_modified desc",
    )
}}
