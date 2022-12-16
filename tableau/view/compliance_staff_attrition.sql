USE gabby;

GO
CREATE OR ALTER VIEW
  tableau.compliance_staff_attrition AS
WITH
  term AS (
    SELECT
      sub.employee_number,
      sub.position_id,
      sub.status_effective_date,
      sub.termination_reason_description,
      ROW_NUMBER() OVER (
        PARTITION BY
          sub.position_id
        ORDER BY
          sub.status_effective_date DESC
      ) AS rn
    FROM
      (
        SELECT
          t.employee_number,
          t.position_id,
          t.status_effective_date,
          t.status_effective_end_date,
          t.termination_reason_description,
          LAG(t.status_effective_end_date) OVER (
            PARTITION BY
              t.position_id
            ORDER BY
              t.status_effective_date
          ) AS prev_end_date
        FROM
          gabby.people.status_history_static AS t
        WHERE
          t.position_status = 'Terminated'
      ) AS sub
    WHERE
      ISNULL(
        DATEDIFF(
          DAY,
          sub.prev_end_date,
          sub.status_effective_date
        ),
        2
      ) > 1
  ),
  roster AS (
    SELECT
      sub.employee_number,
      sub.position_id,
      sub.preferred_first_name,
      sub.preferred_last_name,
      sub.race_ethnicity_reporting,
      sub.gender_reporting,
      sub.original_hire_date,
      sub.rehire_date,
      sub.position_start_date,
      sub.termination_date,
      sub.status_reason,
      sub.kipp_alumni_status,
      CASE
        WHEN MONTH(sub.position_start_date) >= 9 THEN YEAR(sub.position_start_date)
        WHEN MONTH(sub.position_start_date) < 9 THEN YEAR(sub.position_start_date) - 1
      END AS start_academic_year,
      COALESCE(
        CASE
          WHEN MONTH(sub.termination_date) >= 9 THEN YEAR(sub.termination_date)
          WHEN MONTH(sub.termination_date) < 9 THEN YEAR(sub.termination_date) - 1
        END,
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
      ) AS end_academic_year
    FROM
      (
        SELECT
          r.employee_number,
          r.position_id,
          r.preferred_first_name,
          r.preferred_last_name,
          r.race_ethnicity_reporting,
          r.gender_reporting,
          r.original_hire_date,
          r.rehire_date,
          r.kipp_alumni_status,
          COALESCE(r.rehire_date, r.original_hire_date) AS position_start_date,
          CASE
            WHEN r.position_status != 'Terminated' THEN NULL
            ELSE COALESCE(t.status_effective_date, r.termination_date)
          END AS termination_date,
          COALESCE(
            t.termination_reason_description,
            r.termination_reason
          ) AS status_reason
        FROM
          gabby.people.staff_roster AS r
          LEFT JOIN term AS t /* final termination record */ ON r.position_id = t.position_id
          AND t.rn = 1
      ) AS sub
  ),
  years AS (
    SELECT
      n AS academic_year,
      DATEFROMPARTS((n + 1), 4, 30) AS effective_date
    FROM
      gabby.utilities.row_generator_smallint
    WHERE
      n BETWEEN 2002 AND (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1)
  ),
  scaffold AS (
    SELECT
      sub.employee_number,
      sub.position_id,
      sub.preferred_first_name,
      sub.preferred_last_name,
      sub.race_ethnicity_reporting,
      sub.gender_reporting,
      sub.original_hire_date,
      sub.rehire_date,
      sub.academic_year,
      sub.termination_date,
      sub.status_reason,
      sub.academic_year_entrydate,
      sub.academic_year_exitdate,
      sub.kipp_alumni_status,
      LEAD(sub.academic_year_exitdate, 1) OVER (
        PARTITION BY
          sub.position_id
        ORDER BY
          sub.academic_year
      ) AS academic_year_exitdate_next,
      w.business_unit,
      w.job_title,
      w.[location],
      w.home_department,
      scw.school_level,
      scw.reporting_school_id
    FROM
      (
        SELECT
          r.employee_number,
          r.position_id,
          r.preferred_first_name,
          r.preferred_last_name,
          r.race_ethnicity_reporting,
          r.gender_reporting,
          r.original_hire_date,
          r.rehire_date,
          r.status_reason,
          r.kipp_alumni_status,
          y.academic_year,
          y.effective_date,
          CASE
            WHEN r.end_academic_year = y.academic_year THEN r.termination_date
          END AS termination_date,
          CASE
            WHEN r.start_academic_year = y.academic_year THEN r.position_start_date
            ELSE DATEFROMPARTS(y.academic_year, 7, 1)
          END AS academic_year_entrydate,
          COALESCE(
            CASE
              WHEN r.end_academic_year = y.academic_year THEN r.termination_date
            END,
            DATEFROMPARTS((y.academic_year + 1), 6, 30)
          ) AS academic_year_exitdate
        FROM
          roster AS r
          INNER JOIN years AS y ON y.academic_year (
            BETWEEN r.start_academic_year AND r.end_academic_year
          )
      ) AS sub
      LEFT JOIN gabby.people.employment_history_static AS w ON sub.position_id = w.position_id
      AND sub.effective_date (
        BETWEEN w.effective_start_date AND w.effective_end_date
      )
      LEFT JOIN gabby.people.school_crosswalk AS scw ON w.[location] = scw.site_name
      AND scw._fivetran_deleted = 0
    WHERE
      sub.academic_year_exitdate > sub.academic_year_entrydate
  )
