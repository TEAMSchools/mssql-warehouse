{{
    dbt_utils.deduplicate(
        relation=source("whetstone", "assignments"),
        partition_by="_id",
        order_by="_modified desc",
    )
}}
