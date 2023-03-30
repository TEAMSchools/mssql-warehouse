{%- set unique_key = "associate_id" -%}

{{-
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key=unique_key,
        schema="people",
    )
-}}

with
    using_clause as (select associate_id from {{ source("adp", "employees_all") }}),

    updates as (
        select *
        from using_clause
        {% if is_incremental() -%}
        where {{ unique_key }} in (select {{ unique_key }} from {{ this }})
        {%- endif %}
    ),

    inserts as (
        select *
        from using_clause
        where {{ unique_key }} not in (select {{ unique_key }} from updates)
    )

select *
from inserts
