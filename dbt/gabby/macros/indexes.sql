{# https://github.com/dbt-msft/dbt-sqlserver/blob/73537af0cbb1162f585b3bebf06f1a043d1a28d0/dbt/include/sqlserver/macros/adapters/indexes.sql #}
{% macro create_clustered_index(columns, unique=False) -%}

{{ log("Creating clustered index...") }}

{% set idx_name = "clustered_" + local_md5(columns | join("_")) %}

if not exists (
    select *
    from sys.indexes
    where name = '{{ idx_name }}' and object_id = object_id('{{ this }}')
)
begin

create
{% if unique -%}
unique
{% endif %}
clustered index
    {{ idx_name }}
      on {{ this }} ({{ '[' + columns|join("], [") + ']' }})
end

{%- endmacro %}

{% macro create_nonclustered_index(columns, includes=False) %}

{{ log("Creating nonclustered index...") }}

{% if includes -%}
{% set idx_name = (
    "nonclustered_"
    + local_md5(columns | join("_"))
    + "_incl_"
    + local_md5(includes | join("_"))
) %}
{% else -%} {% set idx_name = "nonclustered_" + local_md5(columns | join("_")) %}
{% endif %}

if not exists (
    select *
    from sys.indexes
    where name = '{{ idx_name }}' and object_id = object_id('{{ this }}')
)
begin
create nonclustered index
    {{ idx_name }}
      on {{ this }} ({{ '[' + columns|join("], [") + ']' }})
      {% if includes -%}
        include ({{ '[' + includes|join("], [") + ']' }})
      {% endif %}
end

{% endmacro %}
