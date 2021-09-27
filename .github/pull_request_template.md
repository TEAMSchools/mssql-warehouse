**Code checks:**
1) Is your branch up to date with `main`? Update from `main` and resolve and merge conflicts before submitting.
2) Are all objects referenced in three-parts: `{database}.{schema}.{table}`?
3) Are all columns prefixed with a table alias (i.e. `t.column_name`)?
4) Are you `JOIN`-ing to a subquery? Refactor as a `CTE`.
5) Do your CTEs significantly transform the data, or could they be refactored into simple `JOIN`s?
6) Will every `SELECT` column be used downstream? Remove superfluous columns.
7) Does every table `JOIN` introduce columns that are used downstream? Remove superfluous `JOIN`s.
8) Double check that your SQL conforms to the style guide.

**What is the purpose of this view?**
> *[extract|feed|clean-up|other] Brief explanation...*
