WITH all_tables_columns_pivot AS (
  SELECT sub.schema_name
        ,sub.table_name
        ,sub.column_name
        ,sub.kippmiami_column_type
        ,sub.kippcamden_column_type
        ,sub.kippnewark_column_type
        ,sub.column_type_mismatch
        ,CASE 
          WHEN sub.kippnewark_column_type IS NULL THEN 'NULL AS [' + sub.column_name + ']'
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%varchar%' 
               THEN 'CONVERT(NVARCHAR, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%float%' 
               THEN 'CONVERT(FLOAT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%datetimeoffset%' 
               THEN 'CONVERT(DATETIMEOFFSET, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 THEN 'CONVERT(INT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          ELSE '[' + sub.column_name + ']' 
         END AS kippnewark
        ,CASE 
          WHEN sub.kippmiami_column_type IS NULL THEN 'NULL AS [' + sub.column_name + ']'
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%varchar%' 
               THEN 'CONVERT(NVARCHAR, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%float%' 
               THEN 'CONVERT(FLOAT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%datetimeoffset%' 
               THEN 'CONVERT(DATETIMEOFFSET, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 THEN 'CONVERT(INT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          ELSE '[' + sub.column_name + ']' 
         END AS kippmiami        
        ,CASE 
          WHEN sub.kippcamden_column_type IS NULL THEN 'NULL AS [' + sub.column_name + ']'
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%varchar%' 
               THEN 'CONVERT(NVARCHAR, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%float%' 
               THEN 'CONVERT(FLOAT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 AND sub.column_type_concat LIKE '%datetimeoffset%' 
               THEN 'CONVERT(DATETIMEOFFSET, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          WHEN sub.column_type_mismatch = 1 THEN 'CONVERT(INT, [' + sub.column_name + ']) AS [' + sub.column_name + ']' 
          ELSE '[' + sub.column_name + ']'
         END AS kippcamden
  FROM
      (
       SELECT p.[schema_name]
             ,p.table_name
             ,p.column_name
             ,p.kippmiami AS kippmiami_column_type
             ,p.kippcamden AS kippcamden_column_type
             ,p.kippnewark AS kippnewark_column_type
             ,CONCAT(p.kippnewark, p.kippcamden, p.kippmiami) AS column_type_concat
             ,CASE
               WHEN (CONCAT(p.kippcamden,p.kippnewark) <> '' AND CHARINDEX(p.kippmiami, CONCAT(p.kippcamden,p.kippnewark)) = 0)
                 OR (CONCAT(p.kippmiami,p.kippnewark) <> '' AND CHARINDEX(p.kippcamden, CONCAT(p.kippmiami,p.kippnewark)) = 0)
                 OR (CONCAT(p.kippmiami,p.kippcamden) <> '' AND CHARINDEX(p.kippnewark, CONCAT(p.kippmiami,p.kippcamden)) = 0)
                    THEN 1
               ELSE 0
              END AS column_type_mismatch
       FROM 
           (
            SELECT [db_name]
                  ,[schema_name]
                  ,table_name
                  ,column_name
                  ,column_type
            FROM gabby.utilities.all_tables_columns
            WHERE column_id > -1
              AND [db_name] <> 'gabby'
           ) sub
       PIVOT(
         MAX(column_type)
         FOR [db_name] IN ([kippnewark], [kippcamden], [kippmiami])
        ) p
    ) sub
 )

SELECT sub.[schema_name]
      ,sub.table_name
      ,sub.column_type_mismatch
      ,CASE 
        WHEN t.n = 0 THEN 'USE gabby'
        WHEN t.n = 1 THEN 'GO'
        WHEN t.n = 2 THEN 'CREATE OR ALTER VIEW ' + sub.[schema_name] + '.' + sub.table_name + ' AS ' 
                            + CASE WHEN sub.kippnewark_count > 0 THEN sub.kippnewark ELSE '' END
                            + CASE WHEN sub.kippcamden_count > 0 THEN ' UNION ALL ' + sub.kippcamden ELSE '' END
                            + CASE WHEN sub.kippmiami_count > 0 THEN ' UNION ALL ' + sub.kippmiami ELSE '' END
                            + ';' 
        WHEN t.n = 3 THEN 'GO'
       END AS query
FROM
    (
     SELECT atc.[schema_name]
           ,atc.table_name                 
           ,'SELECT ''kippnewark'' AS [db_name] ' + gabby.dbo.GROUP_CONCAT_D(',' + atc.kippnewark, '') + ' FROM kippnewark.' + atc.[schema_name] + '.' + atc.table_name AS kippnewark
           ,'SELECT ''kippcamden'' AS [db_name] ' + gabby.dbo.GROUP_CONCAT_D(',' + atc.kippcamden, '') + ' FROM kippcamden.' + atc.[schema_name] + '.' + atc.table_name AS kippcamden
           ,'SELECT ''kippmiami'' AS [db_name] ' + gabby.dbo.GROUP_CONCAT_D(',' + atc.kippmiami, '') + ' FROM kippmiami.' + atc.[schema_name] + '.' + atc.table_name AS kippmiami
           
           ,MAX(atc.column_type_mismatch) AS column_type_mismatch
           ,COUNT(CASE WHEN atc.kippnewark NOT LIKE '%NULL%' THEN atc.kippnewark END) AS kippnewark_count
           ,COUNT(CASE WHEN atc.kippcamden NOT LIKE '%NULL%' THEN atc.kippcamden END) AS kippcamden_count
           ,COUNT(CASE WHEN atc.kippmiami NOT LIKE '%NULL%' THEN atc.kippmiami END) AS kippmiami_count
     FROM all_tables_columns_pivot atc
     WHERE atc.table_name NOT LIKE 'fivetran%'
       AND atc.[schema_name] <> 'fivetran_log'
     GROUP BY atc.table_name
             ,atc.[schema_name]
    ) sub
CROSS JOIN (SELECT n FROM gabby.utilities.row_generator WHERE n <= 3) t
ORDER BY sub.[schema_name], sub.table_name, t.n