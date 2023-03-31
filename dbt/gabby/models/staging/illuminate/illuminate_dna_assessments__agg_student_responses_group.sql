{# "{{ create_nonclustered_index(columns=['student_assessment_id', 'reporting_group_id', 'points_possible'], includes=['points', 'percent_correct', 'assessment_id']) }}", #}
{{-
    config(
        alias="stg_agg_student_responses_group",
        post_hook=[
            "{{ create_clustered_index(columns=['student_assessment_id', 'reporting_group_id'], unique=True) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("illuminate_dna_assessments", "agg_student_responses_group"),
        partition_by="student_assessment_id, reporting_group_id",
        order_by="_fivetran_synced desc",
    )
}}
