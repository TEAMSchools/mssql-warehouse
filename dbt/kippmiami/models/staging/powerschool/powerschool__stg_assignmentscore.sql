{{-
    config(
        alias="stg_assignmentscore",
        post_hook=[
            "{{ create_clustered_index(columns=['assignmentscoreid'], unique=True) }}"
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("powerschool", "assignmentscore"),
        partition_by="assignmentscoreid",
        order_by="_modified desc",
    )
}}
