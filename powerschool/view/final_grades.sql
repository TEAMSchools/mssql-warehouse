CREATE OR ALTER VIEW
  powerschool.final_grades AS
WITH
  enr AS (
    SELECT
      sub.studentid,
      sub.schoolid,
      sub.yearid,
      sub.termid,
      sub.termbin_start_date,
      sub.termbin_end_date,
      sub.course_number,
      sub.gradescaleid,
      sub.gradescaleid_unweighted,
      sub.potential_credit_hours,
      sub.excludefromgpa,
      sub.sectionid,
      sub.is_dropped_section,
      sub.dateleft,
      sub.storecode,
      sub.term_weighted_pts_poss,
      AVG(
        sub.is_dropped_section
      ) OVER (
        PARTITION BY
          sub.yearid,
          sub.course_number,
          sub.studentid
      ) AS is_dropped_course
    FROM
      (
        SELECT
          cc.studentid,
          cc.schoolid,
          cc.dateenrolled,
          cc.dateleft,
          CASE
            WHEN cc.sectionid < 0 THEN 1.0
            ELSE 0.0
          END AS is_dropped_section,
          sec.sectionid,
          sec.course_number,
          sec.termid,
          sec.excludefromgpa,
          sec.courses_gradescaleid AS gradescaleid,
          sec.credit_hours AS potential_credit_hours,
          CASE
            WHEN sec.courses_gradescaleid = 712 THEN 874 /* unweighted 2016-2018 */
            WHEN sec.courses_gradescaleid = 991 THEN 976 /* unweighted 2019+ */
            WHEN sec.courses_gradescaleid IS NULL THEN 874 /* MISSING GRADESCALE - default 2016+ */
            ELSE sec.courses_gradescaleid
          END AS gradescaleid_unweighted,
          tb.yearid,
          tb.storecode,
          tb.date_1 AS termbin_start_date,
          tb.date_2 AS termbin_end_date,
          CAST(
            CASE
              WHEN MIN(tb.storecode) OVER (
                PARTITION BY
                  sec.sectionid
              ) LIKE 'Q%' THEN 25
              WHEN tb.storecode LIKE 'Q%' THEN 22
              WHEN tb.storecode LIKE 'E%' THEN 5
            END AS DECIMAL(4, 0)
          ) AS term_weighted_pts_poss
        FROM
          powerschool.cc
          INNER JOIN powerschool.sections_identifiers AS sec ON ABS(cc.sectionid) = sec.sectionid
          INNER JOIN powerschool.termbins AS tb ON cc.schoolid = tb.schoolid
          AND ABS(cc.termid) = tb.termid
          AND (
            tb.storecode LIKE 'Q%'
            OR tb.storecode LIKE 'E%'
          )
        WHERE
          cc.dateenrolled >= DATEFROMPARTS(
            gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
            7,
            1
          )
      ) AS sub
  ),
  enr_gr AS (
    SELECT
      sub.studentid,
      sub.schoolid,
      sub.yearid,
      sub.termid,
      sub.termbin_start_date,
      sub.termbin_end_date,
      sub.course_number,
      sub.gradescaleid,
      sub.gradescaleid_unweighted,
      sub.fg_potential_credit_hours,
      sub.sg_potential_credit_hours,
      sub.sectionid,
      sub.is_dropped_section,
      sub.storecode,
      sub.fg_letter,
      sub.fg_letter_adj,
      sub.fg_percent,
      sub.fg_percent_adj,
      sub.fg_grade_pts,
      sub.fg_exclude_from_gpa,
      0 AS fg_exclude_from_graduation,
      sub.sg_letter,
      sub.sg_percent,
      sub.sg_grade_pts,
      sub.sg_exclude_from_gpa,
      sub.sg_exclude_from_graduation,
      sub.term_weighted_pts_poss,
      COALESCE(
        sub.sg_potential_credit_hours,
        sub.fg_potential_credit_hours
      ) AS potential_credit_hours,
      COALESCE(
        sub.sg_exclude_from_gpa,
        sub.fg_exclude_from_gpa
      ) AS exclude_from_gpa,
      COALESCE(
        sub.sg_exclude_from_graduation,
        0
      ) AS exclude_from_graduation,
      COALESCE(
        sub.sg_letter,
        sub.fg_letter
      ) AS term_grade_letter,
      COALESCE(
        sub.sg_letter,
        sub.fg_letter_adj
      ) AS term_grade_letter_adj,
      COALESCE(
        sub.sg_percent,
        sub.fg_percent
      ) AS term_grade_percent,
      COALESCE(
        sub.sg_percent,
        sub.fg_percent_adj
      ) AS term_grade_percent_adj,
      COALESCE(
        sub.sg_grade_pts,
        sub.fg_grade_pts
      ) AS term_grade_pts,
      SUM(
        sub.term_weighted_pts_poss
      ) OVER (
        PARTITION BY
          sub.yearid,
          sub.course_number,
          sub.studentid
      ) AS y1_weighted_pts_poss,
      SUM(
        sub.term_weighted_pts_poss
      ) OVER (
        PARTITION BY
          sub.yearid,
          sub.course_number,
          sub.studentid
        ORDER BY
          sub.termbin_end_date ASC
      ) AS y1_weighted_pts_poss_running
    FROM
      (
        SELECT
          te.studentid,
          te.schoolid,
          te.yearid,
          te.termid,
          te.termbin_start_date,
          te.termbin_end_date,
          te.course_number,
          te.gradescaleid,
          te.gradescaleid_unweighted,
          te.sectionid,
          te.is_dropped_section,
          te.storecode,
          te.potential_credit_hours AS fg_potential_credit_hours,
          te.excludefromgpa AS fg_exclude_from_gpa,
          CASE
            WHEN sg.grade IS NULL
            AND fg.grade IS NULL THEN NULL
            WHEN sg.grade IS NOT NULL THEN te.term_weighted_pts_poss
            WHEN fg.grade = '--' THEN NULL
            ELSE te.term_weighted_pts_poss
          END AS term_weighted_pts_poss,
          CASE
            WHEN te.is_dropped_section = 1.0
            AND sg.[percent] IS NULL THEN NULL
            WHEN fg.grade != '--' THEN fg.grade
          END AS fg_letter,
          CAST(
            CASE
              WHEN te.is_dropped_section = 1.0
              AND sg.[percent] IS NULL THEN NULL
              WHEN fg.grade != '--' THEN (
                fg.[percent] / 100.000
              )
            END AS DECIMAL(5, 3)
          ) AS fg_percent,
          CASE
            WHEN te.is_dropped_section = 1.0
            AND sg.[percent] IS NULL THEN NULL
            WHEN fg.grade = '--' THEN NULL
            WHEN fg.[percent] < 50.0 THEN 'F*'
            ELSE fg.grade
          END AS fg_letter_adj,
          CAST(
            CASE
              WHEN te.is_dropped_section = 1
              AND sg.[percent] IS NULL THEN NULL
              WHEN fg.grade = '--' THEN NULL
              WHEN fg.[percent] < 50.0 THEN 0.500
              ELSE (
                fg.[percent] / 100.000
              )
            END AS DECIMAL(5, 3)
          ) AS fg_percent_adj,
          CAST(
            CASE
              WHEN te.is_dropped_section = 1
              AND sg.[percent] IS NULL THEN NULL
              WHEN fg.grade = '--' THEN NULL
              ELSE fgs.grade_points
            END AS DECIMAL(3, 2)
          ) AS fg_grade_pts,
          sg.grade AS sg_letter,
          sg.excludefromgpa AS sg_exclude_from_gpa,
          sg.excludefromgraduation AS sg_exclude_from_graduation,
          CAST(
            sg.[percent] / 100.0 AS DECIMAL(5, 3)
          ) AS sg_percent,
          CAST(
            CASE
              WHEN sg.potentialcrhrs != 0.0 THEN sg.potentialcrhrs
            END AS DECIMAL(5, 2)
          ) AS sg_potential_credit_hours,
          CAST(
            sgs.grade_points AS DECIMAL(3, 2)
          ) AS sg_grade_pts,
          ROW_NUMBER() OVER (
            PARTITION BY
              te.studentid,
              te.yearid,
              te.course_number,
              te.storecode
            ORDER BY
              sg.[percent] DESC,
              te.is_dropped_section ASC,
              te.dateleft DESC,
              te.sectionid DESC
          ) AS rn_enr_fg
        FROM
          enr AS te
          LEFT JOIN powerschool.pgfinalgrades AS fg ON te.studentid = fg.studentid
          AND te.storecode = fg.finalgradename
          AND te.sectionid = fg.sectionid
          LEFT JOIN powerschool.gradescaleitem_lookup_static AS fgs ON te.gradescaleid = fgs.gradescaleid
          AND (
            fg.[percent] BETWEEN fgs.min_cutoffpercentage AND fgs.max_cutoffpercentage
          )
          LEFT JOIN powerschool.storedgrades AS sg ON te.studentid = sg.studentid
          AND te.course_number = sg.course_number
          AND te.storecode = sg.storecode
          AND te.termid = sg.termid
          AND te.sectionid = sg.sectionid
          LEFT JOIN powerschool.gradescaleitem_lookup_static AS sgs ON te.gradescaleid = sgs.gradescaleid
          AND (
            sg.[percent] BETWEEN sgs.min_cutoffpercentage AND sgs.max_cutoffpercentage
          )
        WHERE
          te.is_dropped_course < 1.0
      ) AS sub
    WHERE
      sub.rn_enr_fg = 1
  ),
  y1 AS (
    SELECT
      sub.studentid,
      sub.schoolid,
      sub.yearid,
      sub.termid,
      sub.termbin_start_date,
      sub.termbin_end_date,
      sub.course_number,
      sub.gradescaleid,
      sub.gradescaleid_unweighted,
      sub.sectionid,
      sub.is_dropped_section,
      sub.storecode,
      sub.fg_potential_credit_hours,
      sub.sg_potential_credit_hours,
      sub.potential_credit_hours,
      sub.fg_exclude_from_gpa,
      sub.sg_exclude_from_gpa,
      sub.exclude_from_gpa,
      sub.fg_exclude_from_graduation,
      sub.sg_exclude_from_graduation,
      sub.exclude_from_graduation,
      sub.fg_letter,
      sub.fg_percent,
      sub.fg_letter_adj,
      sub.fg_percent_adj,
      sub.fg_grade_pts,
      sub.sg_letter,
      sub.sg_percent,
      sub.sg_grade_pts,
      sub.term_grade_letter,
      sub.term_grade_letter_adj,
      sub.term_grade_percent,
      sub.term_grade_percent_adj,
      sub.term_grade_pts,
      sub.term_weighted_pts_poss,
      sub.term_weighted_pts_earned,
      sub.term_weighted_pts_earned_adj,
      sub.y1_weighted_pts_poss,
      sub.y1_weighted_pts_poss_running,
      sub.y1_weighted_pts_earned_running,
      sub.y1_weighted_pts_earned_adj_running,
      sub.y1_weighted_pts_earned_running / sub.y1_weighted_pts_poss_running AS y1_grade_percent,
      sub.y1_weighted_pts_earned_adj_running / sub.y1_weighted_pts_poss_running AS y1_grade_percent_adj
    FROM
      (
        SELECT
          eg.studentid,
          eg.schoolid,
          eg.yearid,
          eg.termid,
          eg.termbin_start_date,
          eg.termbin_end_date,
          eg.course_number,
          eg.gradescaleid,
          eg.gradescaleid_unweighted,
          eg.sectionid,
          eg.is_dropped_section,
          eg.storecode,
          eg.fg_potential_credit_hours,
          eg.sg_potential_credit_hours,
          eg.potential_credit_hours,
          eg.fg_exclude_from_gpa,
          eg.sg_exclude_from_gpa,
          eg.exclude_from_gpa,
          eg.fg_exclude_from_graduation,
          eg.sg_exclude_from_graduation,
          eg.exclude_from_graduation,
          eg.fg_letter,
          eg.fg_percent,
          eg.fg_letter_adj,
          eg.fg_percent_adj,
          eg.fg_grade_pts,
          eg.sg_letter,
          eg.sg_percent,
          eg.sg_grade_pts,
          eg.term_grade_letter,
          eg.term_grade_letter_adj,
          eg.term_grade_percent,
          eg.term_grade_percent_adj,
          eg.term_grade_pts,
          eg.term_weighted_pts_poss,
          eg.y1_weighted_pts_poss,
          eg.y1_weighted_pts_poss_running,
          eg.term_grade_percent * eg.term_weighted_pts_poss AS term_weighted_pts_earned,
          eg.term_grade_percent_adj * eg.term_weighted_pts_poss AS term_weighted_pts_earned_adj,
          SUM(
            eg.term_grade_percent * eg.term_weighted_pts_poss
          ) OVER (
            PARTITION BY
              eg.studentid,
              eg.yearid,
              eg.course_number
            ORDER BY
              eg.storecode ASC
          ) AS y1_weighted_pts_earned_running,
          SUM(
            eg.term_grade_percent_adj * eg.term_weighted_pts_poss
          ) OVER (
            PARTITION BY
              eg.studentid,
              eg.yearid,
              eg.course_number
            ORDER BY
              eg.storecode ASC
          ) AS y1_weighted_pts_earned_adj_running
        FROM
          enr_gr AS eg
      ) AS sub
  )
