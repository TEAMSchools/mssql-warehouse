CREATE OR ALTER VIEW
  tableau.school_tactical_dashboard AS
WITH
  roster AS (
    SELECT
      student_number,
      studentid,
      academic_year,
      yearid,
      region,
      school_level,
      CAST(
        reporting_schoolid AS VARCHAR(25)
      ) AS reporting_schoolid,
      CAST(grade_level AS VARCHAR(5)) AS grade_level,
      iep_status,
      lunchstatus,
      exitdate,
      enroll_status,
      [db_name]
    FROM
      gabby.powerschool.cohort_identifiers_static
    WHERE
      academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND rn_year = 1
      AND grade_level != 99
  ),
  demographics AS (
    SELECT
      academic_year,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      field,
      [value]
    FROM
      (
        SELECT
          academic_year,
          ISNULL(region, 'All') AS region,
          ISNULL(school_level, 'All') AS school_level,
          ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
          ISNULL(grade_level, 'All') AS grade_level,
          AVG(CAST(is_fr_lunch AS FLOAT)) AS pct_fr_lunch,
          SUM(CAST(is_attrition_week AS FLOAT)) AS n_attrition_week
        FROM
          (
            SELECT
              academic_year,
              region,
              school_level,
              reporting_schoolid,
              grade_level,
              CASE
                WHEN lunchstatus IN ('F', 'R') THEN 1.0
                ELSE 0.0
              END AS is_fr_lunch,
              CASE
                WHEN (
                  exitdate BETWEEN DATEADD(
                    DAY,
                    1 - (DATEPART(WEEKDAY, SYSDATETIME())),
                    CAST(SYSDATETIME() AS DATE)
                  ) /* week start date */ AND DATEADD(
                    DAY,
                    7 - (DATEPART(WEEKDAY, SYSDATETIME())),
                    CAST(SYSDATETIME() AS DATE)
                  )
                ) /* week end date */ THEN 1.0
                ELSE 0.0
              END AS is_attrition_week
            FROM
              roster
          ) AS sub
        GROUP BY
          academic_year,
          ROLLUP (region, reporting_schoolid),
          CUBE (school_level, grade_level)
      ) AS sub UNPIVOT (
        [value] FOR field IN (pct_fr_lunch, n_attrition_week)
      ) AS u
  ),
  modules AS (
    SELECT
      academic_year,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      subject_area,
      module_number,
      field,
      [value]
    FROM
      (
        SELECT
          academic_year,
          subject_area,
          module_number,
          ISNULL(region, 'All') AS region,
          ISNULL(school_level, 'All') AS school_level,
          ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
          ISNULL(grade_level, 'All') AS grade_level,
          AVG(is_target) AS pct_target,
          AVG(is_approaching) AS pct_approaching,
          AVG(is_below) AS pct_below,
          AVG(is_target_iep) AS pct_target_iep,
          AVG(is_approaching_iep) AS pct_approaching_iep,
          AVG(is_below_iep) AS pct_below_iep
        FROM
          (
            SELECT
              r.student_number,
              r.academic_year,
              r.region,
              r.school_level,
              r.reporting_schoolid,
              r.grade_level,
              a.subject_area,
              a.module_number,
              CASE
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number >= 4 THEN 1.0
                ELSE 0.0
              END AS is_target,
              CASE
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number = 3 THEN 1.0
                ELSE 0.0
              END AS is_approaching,
              CASE
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number <= 2 THEN 1.0
                ELSE 0.0
              END AS is_below,
              CASE
                WHEN r.iep_status = 'No IEP' THEN NULL
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number >= 4 THEN 1.0
                ELSE 0.0
              END AS is_target_iep,
              CASE
                WHEN r.iep_status = 'No IEP' THEN NULL
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number = 3 THEN 1.0
                ELSE 0.0
              END AS is_approaching_iep,
              CASE
                WHEN r.iep_status = 'No IEP' THEN NULL
                WHEN a.performance_band_number IS NULL THEN NULL
                WHEN a.performance_band_number <= 2 THEN 1.0
                ELSE 0.0
              END AS is_below_iep
            FROM
              roster AS r
              INNER JOIN illuminate_dna_assessments.agg_student_responses_all AS a ON (
                r.student_number = local_student_id
                AND r.academic_year = a.academic_year
                AND a.response_type = 'O'
                AND a.is_replacement = 0
                AND a.module_type IN ('QA', 'CRQ')
                AND a.module_number IS NOT NULL
              )
          ) AS sub
        GROUP BY
          academic_year,
          subject_area,
          module_number,
          ROLLUP (region, reporting_schoolid),
          CUBE (school_level, grade_level)
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          pct_target,
          pct_approaching,
          pct_below,
          pct_target_iep,
          pct_approaching_iep,
          pct_below_iep
        )
      ) AS u
  ),
  /*
  -- parcc AS (
  --   SELECT
  --     academic_year,
  --     region,
  --     school_level,
  --     reporting_schoolid,
  --     grade_level,
  --     [subject],
  --     field,
  --     [value]
  --   FROM
  --     (
  --       SELECT
  --         academic_year,
  --         [subject],
  --         ISNULL(region, 'All') AS region,
  --         ISNULL(school_level, 'All') AS school_level,
  --         ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
  --         ISNULL(grade_level, 'All') AS grade_level,
  --         AVG(is_target) AS pct_target,
  --         AVG(is_approaching) AS pct_approaching,
  --         AVG(is_below) AS pct_below,
  --         AVG(is_target_iep) AS pct_target_iep,
  --         AVG(is_approaching_iep) AS pct_approaching_iep,
  --         AVG(is_below_iep) AS pct_below_iep
  --       FROM
  --         (
  --           SELECT
  --             r.student_number,
  --             r.academic_year,
  --             r.region,
  --             r.school_level,
  --             r.reporting_schoolid,
  --             r.grade_level,
  --             p.[subject],
  --             CASE
  --               WHEN p.test_performance_level >= 4 THEN 1.0
  --               ELSE 0.0
  --             END AS is_target,
  --             CASE
  --               WHEN p.test_performance_level = 3 THEN 1.0
  --               ELSE 0.0
  --             END AS is_approaching,
  --             CASE
  --               WHEN p.test_performance_level <= 2 THEN 1.0
  --               ELSE 0.0
  --             END AS is_below,
  --             CASE
  --               WHEN r.iep_status = 'No IEP' THEN NULL
  --               WHEN p.test_performance_level >= 4 THEN 1.0
  --               ELSE 0.0
  --             END AS is_target_iep,
  --             CASE
  --               WHEN r.iep_status = 'No IEP' THEN NULL
  --               WHEN p.test_performance_level = 3 THEN 1.0
  --               ELSE 0.0
  --             END AS is_approaching_iep,
  --             CASE
  --               WHEN r.iep_status = 'No IEP' THEN NULL
  --               WHEN p.test_performance_level <= 2 THEN 1.0
  --               ELSE 0.0
  --             END AS is_below_iep
  --           FROM
  --             roster AS r
  --             INNER JOIN gabby.parcc.summative_record_file_clean AS p ON (
  --               r.student_number = p.local_student_identifier
  --               AND r.academic_year = p.academic_year
  --             )
  --         ) AS sub
  --       GROUP BY
  --         academic_year,
  --         [subject],
  --         ROLLUP (region, reporting_schoolid),
  --         CUBE (school_level, grade_level)
  --     ) AS sub UNPIVOT (
  --       [value] FOR field IN (
  --         pct_target,
  --         pct_approaching,
  --         pct_below,
  --         pct_target_iep,
  --         pct_approaching_iep,
  --         pct_below_iep
  --       )
  --     ) AS u
  -- ),
  --*/
  student_attendance AS (
    SELECT
      r.student_number,
      r.academic_year,
      r.region,
      r.school_level,
      r.reporting_schoolid,
      r.grade_level,
      r.iep_status,
      r.enroll_status,
      SUM(
        CAST([ada].membershipvalue AS FLOAT)
      ) AS n_membership,
      SUM(
        CAST([ada].attendancevalue AS FLOAT)
      ) AS n_present,
      SUM(
        CASE
          WHEN (
            [ada].calendardate BETWEEN
            /* week start date */
            DATEADD(
              DAY,
              1 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            ) AND
            /* week end date */
            DATEADD(
              DAY,
              7 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            )
          ) THEN CAST([ada].membershipvalue AS FLOAT)
        END
      ) AS n_membership_week,
      SUM(
        CASE
          WHEN (
            [ada].calendardate BETWEEN
            /* week start date */
            DATEADD(
              DAY,
              1 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            ) AND
            /* week end date */
            DATEADD(
              DAY,
              7 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            )
          ) THEN CAST([ada].attendancevalue AS FLOAT)
        END
      ) AS n_present_week,
      SUM(
        CAST(
          CASE
            WHEN att.att_code IN ('T', 'T10') THEN 1
            ELSE 0
          END AS FLOAT
        )
      ) AS n_tardy,
      CAST(
        CASE
          WHEN SUM(
            CASE
              WHEN att.att_code = 'ISS' THEN 1
            END
          ) > 0 THEN 1
          ELSE 0
        END AS FLOAT
      ) AS is_iss,
      CAST(
        CASE
          WHEN SUM(
            CASE
              WHEN att.att_code = 'OSS' THEN 1
            END
          ) > 0 THEN 1
          ELSE 0
        END AS FLOAT
      ) AS is_oss,
      SUM(
        CASE
          WHEN (
            [ada].calendardate BETWEEN
            /* week start date */
            DATEADD(
              DAY,
              1 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            ) AND
            /* week end date */
            DATEADD(
              DAY,
              7 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            )
          ) THEN CAST(
            CASE
              WHEN att.att_code IN ('T', 'T10') THEN 1
              ELSE 0
            END AS FLOAT
          )
        END
      ) AS n_tardy_week,
      SUM(
        CASE
          WHEN (
            [ada].calendardate BETWEEN
            /* week start date */
            DATEADD(
              DAY,
              1 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            ) AND
            /* week end date */
            DATEADD(
              DAY,
              7 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            )
          ) THEN CAST(
            CASE
              WHEN att.att_code = 'ISS' THEN 1
              ELSE 0
            END AS FLOAT
          )
        END
      ) AS is_iss_week,
      SUM(
        CASE
          WHEN (
            [ada].calendardate BETWEEN
            /* week start date */
            DATEADD(
              DAY,
              1 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            ) AND
            /* week end date */
            DATEADD(
              DAY,
              7 - (DATEPART(WEEKDAY, SYSDATETIME())),
              CAST(SYSDATETIME() AS DATE)
            )
          ) THEN CAST(
            CASE
              WHEN att.att_code = 'OSS' THEN 1
              ELSE 0
            END AS FLOAT
          )
        END
      ) AS is_oss_week,
      CAST(
        CASE
          WHEN r.iep_status = 'No IEP' THEN NULL
          WHEN SUM(
            CASE
              WHEN att.att_code = 'ISS' THEN 1
            END
          ) > 0 THEN 1
          ELSE 0
        END AS FLOAT
      ) AS is_iss_iep,
      CAST(
        CASE
          WHEN r.iep_status = 'No IEP' THEN NULL
          WHEN SUM(
            CASE
              WHEN att.att_code = 'OSS' THEN 1
            END
          ) > 0 THEN 1
          ELSE 0
        END AS FLOAT
      ) AS is_oss_iep
    FROM
      roster AS r
      INNER JOIN gabby.powerschool.ps_adaadm_daily_ctod_current_static AS [ada] ON (
        r.studentid = [ada].studentid
        AND r.yearid = [ada].yearid
        AND r.[db_name] = [ada].[db_name]
        AND [ada].membershipvalue = 1
        AND [ada].calendardate < CAST(SYSDATETIME() AS DATE)
      )
      LEFT JOIN gabby.powerschool.ps_attendance_daily_current_static AS att ON (
        r.studentid = att.studentid
        AND r.[db_name] = att.[db_name]
        AND [ada].calendardate = att.att_date
      )
    GROUP BY
      r.student_number,
      r.academic_year,
      r.region,
      r.school_level,
      r.reporting_schoolid,
      r.grade_level,
      r.iep_status,
      r.enroll_status
  ),
  student_attendance_rollup AS (
    SELECT
      academic_year,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      field,
      [value]
    FROM
      (
        SELECT
          academic_year,
          ISNULL(region, 'All') AS region,
          ISNULL(school_level, 'All') AS school_level,
          ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
          ISNULL(grade_level, 'All') AS grade_level,
          SUM(n_present) / SUM(n_membership) AS pct_ada,
          (SUM(n_present) - SUM(n_tardy)) / SUM(n_membership) AS pct_ontime,
          AVG(is_iss) AS pct_iss,
          AVG(is_oss) AS pct_oss,
          AVG(is_iss_iep) AS pct_iss_iep,
          AVG(is_oss_iep) AS pct_oss_iep,
          SUM(n_present_week) / SUM(n_membership_week) AS pct_ada_week,
          (
            SUM(n_present_week) - SUM(n_tardy_week)
          ) / SUM(n_membership_week) AS pct_ontime_week,
          CAST(
            COUNT(
              DISTINCT CASE
                WHEN is_iss_week >= 1 THEN student_number
              END
            ) AS FLOAT
          ) AS n_iss_week,
          CAST(
            COUNT(
              DISTINCT CASE
                WHEN is_oss_week >= 1 THEN student_number
              END
            ) AS FLOAT
          ) AS n_oss_week
        FROM
          student_attendance AS sub
        GROUP BY
          academic_year,
          ROLLUP (region, reporting_schoolid),
          CUBE (school_level, grade_level)
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          pct_ada,
          pct_ontime,
          pct_iss,
          pct_oss,
          pct_iss_iep,
          pct_oss_iep,
          pct_ada_week,
          pct_ontime_week,
          n_iss_week,
          n_oss_week
        )
      ) AS u
  ),
  chronic_absentee AS (
    SELECT
      academic_year,
      ISNULL(region, 'All') AS region,
      ISNULL(school_level, 'All') AS school_level,
      ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
      ISNULL(grade_level, 'All') AS grade_level,
      'pct_chronic_absentee' AS field,
      AVG(is_chronic_absentee) AS [value]
    FROM
      (
        SELECT
          student_number,
          academic_year,
          region,
          school_level,
          reporting_schoolid,
          grade_level,
          CAST(
            CASE
              WHEN (n_present / n_membership) < 0.895 THEN 1
              ELSE 0
            END AS FLOAT
          ) AS is_chronic_absentee
        FROM
          student_attendance
        WHERE
          enroll_status = 0
      ) AS sub
    GROUP BY
      academic_year,
      ROLLUP (region, reporting_schoolid),
      CUBE (school_level, grade_level)
  ),
  /*
  -- staff_attrition AS (
  --   SELECT
  --     academic_year,
  --     region,
  --     school_level,
  --     reporting_schoolid,
  --     grade_level,
  --     field,
  --     [value]
  --   FROM
  --     (
  --       SELECT
  --         academic_year,
  --         ISNULL(region, 'All') AS region,
  --         ISNULL(school_level, 'All') AS school_level,
  --         ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
  --         'All' AS grade_level,
  --         AVG(is_attrition) AS pct_attrition,
  --         AVG(is_attrition_resignation) AS pct_attrition_resignation,
  --         AVG(is_attrition_termination) AS pct_attrition_termination
  --       FROM
  --         (
  --           SELECT
  --             df_employee_number,
  --             academic_year,
  --             CASE
  --               WHEN legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
  --               WHEN legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
  --               WHEN legal_entity_name = 'KIPP Miami' THEN 'KMS'
  --             END AS region,
  --             primary_site_school_level AS school_level,
  --             CAST(
  --               primary_site_reporting_schoolid AS VARCHAR(25)
  --             ) AS reporting_schoolid,
  --             NULL AS grade_level,
  --             CAST(is_attrition AS FLOAT) AS is_attrition,
  --             CAST(
  --               CASE
  --                 WHEN status_reason = 'Resignation' THEN 1.0
  --                 ELSE 0.0
  --               END AS FLOAT
  --             ) AS is_attrition_resignation,
  --             CAST(
  --               CASE
  --                 WHEN status_reason = 'Termination' THEN 1.0
  --                 ELSE 0.0
  --               END AS FLOAT
  --             ) AS is_attrition_termination
  --           FROM
  --             gabby.tableau.compliance_staff_attrition
  --           WHERE
  --             is_denominator = 1
  --             AND primary_site_reporting_schoolid != 0
  --             AND legal_entity_name != 'KIPP New Jersey'
  --             AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  --         ) AS sub
  --       GROUP BY
  --         academic_year,
  --         ROLLUP (region, reporting_schoolid),
  --         CUBE (school_level)
  --     ) AS sub UNPIVOT (
  --       VALUE FOR field IN (
  --         pct_attrition,
  --         pct_attrition_resignation,
  --         pct_attrition_termination
  --       )
  --     ) AS u
  -- ),
  --*/
  student_attrition AS (
    SELECT
      academic_year,
      ISNULL(region, 'All') AS region,
      ISNULL(school_level, 'All') AS school_level,
      ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
      ISNULL(grade_level, 'All') AS grade_level,
      'pct_attrition' AS field,
      AVG(is_attrition) AS [value]
    FROM
      (
        SELECT
          y1.student_number,
          y1.academic_year,
          y1.region,
          CAST(y1.school_level AS VARCHAR(5)) AS school_level,
          CAST(
            y1.reporting_schoolid AS VARCHAR(25)
          ) AS reporting_schoolid,
          CAST(y1.grade_level AS VARCHAR(5)) AS grade_level,
          CASE
          /* graduates != attrition */
            WHEN y1.exitcode = 'G1' THEN 0.0
            /* handles re-enrollments during the year */
            WHEN (
              s.exitdate >= y1.exitdate
              AND s.exitdate >= CAST(SYSDATETIME() AS DATE)
            ) THEN 0.0
            /* was not enrolled on 10/1 next year */
            WHEN (
              y1.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
              AND y1.exitdate <= SYSDATETIME()
              AND y2.entrydate IS NULL
            ) THEN 1.0
            /* left after 10/1 this year */
            WHEN (
              y1.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
              AND s.exitdate <= SYSDATETIME()
            ) THEN 1.0
            ELSE 0.0
          END AS is_attrition
        FROM
          gabby.powerschool.cohort_identifiers_static AS y1
          LEFT JOIN gabby.powerschool.students AS s ON (
            y1.student_number = s.student_number
            AND y1.[db_name] = s.[db_name]
          )
          LEFT JOIN gabby.powerschool.cohort_identifiers_static AS y2 ON (
            y1.student_number = y2.student_number
            AND y1.[db_name] = y2.[db_name]
            AND y1.academic_year = (y2.academic_year - 1)
            AND (
              DATEFROMPARTS(y2.academic_year, 10, 01) BETWEEN y2.entrydate AND y2.exitdate
            )
          )
        WHERE
          (
            DATEFROMPARTS(y1.academic_year, 10, 01) BETWEEN y1.entrydate AND y1.exitdate
          )
      ) AS sub
    GROUP BY
      academic_year,
      ROLLUP (region, reporting_schoolid),
      CUBE (school_level, grade_level)
  ),
  gpa AS (
    SELECT
      academic_year,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      field,
      [value]
    FROM
      (
        SELECT
          academic_year,
          ISNULL(region, 'All') AS region,
          ISNULL(school_level, 'All') AS school_level,
          ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
          ISNULL(grade_level, 'All') AS grade_level,
          AVG(gpa_ge_3) AS pct_gpa_ge_3,
          AVG(gpa_ge_2) AS pct_gpa_ge_2
        FROM
          (
            SELECT
              r.student_number,
              r.academic_year,
              r.region,
              r.school_level,
              r.reporting_schoolid,
              r.grade_level,
              CASE
                WHEN gpa.gpa_y1 >= 3.0 THEN 1.0
                ELSE 0.0
              END AS gpa_ge_3,
              CASE
                WHEN gpa.gpa_y1 >= 2.0 THEN 1.0
                ELSE 0.0
              END AS gpa_ge_2
            FROM
              roster AS r
              INNER JOIN gabby.powerschool.gpa_detail AS gpa ON (
                r.student_number = gpa.student_number
                AND r.academic_year = gpa.academic_year
                AND r.reporting_schoolid = gpa.schoolid
                AND r.[db_name] = gpa.[db_name]
                AND gpa.is_curterm = 1
              )
          ) AS sub
        GROUP BY
          academic_year,
          ROLLUP (region, reporting_schoolid),
          CUBE (school_level, grade_level)
      ) AS sub UNPIVOT (
        [value] FOR field IN (pct_gpa_ge_3, pct_gpa_ge_2)
      ) AS u
  ),
  lit AS (
    SELECT
      academic_year,
      reporting_term,
      region,
      school_level,
      reporting_schoolid,
      grade_level,
      field,
      [value]
    FROM
      (
        SELECT
          academic_year,
          reporting_term,
          ISNULL(region, 'All') AS region,
          ISNULL(school_level, 'All') AS school_level,
          ISNULL(reporting_schoolid, 'All') AS reporting_schoolid,
          ISNULL(grade_level, 'All') AS grade_level,
          AVG(is_on_gradelevel) AS pct_on_gradelevel,
          AVG(moved_reading_level) AS pct_moved_reading_level
        FROM
          (
            SELECT
              r.student_number,
              r.academic_year,
              r.region,
              r.school_level,
              r.reporting_schoolid,
              r.grade_level,
              achv.reporting_term,
              CAST(achv.met_goal AS FLOAT) AS is_on_gradelevel,
              CASE
                WHEN achv.reporting_term = 'LIT1' THEN NULL
                ELSE CAST(achv.moved_levels AS FLOAT)
              END AS moved_reading_level
            FROM
              roster AS r
              INNER JOIN gabby.lit.achieved_by_round_static AS achv ON (
                r.student_number = achv.student_number
                AND r.academic_year = achv.academic_year
                AND achv.achv_unique_id LIKE 'FPBAS%'
                AND achv.[start_date] <= SYSDATETIME()
              )
          ) AS sub
        GROUP BY
          academic_year,
          reporting_term,
          ROLLUP (region, reporting_schoolid),
          CUBE (school_level, grade_level)
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          pct_on_gradelevel,
          pct_moved_reading_level
        )
      ) AS u
  ),
  so_survey AS (
    SELECT
      academic_year,
      reporting_term,
      ISNULL(subject_legal_entity_name, 'All') AS region,
      ISNULL(
        subject_primary_site_school_level,
        'All'
      ) AS school_level,
      ISNULL(
        subject_primary_site_schoolid,
        'All'
      ) AS reporting_schoolid,
      'All' AS grade_level,
      'avg_survey_weighted_response_value' AS field,
      AVG(
        avg_survey_weighted_response_value
      ) AS [value]
    FROM
      (
        SELECT
          academic_year,
          reporting_term,
          subject_legal_entity_name AS subject_legal_entity_name,
          subject_primary_site_school_level,
          CAST(
            subject_primary_site_schoolid AS VARCHAR
          ) AS subject_primary_site_schoolid,
          subject_username,
          SUM(total_weighted_response_value) / SUM(total_response_weight) AS avg_survey_weighted_response_value
        FROM
          gabby.surveys.self_and_others_survey_rollup_static
        WHERE
          subject_primary_site_school_level IS NOT NULL
        GROUP BY
          academic_year,
          reporting_term,
          subject_legal_entity_name,
          subject_primary_site_school_level,
          subject_primary_site_schoolid,
          subject_username
      ) AS sub
    GROUP BY
      academic_year,
      reporting_term,
      ROLLUP (
        subject_legal_entity_name,
        subject_primary_site_schoolid
      ),
      CUBE (
        subject_primary_site_school_level
      )
  ),
  manager_survey AS (
    SELECT
      academic_year,
      reporting_term,
      ISNULL(subject_legal_entity_name, 'All') AS region,
      ISNULL(
        subject_primary_site_school_level,
        'All'
      ) AS school_level,
      ISNULL(
        subject_primary_site_schoolid,
        'All'
      ) AS reporting_schoolid,
      'All' AS grade_level,
      'avg_survey_response_value' AS field,
      AVG(avg_survey_response_value) AS [value]
    FROM
      (
        SELECT
          academic_year,
          reporting_term,
          subject_legal_entity_name AS subject_legal_entity_name,
          subject_primary_site_school_level,
          CAST(
            subject_primary_site_schoolid AS VARCHAR
          ) AS subject_primary_site_schoolid,
          subject_username,
          AVG(avg_response_value) AS avg_survey_response_value
        FROM
          gabby.surveys.manager_survey_rollup
        WHERE
          subject_primary_site_school_level IS NOT NULL
        GROUP BY
          academic_year,
          reporting_term,
          subject_legal_entity_name,
          subject_primary_site_school_level,
          subject_primary_site_schoolid,
          subject_username
      ) AS sub
    GROUP BY
      academic_year,
      reporting_term,
      ROLLUP (
        subject_legal_entity_name,
        subject_primary_site_schoolid
      ),
      CUBE (
        subject_primary_site_school_level
      )
  )
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  'Y1' AS term_name,
  'Student Enrollment' AS [domain],
  'Demographics' AS subdomain,
  field,
  [value]
