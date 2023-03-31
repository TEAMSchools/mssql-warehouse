{{-
    config(
        alias="stg_agg_student_responses",
        post_hook=[
            "{{ create_clustered_index(columns=['student_assessment_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['student_assessment_id'], includes=['date_taken', 'points', 'points_possible', 'percent_correct', 'assessment_id', 'version_id', 'student_id', 'performance_band_id', 'performance_band_level', 'mastered', 'answered', 'number_of_questions']) }}",
            "{{ create_nonclustered_index(columns=['assessment_id'], includes=['student_id', 'percent_correct', 'number_of_questions', 'performance_band_level']) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source("illuminate_dna_assessments", "agg_student_responses"),
        partition_by="student_assessment_id",
        order_by="_fivetran_synced desc",
    )
}}
