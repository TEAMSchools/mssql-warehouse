{% macro re_search(pattern, string) -%}
{%- set match = modules.re.search(pattern, string) -%}
{%- if match is not None -%} {{ match.group(1) }}
{%- else -%} ''
{%- endif -%}
{%- endmacro %}
