{{-
    config(
        alias="stg_person_data",
        post_hook=[
            "{{ create_clustered_index(columns=['person_identifier'], unique=True) }}"
        ],
    )
-}}

with
    deduplicate as (
        {{
            dbt_utils.deduplicate(
                relation=source("titan", "person_data"),
                partition_by="person_identifier",
                order_by="_modified desc",
            )
        }}
    )

select
    person_identifier,
    application_academic_school_year,
    application_approved_benefit_type,
    eligibility,
    eligibility_benefit_type,
    eligibility_determination_reason,
    is_directly_certified,
    convert(money, total_balance) as total_balance,
    convert(money, total_negative_balance) as total_negative_balance,
    convert(money, total_positive_balance) as total_positive_balance,
    cast(
        coalesce(
            left(application_academic_school_year, 4), substring(_file, 12, 4)
        ) as int
    ) as application_academic_school_year_clean,
    case
        when eligibility = '1'
        then 'F'
        when eligibility = '2'
        then 'R'
        when eligibility = '3'
        then 'P'
        else cast(eligibility as nvarchar(1))
    end as eligibility_name
from deduplicate
