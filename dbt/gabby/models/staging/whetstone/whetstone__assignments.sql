{{-
    config(
        alias="stg_assignments",
        post_hook=[
            "{{ create_clustered_index(columns=['_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['_id'], includes=['user', 'creator', 'created', 'type', 'name']) }}",
            "{{ create_nonclustered_index(columns=['type'], includes=['tags', '_id']) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("whetstone", "assignments"),
        partition_by="_id",
        order_by="_modified desc",
    )
}}
