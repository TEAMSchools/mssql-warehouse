{{-
    config(
        alias="stg_assignmentcategoryassoc",
        post_hook=[
            "{{ create_clustered_index(columns=['assignmentcategoryassocid'], unique=True) }}"
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("powerschool", "assignmentcategoryassoc"),
        partition_by="assignmentcategoryassocid",
        order_by="_modified desc",
    )
}}
