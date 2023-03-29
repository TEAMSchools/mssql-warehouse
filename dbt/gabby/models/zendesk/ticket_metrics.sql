{{
    dbt_utils.deduplicate(
        relation=source("zendesk", "ticket_metrics"),
        partition_by="id",
        order_by="_fivetran_synced desc",
    )
}}
