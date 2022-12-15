# gabby

## General Rules & Guidelines
- Almost always prefer CTEs over subqueries
- Alias column and table names explicitly with `AS`
- `INNER JOIN` should be used explicitly; avoid using a naked `JOIN`

## Known Formatting Issues

- `x BETWEEN y AND z` clauses must be put in **(parenthesis)** for successful parsing
- User-defined functions will add an extra space in-between the function name and the parenthesis
