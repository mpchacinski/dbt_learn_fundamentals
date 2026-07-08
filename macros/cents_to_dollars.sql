{%- macro cents_to_dollars(column_name, decimals=2) -%}
    ROUND(CAST({{ column_name }} AS FLOAT) / 100.0, {{ decimals }})
{% endmacro %}