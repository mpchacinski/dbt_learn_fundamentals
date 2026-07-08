{%- macro cents_to_dollars(column_name, decimals=2) -%}
    ROUND(CAST({{ column_name }} AS NUMBER(38,2)) / 100.0, {{ decimals }})
{% endmacro %}