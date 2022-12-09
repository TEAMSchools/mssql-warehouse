USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_designations AS
WITH
  ADA AS (
    SELECT
      psa.studentid,
      psa.[db_name],
      psa.yearid,
      ROUND(AVG(CAST(psa.attendancevalue AS FLOAT)), 2) AS ADA
    FROM
      gabby.powerschool.ps_adaadm_daily_ctod_current_static psa
    WHERE
      psa.membershipvalue = 1
      AND psa.calendardate <= CAST(SYSDATETIME() AS DATE)
    GROUP BY
      psa.studentid,
      psa.yearid,
      psa.[db_name]
  ),
  sp AS (
    SELECT
      p.[db_name],
      p.academic_year,
      p.studentid,
      p.enter_date,
      p.exit_date,
      p.[NCCS],
      p.[Americorps],
      p.[Out of District],
      p.[Whittier ES],
      p.[Pathways MS],
      p.[Pathways ES],
      p.[Home Instruction],
      p.[Hybrid - Cohort A],
      p.[Hybrid - Cohort B],
      p.[Remote - Cohort C],
      p.[Hybrid (SC) - Cohort D],
      p.[Remote Instruction],
      p.[Counseling Services]
    FROM
      (
        SELECT
          sp.[db_name],
          sp.academic_year,
          sp.studentid,
          sp.specprog_name,
          sp.enter_date,
          sp.exit_date,
          1 AS n
        FROM
          gabby.powerschool.spenrollments_gen_static sp
        WHERE
          sp.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      ) sub PIVOT (
        MAX(n) FOR specprog_name IN (
          [Pathways ES],
          [Pathways MS],
          [Whittier ES],
          [Out of District],
          [Americorps],
          [NCCS],
          [Home Instruction],
          [Hybrid - Cohort A],
          [Hybrid - Cohort B],
          [Remote - Cohort C],
          [Hybrid (SC) - Cohort D],
          [Remote Instruction],
          [Counseling Services]
        )
      ) p
  ),
  designation AS (
    SELECT
      co.student_number,
      co.academic_year,
      CASE
        WHEN co.iep_status <> 'No IEP' THEN 'IEP'
        ELSE NULL
      END AS is_iep,
      CASE
        WHEN co.c_504_status = 1 THEN '504'
        ELSE NULL
      END AS is_504,
      CASE
        WHEN co.lep_status = 1 THEN 'LEP'
        ELSE NULL
      END AS is_lep,
      CASE
        WHEN gpa.gpa_term >= 3 THEN 'Quarter GPA 3.0+'
        ELSE NULL
      END AS is_quarter_gpa_3plus,
      CASE
        WHEN gpa.gpa_term >= 3.5 THEN 'Quarter GPA 3.5+'
        ELSE NULL
      END AS is_quarter_gpa_35plus,
      CASE
        WHEN sp.[Out of District] IS NOT NULL THEN 'Out-of-District Placement'
        ELSE NULL
      END AS is_ood,
      CASE
        WHEN sp.[NCCS] IS NOT NULL THEN 'NCCS'
        ELSE NULL
      END AS is_nccs,
      CASE
        WHEN sp.[Pathways MS] IS NOT NULL
        OR sp.[Pathways ES] IS NOT NULL THEN 'Pathways'
        ELSE NULL
      END AS is_pathways,
      CASE
        WHEN sp.[Home Instruction] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Home Instruction'
        ELSE NULL
      END AS is_home_instruction,
      CASE
        WHEN sp.[Hybrid - Cohort A] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Hybrid - Cohort A'
        ELSE NULL
      END AS is_hybrid_a,
      CASE
        WHEN sp.[Hybrid - Cohort B] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Hybrid - Cohort B'
        ELSE NULL
      END AS is_hybrid_b,
      CASE
        WHEN sp.[Remote - Cohort C] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Remote - Cohort C'
        ELSE NULL
      END AS is_remote_c,
      CASE
        WHEN sp.[Hybrid (SC) - Cohort D] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Hybrid (SC) - Cohort D'
        ELSE NULL
      END AS is_hybrid_d,
      CASE
        WHEN sp.[Remote Instruction] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Remote Instruction'
        ELSE NULL
      END AS is_remote_instruction,
      CASE
        WHEN sp.[Counseling Services] IS NOT NULL
        AND sp.exit_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Counseling Services'
        ELSE NULL
      END AS is_counseling,
      CASE
        WHEN ADA.ada < 0.9 THEN 'Chronic Absence'
        ELSE NULL
      END AS is_chronic_absentee
    FROM
      gabby.powerschool.cohort_identifiers_static co
      LEFT JOIN gabby.powerschool.gpa_detail gpa ON co.student_number = gpa.student_number
      AND co.academic_year = gpa.academic_year
      AND co.[db_name] = gpa.[db_name]
      AND gpa.is_curterm = 1
      LEFT JOIN sp ON co.studentid = sp.studentid
      AND co.academic_year = sp.academic_year
      AND co.[db_name] = sp.[db_name]
      LEFT JOIN ADA ON co.studentid = ADA.studentid
      AND co.yearid = ADA.yearid
      AND co.[db_name] = ADA.[db_name]
    WHERE
      co.rn_year = 1
      AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  )
SELECT
  student_number,
  academic_year,
  [value] AS designation_name
FROM
  (
    SELECT
      student_number,
      academic_year,
      CAST(is_iep AS NVARCHAR(32)) AS is_iep,
      CAST(is_504 AS NVARCHAR(32)) AS is_504,
      CAST(is_lep AS NVARCHAR(32)) AS is_lep,
      CAST(is_quarter_gpa_3plus AS NVARCHAR(32)) AS is_quarter_gpa_3plus,
      CAST(is_quarter_gpa_35plus AS NVARCHAR(32)) AS is_quarter_gpa_35plus,
      CAST(is_ood AS NVARCHAR(32)) AS is_ood,
      CAST(is_nccs AS NVARCHAR(32)) AS is_nccs,
      CAST(is_pathways AS NVARCHAR(32)) AS is_pathways,
      CAST(is_home_instruction AS NVARCHAR(32)) AS is_home_instruction,
      CAST(is_chronic_absentee AS NVARCHAR(32)) AS is_chronic_absentee,
      CAST(is_hybrid_a AS NVARCHAR(32)) AS is_hybrid_a,
      CAST(is_hybrid_b AS NVARCHAR(32)) AS is_hybrid_b,
      CAST(is_remote_c AS NVARCHAR(32)) AS is_remote_c,
      CAST(is_hybrid_d AS NVARCHAR(32)) AS is_hybrid_d,
      CAST(is_remote_instruction AS NVARCHAR(32)) AS is_remote_instruction,
      CAST(is_counseling AS NVARCHAR(32)) AS is_counseling
    FROM
      designation
  ) sub UNPIVOT (
    [value] FOR field IN (
      is_iep,
      is_504,
      is_lep,
      is_quarter_gpa_3plus,
      is_quarter_gpa_35plus,
      is_ood,
      is_nccs,
      is_pathways,
      is_home_instruction,
      is_chronic_absentee,
      is_hybrid_a,
      is_hybrid_b,
      is_remote_c,
      is_hybrid_d,
      is_remote_instruction,
      is_counseling
    )
  ) u