FROM
  demographics
UNION ALL
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  subject_area,
  module_number AS term_name,
  'Assessments' AS [domain],
  'Internal Assessments' AS subdomain,
  field,
  [value]
FROM
  modules
UNION ALL
/*
-- SELECT
--   academic_year,
--   region,
--   school_level,
--   reporting_schoolid,
--   grade_level,
--   [subject] AS subject_area,
--   'Y1' AS term_name,
--   'Assessments' AS [domain],
--   'PARCC' AS subdomain,
--   field,
--   [value]
-- FROM
--   parcc
-- UNION ALL
--*/
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  'Y1' AS term_name,
  CASE
    WHEN field IN (
      'pct_iss',
      'pct_oss',
      'pct_iss_iep',
      'pct_oss_iep'
    ) THEN 'Student Culture'
    ELSE 'Student Attendance'
  END AS [domain],
  NULL AS subdomain,
  field,
  [value]
FROM
  student_attendance_rollup
UNION ALL
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  'Y1' AS term_name,
  'Student Attendance' AS [domain],
  NULL AS subdomain,
  field,
  [value]
FROM
  chronic_absentee
UNION ALL
/*
-- SELECT
--   academic_year,
--   region,
--   school_level,
--   reporting_schoolid,
--   grade_level,
--   NULL AS subject_area,
--   'Y1' AS term_name,
--   'Staff Attrition' AS [domain],
--   NULL AS subdomain,
--   field,
--   [value]
-- FROM
--   staff_attrition
-- UNION ALL
--*/
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  'Y1' AS term_name,
  'Student Attrition' AS [domain],
  NULL AS subdomain,
  field,
  [value]
FROM
  student_attrition
UNION ALL
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  'Y1' AS term_name,
  'Grades' AS [domain],
  'GPA' AS subdomain,
  field,
  [value]
FROM
  gpa
UNION ALL
/*
-- SELECT
--   academic_year,
--   region,
--   school_level,
--   reporting_schoolid,
--   grade_level,
--   NULL AS subject_area,
--   'Y1' AS term_name,
--   'Staff Attendance' AS [domain],
--   NULL AS subdomain,
--   field,
--   [value]
-- FROM
--   staff_attendance
-- UNION ALL
--*/
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  reporting_term AS term_name,
  'Literacy' AS [domain],
  NULL AS subdomain,
  field,
  [value]
FROM
  lit
UNION ALL
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  reporting_term AS term_name,
  'Surveys' AS [domain],
  'Self & Others' AS subdomain,
  field,
  [value]
FROM
  so_survey
UNION ALL
SELECT
  academic_year,
  region,
  school_level,
  reporting_schoolid,
  grade_level,
  NULL AS subject_area,
  reporting_term AS term_name,
  'Surveys' AS [domain],
  'Manager' AS subdomain,
  field,
  [value]
FROM
  manager_survey
