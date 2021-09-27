**Code checks:**
1) Is your branch up to date with `main`? Update from `main` and resolve and merge conflicts before submitting.
2) Are all objects referenced in three-parts ([db_name].[schema_name].[table_name])?
3) Are there subqueries that could be refactored as simple `JOIN`s?
4) Are there CTEs that could be refactored as simple `JOIN`s?
5) Does every table `JOIN` and `SELECT` column help the view achieve its purpose? Remove superfluous `JOIN`s and columns.
6) Does your SQL formatting conform to the style guide?

8) What is the view's purpose?
> *[extract|feed|clean-up|other] Brief explanation...*