SELECT
  d.employee_number AS df_employee_number,
  d.preferred_first_name,
  d.preferred_last_name,
  d.race_ethnicity_reporting AS primary_ethnicity,
  d.gender_reporting,
  d.academic_year,
  d.academic_year_entrydate,
  d.academic_year_exitdate,
  d.original_hire_date,
  d.rehire_date,
  d.termination_date,
  d.status_reason,
  d.job_title AS primary_job,
  d.home_department AS primary_on_site_department,
  d.[location] AS primary_site,
  d.business_unit AS legal_entity_name,
  d.reporting_school_id AS primary_site_reporting_schoolid,
  d.school_level AS primary_site_school_level,
  d.kipp_alumni_status,
  d.academic_year_exitdate_next AS next_academic_year_exitdate,
  COALESCE(
    d.academic_year_exitdate_next,
    d.termination_date
  ) AS attrition_exitdate,
  CASE
    WHEN DATEDIFF(
      DAY,
      d.academic_year_entrydate,
      d.academic_year_exitdate
    ) <= 0 THEN 0
    WHEN d.academic_year_exitdate >= DATEFROMPARTS(d.academic_year, 9, 1)
    AND d.academic_year_entrydate <= DATEFROMPARTS((d.academic_year + 1), 4, 30) THEN 1
    ELSE 0
  END AS is_denominator,
  CASE
    WHEN COALESCE(
      d.academic_year_exitdate_next,
      d.termination_date
    ) < DATEFROMPARTS((d.academic_year + 1), 9, 1) THEN 1
    ELSE 0
  END AS is_attrition,
  CASE
    WHEN COALESCE(d.rehire_date, d.original_hire_date) > COALESCE(
      d.academic_year_exitdate_next,
      d.termination_date
    ) THEN ROUND(
      DATEDIFF(
        DAY,
        d.original_hire_date,
        COALESCE(
          d.academic_year_exitdate_next,
          d.termination_date
        )
      ) / 365,
      0
    )
    ELSE ROUND(
      DATEDIFF(
        DAY,
        COALESCE(d.rehire_date, d.original_hire_date),
        COALESCE(
          d.academic_year_exitdate_next,
          d.termination_date
        )
      ) / 365,
      0
    )
  END AS years_at_kipp
FROM
  scaffold AS d
