{{
    dbt_utils.deduplicate(
        relation=source("coupa", "users"),
        partition_by="login",
        order_by="_fivetran_synced desc",
    )
}}
