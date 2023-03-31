{{-
    config(
        alias="stg_agg_student_responses_standard",
        post_hook=[
            "{{ create_clustered_index(columns=['student_assessment_id', 'standard_id'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['student_assessment_id', 'standard_id'], includes=['points', 'percent_correct', 'points_possible', 'assessment_id', 'student_id', 'performance_band_id', 'performance_band_level', 'mastered', 'answered', 'number_of_questions']) }}",
            "{{ create_nonclustered_index(columns=['assessment_id', 'points_possible'], includes=['percent_correct', 'points']) }}",
            "{{ create_nonclustered_index(columns=['assessment_id', 'standard_id', 'points_possible'], includes=['student_assessment_id', 'points', 'percent_correct', 'student_id']) }}",
            "{{ create_nonclustered_index(columns=['assessment_id', 'student_id'], includes=['mastered', 'percent_correct', 'points', 'answered']) }}",
        ],
    )
-}}

{{
    dbt_utils.deduplicate(
        relation=source(
            "illuminate_dna_assessments", "agg_student_responses_standard"
        ),
        partition_by="student_assessment_id, standard_id",
        order_by="_fivetran_synced desc",
    )
}}
