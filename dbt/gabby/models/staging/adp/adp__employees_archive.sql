{{-
    config(
        alias="",
        post_hook=[
            "{{ create_clustered_index(columns=['position_id', '_modified'], unique=True) }}",
            "{{ create_nonclustered_index(columns=['position_id', 'position_status'], includes=['associate_id', '_modified', 'business_unit_description', 'location_description', 'home_department_description', 'job_title_description', 'reports_to_associate_id', 'annual_salary', 'flsa_description', 'wfmgr_pay_rule', 'wfmgr_accrual_profile', 'wfmgr_ee_type', 'wfmgr_badge_number']) }}",
        ],
    )
-}}

{%- set from_source = source("adp", "employees_archive") -%}

with
    row_hash as (
        select
            *,
            hashbytes(
                'SHA2_512',
                concat(
                    {{
                        dbt_utils.star(
                            from=from_source,
                            except=[
                                "_file",
                                "_line",
                                "_modified",
                                "_fivetran_synced",
                                "position_id",
                            ],
                        )
                    }}
                )
            ) as row_hash
        from {{ from_source }}
        where position_id is not null
    ),

    row_hash_lag as (
        select
            *,
            lag(row_hash, 1) over (
                partition by position_id order by _modified asc
            ) as row_hash_prev
        from row_hash
    )

select *
from row_hash_lag
where row_hash != row_hash_prev
