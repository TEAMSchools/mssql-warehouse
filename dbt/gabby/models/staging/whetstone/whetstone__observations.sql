{# "{{ create_nonclustered_index(columns=['_id'], includes=['observation_scores']) }}",
"{{ create_nonclustered_index(columns=['archived_at', 'observed_at'], includes=['_id', 'observer', 'rubric', 'teacher', 'created', 'score', 'list_two_column_a', 'list_two_column_b']) }}",
"{{ create_nonclustered_index(columns=['score', 'archived_at'], includes=['rubric', 'teacher', 'observer', 'observed_at']) }}", #}
{{-
    config(
        alias="stg_observations",
        post_hook=[
            "{{ create_clustered_index(columns=['_id'], unique=True) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("whetstone", "observations"),
        partition_by="_id",
        order_by="_modified desc",
    )
}}
