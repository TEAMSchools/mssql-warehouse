{{-
    config(
        alias="stg_assignmentsection",
        post_hook=[
            "{{ create_clustered_index(columns=['assignmentsectionid'], unique=True) }}"
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("powerschool", "assignmentsection"),
        partition_by="assignmentsectionid",
        order_by="_modified desc",
    )
}}