SELECT
  sub.studentid,
  sub.yearid,
  sub.course_number,
  sub.sectionid,
  sub.is_dropped_section,
  sub.storecode,
  sub.termbin_start_date,
  sub.termbin_end_date,
  sub.term_grade_letter,
  sub.term_grade_letter_adj,
  sub.term_grade_pts,
  sub.term_weighted_pts_poss,
  sub.term_weighted_pts_earned,
  sub.term_weighted_pts_earned_adj,
  sub.potential_credit_hours,
  sub.exclude_from_gpa,
  sub.exclude_from_graduation,
  sub.gradescaleid,
  sub.gradescaleid_unweighted,
  sub.fg_potential_credit_hours,
  sub.sg_potential_credit_hours,
  sub.fg_exclude_from_gpa,
  sub.sg_exclude_from_gpa,
  sub.fg_exclude_from_graduation,
  sub.sg_exclude_from_graduation,
  sub.fg_letter,
  sub.sg_letter,
  sub.fg_letter_adj,
  sub.fg_grade_pts,
  sub.sg_grade_pts,
  sub.y1_weighted_pts_poss,
  sub.y1_weighted_pts_poss_running,
  sub.y1_weighted_pts_earned_running,
  sub.fg_percent,
  sub.fg_percent_adj,
  sub.sg_percent,
  sub.term_grade_percent,
  sub.term_grade_percent_adj,
  sub.y1_grade_percent,
  sub.y1_grade_percent_adj,
  sub.need_90,
  sub.need_80,
  sub.need_70,
  sub.need_60,
  y1gs.letter_grade AS y1_grade_letter,
  CAST(
    y1gs.grade_points AS DECIMAL(3, 2)
  ) AS y1_grade_pts,
  CAST(
    y1gsu.grade_points AS DECIMAL(3, 2)
  ) AS y1_grade_pts_unweighted,
  CASE
    WHEN sub.y1_grade_percent < 0.5 THEN 'F*'
    ELSE y1gs.letter_grade
  END AS y1_grade_letter_adj
