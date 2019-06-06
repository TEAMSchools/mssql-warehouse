USE gabby
GO

CREATE OR ALTER VIEW esea_mailmerge AS

WITH scaffold AS (
   SELECT t.df_employee_number
        ,t.preferred_lastfirst
        ,t.legal_entity_name
        ,t.location
        ,t.job_title
        ,t.email_address
        ,t.academic_year
        ,YEAR(t.date_value) AS calendar_year
        ,MONTH(t.date_value) AS month_num
        ,SUM(hours_worked) AS month_hours_worked
        ,COUNT(t.df_employee_number)*9.5 AS month_possible_hours
   FROM tableau.staff_tracker t
   GROUP BY t.df_employee_number
           ,t.preferred_lastfirst
           ,t.legal_entity_name
           ,t.location
           ,t.job_title
           ,t.email_address
           ,t.academic_year
           ,YEAR(t.date_value)
           ,MONTH(t.date_value)
   )

,days_table AS (

  SELECT p.df_employee_number
        ,p.academic_year
        ,p.month_num
        ,p.month_max_days
        ,COALESCE([1],0) AS DAY_1
        ,COALESCE([2],0) AS DAY_2
        ,COALESCE([3],0) AS DAY_3
        ,COALESCE([4],0) AS DAY_4
        ,COALESCE([5],0) AS DAY_5
        ,COALESCE([6],0) AS DAY_6
        ,COALESCE([7],0) AS DAY_7
        ,COALESCE([8],0) AS DAY_8
        ,COALESCE([9],0) AS DAY_9
        ,COALESCE([10],0) AS DAY_10
        ,COALESCE([11],0) AS DAY_11
        ,COALESCE([12],0) AS DAY_12
        ,COALESCE([13],0) AS DAY_13
        ,COALESCE([14],0) AS DAY_14
        ,COALESCE([15],0) AS DAY_15
        ,COALESCE([16],0) AS DAY_16
        ,COALESCE([17],0) AS DAY_17
        ,COALESCE([18],0) AS DAY_18
        ,COALESCE([19],0) AS DAY_19
        ,COALESCE([20],0) AS DAY_20
        ,COALESCE([21],0) AS DAY_21
        ,COALESCE([22],0) AS DAY_22
        ,COALESCE([23],0) AS DAY_23
        ,COALESCE([24],0) AS DAY_24
        ,COALESCE([25],0) AS DAY_25
        ,COALESCE([26],0) AS DAY_26
        ,COALESCE([27],0) AS DAY_27
        ,COALESCE([28],0) AS DAY_28
        ,CASE WHEN month_max_days >= 29 THEN COALESCE([29],0) END AS DAY_29
        ,CASE WHEN month_max_days >= 30 THEN COALESCE([30],0) END AS DAY_30
        ,CASE WHEN month_max_days = 31 THEN COALESCE([31],0) END AS DAY_31
        FROM (SELECT df_employee_number
              ,academic_year
              ,hours_worked
              ,MONTH(date_value) AS month_num
              ,DAY(date_value) AS day_num
              ,DAY(EOMONTH(date_value)) AS month_max_days
        FROM tableau.staff_tracker) sub
  PIVOT ( 
    SUM(hours_worked) 
    FOR day_num IN ([1] ,[2] ,[3] ,[4] ,[5] ,[6] ,[7] ,[8] ,[9] ,[10] ,[11] ,[12] ,[13] ,[14] ,[15] ,[16] ,[17] ,[18] ,[19] ,[20] ,[21] ,[22] ,[23] ,[24] ,[25] ,[26] ,[27] ,[28] ,[29] ,[30] ,[31]) 
    )p
    )

SELECT s.df_employee_number
      ,s.preferred_lastfirst
      ,s.legal_entity_name
      ,s.location
      ,s.job_title
      ,s.email_address
      ,s.academic_year
      ,s.month_num
      ,CASE WHEN s.month_num = 1 THEN 'January'
            WHEN s.month_num = 2 THEN 'February'
            WHEN s.month_num = 3 THEN 'March'
            WHEN s.month_num = 4 THEN 'April'
            WHEN s.month_num = 5 THEN 'May'
            WHEN s.month_num = 6 THEN 'June'
            WHEN s.month_num = 7 THEN 'July'
            WHEN s.month_num = 8 THEN 'August'
            WHEN s.month_num = 9 THEN 'September'
            WHEN s.month_num = 10 THEN 'October'
            WHEN s.month_num = 11 THEN 'November'
            WHEN s.month_num = 12 THEN 'December'
        END AS month_text
      ,s.calendar_year
      ,s.month_hours_worked
      ,s.month_possible_hours
      ,s.month_possible_hours - s.month_hours_worked AS month_hours_not_worked
      ,CONVERT(INT,ROUND(s.month_hours_worked/s.month_possible_hours*100,0)) AS month_percent_worked
      ,CONVERT(INT,ROUND((s.month_possible_hours - s.month_hours_worked)/s.month_possible_hours*100,0)) AS month_percent_not_worked
      ,d.month_max_days
      ,d.DAY_1
      ,d.DAY_2
      ,d.DAY_3
      ,d.DAY_4
      ,d.DAY_5
      ,d.DAY_6
      ,d.DAY_7
      ,d.DAY_8
      ,d.DAY_9
      ,d.DAY_10
      ,d.DAY_11
      ,d.DAY_12
      ,d.DAY_13
      ,d.DAY_14
      ,d.DAY_15
      ,d.DAY_16
      ,d.DAY_17
      ,d.DAY_18
      ,d.DAY_19
      ,d.DAY_20
      ,d.DAY_21
      ,d.DAY_22
      ,d.DAY_23
      ,d.DAY_24
      ,d.DAY_25
      ,d.DAY_26
      ,d.DAY_27
      ,d.DAY_28
      ,d.DAY_29
      ,d.DAY_30
      ,d.DAY_31

FROM scaffold s LEFT JOIN days_table d
  ON s.df_employee_number = d.df_employee_number
 AND s.academic_year = d.academic_year
 AND s.month_num = d.month_num