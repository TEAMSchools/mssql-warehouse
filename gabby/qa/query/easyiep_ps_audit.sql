WITH
  ps AS (
    SELECT
      s.student_number,
      s.state_studentnumber,
      s.lastfirst,
      s.enroll_status,
      s.schoolid,
      s.grade_level,
      s.[db_name],
      scf.spedlep
    FROM
      powerschool.students AS s
      LEFT JOIN powerschool.studentcorefields AS scf ON (
        s.dcid = scf.studentsdcid
        AND s.[db_name] = scf.[db_name]
      )
    WHERE
      s.entrydate >= '2021-07-01'
      AND s.grade_level != 99
      AND s.[db_name] != 'kippmiami'
  ),
  iep AS (
    SELECT
      student_number,
      state_studentnumber,
      spedlep,
      special_education,
      special_education_code
    FROM
      easyiep.stg_njsmart_powerschool
    WHERE
      academic_year = 2021
  )
SELECT
  ps_sn,
  ps_lastfirst,
  enroll_status,
  schoolid,
  grade_level,
  [db_name],
  ps_spedlep,
  iep_sn,
  iep_spedlep,
  special_education,
  special_education_code,
  CASE
    WHEN ps_sn IS NULL THEN 'In EasyIEP; Missing from PS'
    WHEN (
      ps_spedlep != 'No IEP'
      AND iep_sn IS NULL
    ) THEN 'In PS; Missing from EasyIEP export'
    WHEN ps_spedlep != iep_spedlep THEN 'Conflicting SPEDLEP'
    ELSE 'Match'
  END AS audit_result
FROM
  (
    SELECT
      ps.student_number AS ps_sn,
      ps.lastfirst AS ps_lastfirst,
      ps.enroll_status,
      ps.schoolid,
      ps.grade_level,
      ps.[db_name],
      ISNULL(ps.spedlep, 'No IEP') AS ps_spedlep,
      iep.student_number AS iep_sn,
      ISNULL(iep.spedlep, 'No IEP') AS iep_spedlep,
      iep.special_education,
      iep.special_education_code
    FROM
      ps
      FULL JOIN iep ON (
        ps.student_number = iep.student_number
      )
  ) AS sub
