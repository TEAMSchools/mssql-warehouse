CREATE OR ALTER VIEW
  powerschool.cohort AS
WITH
  enr_union AS (
    /* terminal (current & transfers) */
    SELECT
      s.id AS studentid,
      s.dcid AS studentsdcid,
      s.student_number,
      s.grade_level,
      s.schoolid,
      s.entrydate,
      s.exitdate,
      s.entrycode,
      s.exitcode,
      s.exitcomment,
      s.lunchstatus,
      s.fteid,
      s.track,
      terms.yearid,
      x1.exit_code AS exit_code_kf,
      x2.exit_code AS exit_code_ts
    FROM
      powerschool.students AS s
      INNER JOIN powerschool.terms AS terms ON (
        s.schoolid = terms.schoolid
        AND (
          s.entrydate BETWEEN terms.firstday AND terms.lastday
        )
        AND terms.isyearrec = 1
      )
      LEFT JOIN powerschool.u_clg_et_stu_clean_static AS x1 ON (
        s.dcid = x1.studentsdcid
        AND s.exitdate = x1.exit_date
      )
      LEFT JOIN powerschool.u_clg_et_stu_alt_clean_static AS x2 ON (
        s.dcid = x2.studentsdcid
        AND s.exitdate = x2.exit_date
      )
    WHERE
      s.enroll_status IN (-1, 0, 2)
      AND s.exitdate > s.entrydate
    UNION ALL
    /* terminal (grads) */
    SELECT
      s.id AS studentid,
      s.dcid AS studentsdcid,
      s.student_number,
      s.grade_level,
      s.schoolid,
      NULL AS entrydate,
      NULL AS exitdate,
      NULL AS entrycode,
      NULL AS exitcode,
      NULL AS exitcomment,
      NULL AS lunchstatus,
      NULL AS fteid,
      NULL AS track,
      terms.yearid,
      NULL AS exit_code_kf,
      NULL AS exit_code_ts
    FROM
      powerschool.students AS s
      INNER JOIN powerschool.terms AS terms ON (
        s.schoolid = terms.schoolid
        AND s.entrydate <= terms.firstday
        AND terms.isyearrec = 1
      )
    WHERE
      s.enroll_status = 3
    UNION ALL
    /* re-enrollments */
    SELECT
      re.studentid AS studentid,
      s.dcid AS studentsdcid,
      s.student_number,
      re.grade_level,
      re.schoolid,
      re.entrydate,
      re.exitdate,
      re.entrycode,
      re.exitcode,
      re.exitcomment,
      re.lunchstatus,
      re.fteid,
      re.track,
      terms.yearid,
      x1.exit_code AS exit_code_kf,
      x2.exit_code AS exit_code_ts
    FROM
      powerschool.reenrollments AS re
      INNER JOIN powerschool.students AS s ON (re.studentid = s.id)
      INNER JOIN powerschool.terms AS terms ON (
        re.schoolid = terms.schoolid
        AND (
          re.entrydate BETWEEN terms.firstday AND terms.lastday
        )
        AND terms.isyearrec = 1
      )
      LEFT JOIN powerschool.u_clg_et_stu_clean_static AS x1 ON (
        s.dcid = x1.studentsdcid
        AND re.exitdate = x1.exit_date
      )
      LEFT JOIN powerschool.u_clg_et_stu_alt_clean_static AS x2 ON (
        s.dcid = x2.studentsdcid
        AND re.exitdate = x2.exit_date
      )
    WHERE
      re.schoolid != 12345 /* filter out summer school */
      AND re.exitdate > re.entrydate
  ),
  enr_order AS (
    SELECT
      studentid,
      studentsdcid,
      student_number,
      schoolid,
      grade_level,
      entrydate,
      exitdate,
      exit_code_kf,
      exit_code_ts,
      exitcomment,
      lunchstatus,
      fteid,
      yearid,
      (yearid + 1990) AS academic_year,
      CASE
        WHEN entrycode = '' THEN NULL
        ELSE entrycode
      END AS entrycode,
      CASE
        WHEN exitcode = '' THEN NULL
        ELSE exitcode
      END AS exitcode,
      CASE
        WHEN track = '' THEN NULL
        ELSE track
      END AS track,
      LAG(yearid, 1) OVER (
        PARTITION BY
          studentid
        ORDER BY
          yearid ASC
      ) AS prev_yearid,
      LAG(grade_level, 1) OVER (
        PARTITION BY
          studentid
        ORDER BY
          yearid ASC
      ) AS prev_grade_level,
      ROW_NUMBER() OVER (
        PARTITION BY
          studentid,
          yearid
        ORDER BY
          yearid DESC,
          exitdate DESC
      ) AS rn_year,
      ROW_NUMBER() OVER (
        PARTITION BY
          studentid,
          schoolid
        ORDER BY
          yearid DESC,
          exitdate DESC
      ) AS rn_school,
      ROW_NUMBER() OVER (
        PARTITION BY
          studentid,
          CASE
            WHEN grade_level = 99 THEN 1
            ELSE 0
          END
        ORDER BY
          yearid DESC,
          exitdate DESC
      ) AS rn_undergrad,
      ROW_NUMBER() OVER (
        PARTITION BY
          studentid
        ORDER BY
          yearid DESC,
          exitdate DESC
      ) AS rn_all
    FROM
      enr_union
  )
