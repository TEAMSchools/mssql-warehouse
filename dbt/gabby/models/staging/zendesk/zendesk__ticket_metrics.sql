{{-
    config(
        alias="stg_ticket_metrics",
        post_hook=[
            "{{ create_clustered_index(columns=['id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['id'], includes=['ticket_id', 'agent_wait_time_in_minutes', 'assigned_at', 'assignee_stations', 'assignee_updated_at', 'created_at', 'first_resolution_time_in_minutes', 'full_resolution_time_in_minutes', 'group_stations', 'initially_assigned_at', 'latest_comment_added_at', 'on_hold_time_in_minutes', 'reopens', 'replies', 'reply_time_in_minutes', 'requester_updated_at', 'requester_wait_time_in_minutes', 'solved_at', 'status_updated_at', 'updated_at', 'url']) }}",
            "{{ create_nonclustered_index(columns=['ticket_id'], includes=['agent_wait_time_in_minutes', 'assigned_at', 'assignee_stations', 'assignee_updated_at', 'created_at', 'first_resolution_time_in_minutes', 'full_resolution_time_in_minutes', 'group_stations', 'initially_assigned_at', 'latest_comment_added_at', 'on_hold_time_in_minutes', 'reopens', 'replies', 'reply_time_in_minutes', 'requester_updated_at', 'requester_wait_time_in_minutes', 'solved_at', 'status_updated_at', 'updated_at']) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("zendesk", "ticket_metrics"),
        partition_by="id",
        order_by="_fivetran_synced desc",
    )
}}
