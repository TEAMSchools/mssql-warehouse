{{-
    config(
        alias="stg_assignmentscore",
        post_hook=[],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("powerschool", "assignmentscore"),
        partition_by="assignmentscoreid",
        order_by="_modified desc",
    )
}}