SELECT
  studentid,
  studentsdcid,
  student_number,
  schoolid,
  grade_level,
  entrydate,
  exitdate,
  entrycode,
  exitcode,
  exit_code_kf,
  exit_code_ts,
  exitcomment,
  CASE
    WHEN lunchstatus IN ('', 'NoD', '1', '2') THEN NULL
    ELSE lunchstatus
  END AS lunchstatus,
  fteid,
  ISNULL(track, 'A') AS track,
  yearid,
  academic_year,
  rn_year,
  rn_school,
  CASE
    WHEN grade_level != 99 THEN rn_undergrad
  END AS rn_undergrad,
  rn_all,
  prev_grade_level,
  is_retained_year,
  MAX(is_retained_year) OVER (
    PARTITION BY
      studentid
  ) AS is_retained_ever,
  MAX(year_in_network) OVER (
    PARTITION BY
      studentid,
      academic_year
  ) AS year_in_network,
  MAX(year_in_school) OVER (
    PARTITION BY
      studentid,
      academic_year
  ) AS year_in_school,
  MIN(
    CASE
      WHEN year_in_network = 1 THEN schoolid
    END
  ) OVER (
    PARTITION BY
      studentid
  ) AS entry_schoolid,
  MIN(
    CASE
      WHEN year_in_network = 1 THEN grade_level
    END
  ) OVER (
    PARTITION BY
      studentid
  ) AS entry_grade_level,
  CASE
    WHEN DB_NAME() = 'kippcamden' THEN 'KCNA'
    WHEN DB_NAME() = 'kippnewark' THEN 'TEAM'
    WHEN DB_NAME() = 'kippmiami' THEN 'KMS'
  END AS region,
  CASE
    WHEN grade_level = 99 THEN MAX(
      CASE
        WHEN exitcode = 'G1' THEN yearid + 2003 + (-1 * grade_level)
      END
    ) OVER (
      PARTITION BY
        studentid
    )
    WHEN grade_level >= 9 THEN MAX(
      CASE
        WHEN year_in_school = 1 THEN yearid + 2003 + (-1 * grade_level)
      END
    ) OVER (
      PARTITION BY
        studentid,
        schoolid
    )
    ELSE yearid + 2003 + (-1 * grade_level)
  END AS cohort,
  CASE
    WHEN grade_level = 99 THEN 'Graduated'
    WHEN MAX(year_in_network) OVER (
      PARTITION BY
        studentid,
        academic_year
    ) = 1 THEN 'New'
    WHEN prev_grade_level IS NULL THEN 'New'
    WHEN prev_grade_level < grade_level THEN 'Promoted'
    WHEN prev_grade_level = grade_level THEN 'Retained'
    WHEN prev_grade_level > grade_level THEN 'Demoted'
  END AS boy_status,
  CASE
    WHEN academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR () THEN NULL
    WHEN exitcode = 'G1' THEN 'Graduated'
    /* this is wrong or N/A */
    --WHEN exitcode LIKE 'T%' THEN 'Transferred'
    --WHEN prev_grade_level < grade_level THEN 'Promoted'
    --WHEN prev_grade_level = grade_level THEN 'Retained'
    --WHEN prev_grade_level > grade_level THEN 'Demoted'
  END AS eoy_status
FROM
  (
    SELECT
      studentid,
      studentsdcid,
      student_number,
      schoolid,
      grade_level,
      entrydate,
      exitdate,
      entrycode,
      exitcode,
      exit_code_kf,
      exit_code_ts,
      exitcomment,
      fteid,
      track,
      yearid,
      academic_year,
      rn_year,
      rn_school,
      rn_all,
      lunchstatus,
      rn_undergrad,
      CASE
        WHEN rn_year > 1 THEN NULL
        ELSE ROW_NUMBER() OVER (
          PARTITION BY
            studentid,
            schoolid,
            rn_year
          ORDER BY
            yearid ASC,
            exitdate ASC
        )
      END AS year_in_school,
      CASE
        WHEN rn_year > 1 THEN NULL
        ELSE ROW_NUMBER() OVER (
          PARTITION BY
            studentid,
            rn_year
          ORDER BY
            yearid ASC,
            exitdate ASC
        )
      END AS year_in_network,
      MIN(prev_grade_level) OVER (
        PARTITION BY
          studentid,
          yearid
        ORDER BY
          yearid ASC
      ) AS prev_grade_level,
      CASE
        WHEN yearid = MIN(prev_yearid) OVER (
          PARTITION BY
            studentid,
            yearid
          ORDER BY
            yearid ASC
        ) THEN 0
        WHEN (
          grade_level != 99
          AND grade_level <= MIN(prev_grade_level) OVER (
            PARTITION BY
              studentid,
              yearid
            ORDER BY
              yearid ASC
          )
        ) THEN 1
        ELSE 0
      END AS is_retained_year
    FROM
      enr_order
  ) AS sub
