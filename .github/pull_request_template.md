**Code checks:**
1) Is your branch up to date with `main`? Update from `main` and resolve and merge conflicts before submitting.
2) Are you `JOIN`-ing to a subquery? Refactor as a `CTE`.
3) Do your CTEs significantly transform the data, or could they be refactored into simple `JOIN`s?
4) Will every `SELECT` column be used downstream? Remove superfluous columns.
5) Does every table `JOIN` introduce columns that are used downstream? Remove superfluous `JOIN`s.
6) Double check that your SQL conforms to the style guide.
   * All tables should be referenced in three-parts: `{database}.{schema}.{table}`
   * All columns sould be prefixed with a table alias: `t.column_name`
   * All keywords should be UPPERCASE; all identifiers should be `snake_case`
   * In the event an identifier shares a name with a keyword, surround it with [square brackets].
   * Spaces, not tabs.
    
**What is the purpose of this view?**
> *[extract|feed|clean-up|other] Brief explanation...*
