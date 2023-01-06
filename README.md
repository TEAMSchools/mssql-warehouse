# mssql-warehouse

Formatting via [sql-formatter](https://github.com/sql-formatter-org/sql-formatter)
Linting via SQLFluff: [Rules Reference](https://docs.sqlfluff.com/en/stable/rules.html)

## General Rules & Guidelines

- Use `snake_case`
- Limit line length to 88 characters
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

- Complex logical statements should be wrapped in **(parenthesis)**
  - `CASE WHEN (... AND ...) THEN ...`
- Wrap `COLLATE` statements in **(parenthesis)**
  - `(tbl.col COLLATE LATIN1_GENERAL_BIN) AS foo,`

## Known Issues

- `BETWEEN` clauses **MUST** be wrapped in **(parenthesis)** for successful parsing
  - `(x BETWEEN y AND z)`
- `sql-format` will add an extra space in-between the function name and the parenthesis for user-defined functions
  - On occasion, it will add multiple spaces, breaking the code. This can be addressed by wrapping the statement in **(parenthesis)**, e.g. `(GLOBAL_ACADEMIC_YEAR () - 1)`

## Troubleshooting Linter Errors

- `L016`: Line is too long
  - Surround longer expressions in **(parenthesis)**. All expressions > 33 characters will be automatically wrapped to the next lines.
- `PRS`: Found unparsable section: ...
