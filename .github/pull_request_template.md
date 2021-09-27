**Code checks:**
1) Is your branch up to date with `main`? Update from `main` and resolve and merge conflicts before submitting.
2) Are all objects referenced in three-parts ([db_name].[schema_name].[table_name])?
3) Are there subqueries that could be refactored as simple `JOIN`s?
4) Are there CTEs that could be refactored as simple `JOIN`s?
5) Will every `SELECT` column be used downstream? Remove superfluous columns.
6) Does every table `JOIN` introduce columns that are used downstream? Remove superfluous `JOIN`s.
7) Double check that your SQL conforms to the style guide.

**What is the purpose of this view?**
> *[extract|feed|clean-up|other] Brief explanation...*
