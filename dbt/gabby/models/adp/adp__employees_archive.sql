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
