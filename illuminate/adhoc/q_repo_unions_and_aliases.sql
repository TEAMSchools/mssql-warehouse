WITH oer_repos AS (
  SELECT CONCAT('repository_', r.repository_id) AS repo_name
        ,CONCAT('SELECT *', CHAR(10), 'FROM gabby.illuminate_dna_repositories.', CONCAT('repository_', r.repository_id), ' UNION ALL ') AS select_statement
  FROM gabby.illuminate_dna_repositories.repositories r
  JOIN gabby.illuminate_codes.dna_scopes dsc
    ON r.code_scope_id = dsc.code_id
  JOIN gabby.illuminate_codes.dna_subject_areas dsu
    ON r.code_subject_area_id = dsu.code_id
  WHERE ((dsc.code_translation = 'Unit Assessment' AND dsu.code_translation = 'English') OR r.title = 'English OE - Quarterly Assessments')
 )

SELECT *
FROM
    (
     SELECT t.name AS table_name
           ,f.label
           ,COALESCE(',' + c.name + ' AS [' + LTRIM(RTRIM(f.label)) + ']', ',' + c.name) AS pivot_value
     FROM gabby.sys.tables t
     JOIN gabby.sys.all_columns c
       ON t.object_id = c.object_id
      AND c.name NOT LIKE '_fivetran%'
     LEFT OUTER JOIN gabby.illuminate_dna_repositories.fields f
       ON c.name = f.name
      AND SUBSTRING(t.name, CHARINDEX('_', t.name) + 1, LEN(t.name)) = f.repository_id
     WHERE t.name IN (SELECT repo_name FROM oer_repos)    
    ) sub
PIVOT(
  MAX(pivot_value)
  FOR table_name IN ([repository_154]
                    ,[repository_155]
                    ,[repository_158]
                    ,[repository_161]
                    ,[repository_162]
                    ,[repository_163]
                    ,[repository_175]
                    ,[repository_79])
 ) p