{%- set unique_key = "associate_id" -%}

{{-
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key=unique_key,
        merge_update_columns=[unique_key],
        alias="stg_employee_numbers",
        post_hook=[
            "{{ create_clustered_index(columns=['associate_id', 'employee_number', 'is_active'], unique=True) }}",
        ],
    )
-}}

with
    max_employee_number as (
        select max(employee_number) as max_employee_number from {{ this }}
    ),

    using_clause as (select {{ unique_key }} from {{ source("adp", "employees_all") }}),

    updates as (
        select {{ unique_key }}
        from using_clause
        {% if is_incremental() -%}
        where {{ unique_key }} in (select {{ unique_key }} from {{ this }})
        {%- endif %}
    ),

    inserts as (
        select
            uc.{{ unique_key }},
            {% if is_incremental() %}
            men.max_employee_number
            + row_number() over (order by uc.{{ unique_key }}) as employee_number
            {% else %} employee_number
            {% endif %}
        from using_clause as uc
        cross join max_employee_number as men
        where {{ unique_key }} not in (select {{ unique_key }} from updates)
    )

select {{ unique_key }}, null as associate_id_legacy, employee_number, 1 as is_active
from inserts
