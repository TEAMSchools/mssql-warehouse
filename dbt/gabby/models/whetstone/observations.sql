{{
    dbt_utils.deduplicate(
        relation=source("whetstone", "observations"),
        partition_by="_id",
        order_by="_modified desc",
    )
}}