FROM
  (
    SELECT
      y1.studentid,
      y1.yearid,
      y1.course_number,
      y1.sectionid,
      y1.is_dropped_section,
      y1.storecode,
      y1.termbin_start_date,
      y1.termbin_end_date,
      y1.term_grade_letter,
      y1.term_grade_letter_adj,
      y1.term_grade_pts,
      y1.term_weighted_pts_poss,
      y1.term_weighted_pts_earned,
      y1.term_weighted_pts_earned_adj,
      y1.potential_credit_hours,
      y1.exclude_from_gpa,
      y1.exclude_from_graduation,
      y1.gradescaleid,
      y1.gradescaleid_unweighted,
      y1.fg_potential_credit_hours,
      y1.sg_potential_credit_hours,
      y1.fg_exclude_from_gpa,
      y1.sg_exclude_from_gpa,
      y1.fg_exclude_from_graduation,
      y1.sg_exclude_from_graduation,
      y1.fg_letter,
      y1.sg_letter,
      y1.fg_letter_adj,
      y1.fg_grade_pts,
      y1.sg_grade_pts,
      y1.y1_weighted_pts_poss,
      y1.y1_weighted_pts_poss_running,
      y1.y1_weighted_pts_earned_running,
      CAST(
        ROUND(
          y1.fg_percent * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS fg_percent,
      CAST(
        ROUND(
          y1.fg_percent_adj * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS fg_percent_adj,
      CAST(
        ROUND(
          y1.sg_percent * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS sg_percent,
      CAST(
        ROUND(
          y1.term_grade_percent * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS term_grade_percent,
      CAST(
        ROUND(
          y1.term_grade_percent_adj * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS term_grade_percent_adj,
      CAST(
        ROUND(
          y1.y1_grade_percent * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS y1_grade_percent,
      CAST(
        ROUND(
          y1.y1_grade_percent_adj * 100.0,
          0
        ) AS DECIMAL(4, 0)
      ) AS y1_grade_percent_adj
      /*
      need-to-get calc:
      - target % x y1 points possible to-date
      - minus y1 points earned to-date
      - minus current term points
      - divided by current term weight
       */
,
      CAST(
        (
          (
            y1.y1_weighted_pts_poss_running * 0.9
          ) - (
            ISNULL(
              y1.y1_weighted_pts_earned_running,
              0.0
            ) - ISNULL(
              y1.term_weighted_pts_earned,
              0.0
            )
          )
        ) / (
          y1.term_weighted_pts_poss / 100.0
        ) AS DECIMAL(4, 0)
      ) AS need_90,
      CAST(
        (
          (
            y1.y1_weighted_pts_poss_running * 0.8
          ) - (
            ISNULL(
              y1.y1_weighted_pts_earned_running,
              0.0
            ) - ISNULL(
              y1.term_weighted_pts_earned,
              0.0
            )
          )
        ) / (
          y1.term_weighted_pts_poss / 100.0
        ) AS DECIMAL(4, 0)
      ) AS need_80,
      CAST(
        (
          (
            y1.y1_weighted_pts_poss_running * 0.7
          ) - (
            ISNULL(
              y1.y1_weighted_pts_earned_running,
              0.0
            ) - ISNULL(
              y1.term_weighted_pts_earned,
              0.0
            )
          )
        ) / (
          y1.term_weighted_pts_poss / 100.0
        ) AS DECIMAL(4, 0)
      ) AS need_70,
      CAST(
        (
          (
            y1.y1_weighted_pts_poss_running * 0.6
          ) - (
            ISNULL(
              y1.y1_weighted_pts_earned_running,
              0.0
            ) - ISNULL(
              y1.term_weighted_pts_earned,
              0.0
            )
          )
        ) / (
          y1.term_weighted_pts_poss / 100.0
        ) AS DECIMAL(4, 0)
      ) AS need_60
    FROM
      y1
  ) AS sub
  LEFT JOIN powerschool.gradescaleitem_lookup_static AS y1gs ON sub.gradescaleid = y1gs.gradescaleid
  AND (
    sub.y1_grade_percent BETWEEN y1gs.min_cutoffpercentage AND y1gs.max_cutoffpercentage
  )
  LEFT JOIN powerschool.gradescaleitem_lookup_static AS y1gsu ON sub.gradescaleid_unweighted = y1gsu.gradescaleid
  AND (
    sub.y1_grade_percent BETWEEN y1gsu.min_cutoffpercentage AND y1gsu.max_cutoffpercentage
  )
