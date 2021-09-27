**Code checks:**
1) Is your branch up to date with `main`? Update from `main` and resolve and merge conflicts before submitting.
2) Are all objects referenced in three-parts: `{database}.{schema}.{table}`?
3) Are you `JOIN`-ing to a subquery? Refactor as a `CTE`.
4) Do your CTEs significantly transform the data, or could they be refactored into simple `JOIN`s?
5) Will every `SELECT` column be used downstream? Remove superfluous columns.
6) Does every table `JOIN` introduce columns that are used downstream? Remove superfluous `JOIN`s.
7) Double check that your SQL conforms to the style guide.

**What is the purpose of this view?**
> *[extract|feed|clean-up|other] Brief explanation...*
