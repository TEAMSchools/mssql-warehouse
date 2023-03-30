{{
    dbt_utils.deduplicate(
        relation=source("coupa", "budget_line_list"),
        partition_by="period, code",
        order_by="_fivetran_synced desc",
    )
}}
