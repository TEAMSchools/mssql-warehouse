{{-
    config(
        alias="stg_communication",
        post_hook=[
            "{{ create_clustered_index(columns=['dlcall_log_id'], unique=True) }}"
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("deanslist", "communication"),
        partition_by="dlcall_log_id",
        order_by="_modified desc, _line desc",
    )
}}
