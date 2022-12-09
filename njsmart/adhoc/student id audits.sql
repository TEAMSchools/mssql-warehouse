with
  raw_files as (
    select
      'gabby.njsmart.njbct' as _file,
      test_id as _line,
      sid as state_student_id,
      local_student_id,
      first_name,
      last_name,
      'gabby.njsmart.njbct' as table_name
    from
      gabby.njsmart.njbct
    union all
    select
      'gabby.njsmart.njask' as _file,
      test_id as _line,
      sid as state_student_id,
      local_student_id,
      first_name,
      last_name,
      'gabby.njsmart.njask' as table_name
    from
      gabby.njsmart.njask
    union all
    select
      _file,
      _line,
      state_student_id,
      local_student_id,
      first_name,
      last_name,
      'gabby.njsmart.njask_archive' as table_name
    from
      gabby.njsmart.njask_archive
    union all
    select
      _file,
      _line,
      state_student_id,
      local_student_id,
      first_name,
      last_name,
      'gabby.njsmart.hspa' as table_name
    from
      gabby.njsmart.hspa
    union all
    select
      _file,
      _line,
      state_student_id,
      cast(local_student_id as nvarchar),
      first_name,
      last_name,
      'gabby.njsmart.gepa' as table_name
    from
      gabby.njsmart.gepa
    union all
    select
      _file,
      _line,
      state_student_identifier,
      local_student_identifier,
      first_name,
      coalesce(last_name, last_or_surname) as last_name,
      'gabby.parcc.summative_record_file' as table_name
    from
      gabby.parcc.summative_record_file
  ),
  that as (
    select
      *,
      case
        when max(rn_dupe) over (
          partition by
            _file,
            _line
        ) > 1 then 1
        else 0
      end as is_dupe
    from
      (
        select
          r._file,
          r._line,
          r.state_student_id,
          r.local_student_id,
          r.first_name,
          r.last_name,
          r.table_name,
          sid.student_number as sid_student_number,
          sn.state_studentnumber as sn_state_studentnumber,
          sn.lastfirst as sn_lastfirst,
          row_number() over (
            partition by
              r._file,
              r._line
            order by
              sid._line desc,
              sn._line desc
          ) as rn_dupe
        from
          raw_files r
          left outer join gabby.powerschool.students sid on r.state_student_id = sid.state_studentnumber
          left outer join gabby.powerschool.students sn on r.local_student_id = cast(sn.student_number as nvarchar)
      ) sub
    where
      rn_dupe = 1
      and state_student_id is null
      or local_student_id is null
      or sid_student_number is null
      or sn_state_studentnumber is null
  )
  /* invalid SN
  SELECT *
  ,CASE
  WHEN local_student_id LIKE '7325%' THEN CONCAT('UPDATE ', table_name, ' SET local_student_id = NULL WHERE _file = ''', _file, ''' AND _line = ', _line, ';') 
  WHEN local_student_id LIKE '%.0%' THEN CONCAT('UPDATE ', table_name, ' SET local_student_id = ', REPLACE(local_student_id,'.0',''), ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') 
  END AS update_statement
  FROM raw_files
  WHERE local_student_id LIKE '7325%'
  OR local_student_id LIKE '%.0%'
  --*/
  /* missing SID
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET state_student_id = ', sn_state_studentnumber, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  FROM that
  WHERE is_dupe = 0
  AND state_student_id IS NULL
  AND sn_state_studentnumber IS NOT NULL
  ORDER BY _file, _line
  --*/
  /* missing SN
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET local_student_id = ', sid_student_number, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  ,CONCAT('UPDATE ', table_name, ' SET local_student_id = ', sid_student_number, ' WHERE sid = ', STR(state_student_id), ';') AS no_file_line
  FROM that
  WHERE is_dupe = 0
  AND local_student_id IS NULL
  AND sid_student_number IS NOT NULL
  --*/
  /* mismatch SID
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET state_student_id = ', sn_state_studentnumber, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  FROM that
  WHERE state_student_id IS NOT NULL
  AND sid_student_number IS NULL
  AND sn_state_studentnumber IS NOT NULL
  AND is_dupe = 0
  --*/
  /* mismatched SN
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET local_student_id = ', sid_student_number, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  FROM that
  WHERE is_dupe = 0
  AND local_student_id IS NOT NULL
  AND sn_state_studentnumber IS NULL
  AND sid_student_number IS NOT NULL
  --*/
  /* SN matching on name
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET local_student_id = ', ps_student_number, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  FROM
  (
  SELECT *
  ,MAX(rn) OVER(PARTITION BY _file, _line) AS max_rn
  FROM
  (
  SELECT t.*
  
  ,s.student_number AS ps_student_number
  ,s.state_studentnumber AS ps_state_studentnumber
  ,s.lastfirst AS ps_lastfirst 
  
  ,ROW_NUMBER() OVER(
  PARTITION BY t._file, t._line
  ORDER BY s._line DESC) AS rn
  FROM that t
  JOIN gabby.powerschool.students s
  ON CHARINDEX(LTRIM(RTRIM(REPLACE(t.last_name,' ',''))), gabby.utilities.STRIP_CHARACTERS(REPLACE(s.last_name,' ',''),'^A-Z')) > 0
  AND CHARINDEX(LTRIM(RTRIM(REPLACE(t.first_name, ' ', ''))), gabby.utilities.STRIP_CHARACTERS(REPLACE(s.first_name,' ',''),'^A-Z')) > 0
  WHERE t.local_student_id IS NULL
  ) sub          
  ) sub
  --WHERE max_rn = 1
  --*/
  /* SID matching on name
  SELECT *
  ,CONCAT('UPDATE ', table_name, ' SET state_student_id = ', ps_state_studentnumber, ' WHERE _file = ''', _file, ''' AND _line = ', _line, ';') AS update_statement
  FROM
  (
  SELECT *
  ,MAX(rn) OVER(PARTITION BY _file, _line) AS max_rn
  FROM
  (
  SELECT t.*
  
  ,s.student_number AS ps_student_number
  ,s.state_studentnumber AS ps_state_studentnumber
  ,s.lastfirst AS ps_lastfirst 
  
  ,ROW_NUMBER() OVER(
  PARTITION BY t._file, t._line
  ORDER BY s._line DESC) AS rn
  FROM that t
  JOIN gabby.powerschool.students s
  ON CHARINDEX(LTRIM(RTRIM(REPLACE(t.last_name,' ',''))), gabby.utilities.STRIP_CHARACTERS(REPLACE(s.last_name,' ',''),'^A-Z')) > 0
  AND CHARINDEX(LTRIM(RTRIM(REPLACE(t.first_name, ' ', ''))), gabby.utilities.STRIP_CHARACTERS(REPLACE(s.first_name,' ',''),'^A-Z')) > 0
  WHERE t.state_student_id IS NULL
  AND s.state_studentnumber IS NOT NULL
  ) sub          
  ) sub
  WHERE max_rn = 1  
  --*/
  /* manual
  SELECT *
  ,CONCAT(
  'UPDATE ', table_name, ' '
  'SET local_student_id = ', sid_student_number, ' ',
  'WHERE _file = ''', _file, ''' ',
  'AND _line = ', _line, ';') AS update_statement
  FROM that
  WHERE local_student_id IS NULL
  ORDER BY _file, _line
  --*/
  /* final SN check on njask_archive 
  SELECT n.state_student_id
  ,n.local_student_id
  ,n.first_name
  ,n.last_name
  
  ,s.state_studentnumber
  ,s.lastfirst
  
  ,CONCAT('UPDATE gabby.njsmart.njask_archive SET local_student_id =  WHERE _file = ''', n._file, ''' AND _line = ', n._line, ';') AS update_statement
  FROM gabby.njsmart.njask_archive n
  LEFT OUTER JOIN gabby.powerschool.students s
  ON n.local_student_id = s.student_number
  WHERE s.student_number IS NULL
   */
  /* final SN check on njask
  SELECT n.sid
  ,n.local_student_id
  ,n.first_name
  ,n.last_name
  
  ,sid.student_number
  
  ,sn.state_studentnumber
  ,sn.lastfirst
  FROM gabby.njsmart.njask n
  LEFT OUTER JOIN gabby.powerschool.students sid
  ON n.sid = sid.state_studentnumber
  LEFT OUTER JOIN gabby.powerschool.students sn
  ON n.local_student_id = sn.student_number
  WHERE sn.lastfirst IS NULL
   */
