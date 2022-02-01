USE gabby
GO

SELECT ga.[db_name]
      ,MIN(ga.assignmentcategoryassocid) AS min_assignmentcategoryassocid

      ,rt.alt_name
      ,rt.[start_date]
      ,rt.end_date
FROM
    (
     SELECT CONVERT(INT, asec.assignmentsectionid) AS assignmentsectionid
           ,asec.duedate AS assign_date
           ,asec.[db_name]

           ,aca.assignmentcategoryassocid
     FROM powerschool.assignmentsection asec
     LEFT JOIN powerschool.assignmentcategoryassoc aca
       ON asec.assignmentsectionid = aca.assignmentsectionid
      AND asec.[db_name] = aca.[db_name]
     WHERE asec.duedate >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
    ) ga
JOIN gabby.reporting.reporting_terms rt
  ON ga.assign_date BETWEEN rt.[start_date] AND rt.end_date
 AND rt.identifier = 'RT'
 AND rt.schoolid = 0
GROUP BY ga.[db_name]
        ,rt.alt_name
        ,rt.[start_date]
        ,rt.end_date
ORDER BY rt.alt_name, ga.[db_name]
