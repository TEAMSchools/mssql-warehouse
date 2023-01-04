# mssql-warehouse

## General Rules & Guidelines

- Use `snake_case`
- Always use uppercase for the reserved keywords (e.g. `SELECT` and `WHERE`)
- Avoid abbreviated keywords; use the full-length ones where available (e.g `ABSOLUTE` > `ABS`)
- Prefer ANSI SQL functions over vendor-specific functions for maximum portability

## Selects

- Group columns by source table
- Order columns from simple columns to more-complex functions and aggregates
- Always prefer CTEs to subqueries for transformations and rollups
- When subqueries are necessary, avoid going more than one level deep

## Joins

- `INNER JOIN` should be used explicitly; avoid using a naked `JOIN`
- Wrap join conditions in **(parenthesis)**: `ON (x = y AND z = x)`
- Do not `JOIN` to a subquery; use a CTE and join it to the main clause
- Order `INNER JOIN` tables first and then `LEFT JOIN` tables
  - Do not intermingle them unless totally necessary

## Naming Conventions

- Alias column and table names explicitly with `AS`
- Ensure names are unique and do not exist as reserved keywords
- If you must use a keyword as a column name, quote it in `[square brackets]`
- Avoid abbreviations, but if you must, make sure they are commonly understood
- Names must begin with a letter and should not end with an underscore
- Only use letters, numbers, and underscores in names
- Avoid using multiple consecutive underscores
- Use underscores where you would normally use a space

## Formatting Best Practices

- `x BETWEEN y AND z` clauses must be put in **(parenthesis)** for successful parsing
- User-defined functions will add an extra space in-between the function name and the parenthesis
- Complex logical statements should be wrapped in **(parenthesis)** for optimal formatting
  - e.g. `CASE WHEN (... AND ...) THEN ...`
- Wrap `COLLATE` statements in **(parenthesis)** to avoid `sql-formatter` confusion:
  - e.g. `(tbl.col COLLATE LATIN1_GENERAL_BIN) AS foo,`

## Troubleshooting Linter Errors

- `Line is too long [L016]`
- `Found unparsable section: ... [PRS]`
