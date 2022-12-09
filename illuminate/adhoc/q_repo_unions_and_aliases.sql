with
  repos as (
    select
      r.title,
      dsc.code_translation as scope,
      dsu.code_translation as subject_area,
      concat('repository_', r.repository_id) as repo_name,
      concat(
        'SELECT ',
        r.repository_id,
        ' AS repository_id',
        char(10),
        char(13),
        ',repository_row_id',
        char(10),
        char(13),
        ',student_id',
        char(10),
        char(13),
        'FROM gabby.illuminate_dna_repositories.',
        concat('repository_', r.repository_id),
        char(10),
        char(13),
        'UNION ALL '
      ) as select_statement
    from
      gabby.illuminate_dna_repositories.repositories r
      join gabby.illuminate_codes.dna_scopes dsc on r.code_scope_id = dsc.code_id
      join gabby.illuminate_codes.dna_subject_areas dsu on r.code_subject_area_id = dsu.code_id
      /* F&P */
    where
      dsc.code_translation = 'Reporting'
      and dsu.code_translation = 'F&P'
      -- WHERE ((dsc.code_translation = 'Unit Assessment' AND dsu.code_translation =
      -- 'English') OR r.title = 'English OE - Quarterly Assessments') /* OER */
  )
select
  column_name,
  label,
  coalesce([repository_126], concat(',NULL AS [', label, ']')) as [repository_126],
  coalesce([repository_169], concat(',NULL AS [', label, ']')) as [repository_169],
  coalesce([repository_170], concat(',NULL AS [', label, ']')) as [repository_170]
from
  (
    select
      t.name as table_name,
      c.name as column_name,
      f.label,
      coalesce(',' + c.name + ' AS [' + ltrim(rtrim(f.label)) + ']', ',' + c.name) as pivot_value
    from
      gabby.sys.tables t
      join gabby.sys.all_columns c on t.object_id = c.object_id
      and c.name not like '_fivetran%'
      join gabby.illuminate_dna_repositories.fields f on c.name = f.name
      and substring(t.name, charindex('_', t.name) + 1, len(t.name)) = f.repository_id
      and f.deleted_at is null
    where
      t.name in (
        select
          repo_name
        from
          repos
      )
      -- /*
  ) sub pivot (
    max(pivot_value) for table_name in ([repository_126], [repository_169], [repository_170])
  ) p
  -- */
