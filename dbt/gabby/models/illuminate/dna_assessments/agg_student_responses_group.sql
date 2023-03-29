{{
    dbt_utils.deduplicate(
        relation=source("illuminate_dna_assessments", "agg_student_responses_group"),
        partition_by="student_assessment_id, reporting_group_id",
        order_by="_fivetran_synced desc",
    )
}}
