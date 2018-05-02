USE gabby
GO

CREATE OR ALTER VIEW dayforce.grades_taught AS 

WITH e AS
(

     SELECT id.df_employee_number
           ,id.ps_teachernumber
           ,id.staff_lastfirst
           ,ce.studentid
     FROM gabby.people.id_crosswalk_powerschool id LEFT OUTER JOIN
          gabby.powerschool.course_enrollments ce
          ON id.ps_teachernumber = ce.teachernumber
          
     WHERE ce.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
)

SELECT df_employee_number
      ,ps_teachernumber
      ,staff_lastfirst
      ,REPLACE(RTRIM(CONCAT(grade_k,grade_1,grade_2,grade_3,grade_4,grade_5,grade_6,grade_7,grade_8,grade_9,grade_10,grade_11,grade_12)),' ',', ') AS grades_taught 

FROM(

     SELECT df_employee_number
             ,staff_lastfirst
             ,ps_teachernumber
             ,CASE WHEN [k] > 0 THEN 'K ' ELSE NULL END AS grade_k
             ,CASE WHEN [1] > 0 THEN '1 ' ELSE NULL END AS grade_1
             ,CASE WHEN [2] > 0 THEN '2 ' ELSE NULL END AS grade_2
             ,CASE WHEN [3] > 0 THEN '3 ' ELSE NULL END AS grade_3
             ,CASE WHEN [4] > 0 THEN '4 ' ELSE NULL END AS grade_4
             ,CASE WHEN [5] > 0 THEN '5 ' ELSE NULL END AS grade_5
             ,CASE WHEN [6] > 0 THEN '6 ' ELSE NULL END AS grade_6
             ,CASE WHEN [7] > 0 THEN '7 ' ELSE NULL END AS grade_7
             ,CASE WHEN [8] > 0 THEN '8 ' ELSE NULL END AS grade_8
             ,CASE WHEN [9] > 0 THEN '9 ' ELSE NULL END AS grade_9
             ,CASE WHEN [10] > 0 THEN '10 ' ELSE NULL END AS grade_10
             ,CASE WHEN [11] > 0 THEN '11 ' ELSE NULL END AS grade_11
             ,CASE WHEN [12] > 0 THEN '12 ' ELSE NULL END AS grade_12
     FROM (

              SELECT df_employee_number
                     ,ps_teachernumber
                     ,staff_lastfirst
                     ,[K]
                     ,[1]
                     ,[2]
                     ,[3]
                     ,[4]
                     ,[5]
                     ,[6]
                     ,[7]
                     ,[8]
                     ,[9]
                     ,[10]
                     ,[11]
                     ,[12]
              FROM (
                       SELECT e.df_employee_number
                              ,e.ps_teachernumber
                              ,e.staff_lastfirst
                              ,CASE WHEN s.grade_level = 0 THEN 'K' ELSE CONVERT(varchar,s.grade_level) END AS grade_level
                              ,COUNT(1) AS student_count
                       FROM e LEFT OUTER JOIN 
                            gabby.powerschool.students s
                            ON e.studentid = s.id
                       GROUP BY e.df_employee_number, e.ps_teachernumber, e.staff_lastfirst, s.grade_level
                       ) pivot_source
              PIVOT (
                 MAX(student_count)
                 FOR grade_level IN 
                               ([K]
                               ,[1]
                               ,[2]
                               ,[3]
                               ,[4]
                               ,[5]
                               ,[6]
                               ,[7]
                               ,[8]
                               ,[9]
                               ,[10]
                               ,[11]
                               ,[12]
                     )) p
         ) sub
         ) sub
         
ORDER by df_employee_number