WITH
  ps_scores_long AS (
    SELECT
      unique_id,
      testid,
      student_number,
      read_lvl,
      [status],
      field,
      score
    FROM
      (
        SELECT
          unique_id,
          testid,
          student_number,
          CASE
            WHEN academic_year = 2015
            AND testid = 3273 THEN instruct_lvl
            ELSE read_lvl
          END AS read_lvl,
          ISNULL([status], 'Did Not Achieve') AS [status],
          CAST(name_ass AS VARCHAR) AS name_ass,
          CAST(ltr_nameid AS VARCHAR) AS ltr_nameid,
          CAST(ltr_soundid AS VARCHAR) AS ltr_soundid,
          CAST(pa_rhymingwds AS VARCHAR) AS pa_rhymingwds,
          CAST(pa_mfs AS VARCHAR) AS pa_mfs,
          CAST(pa_segmentation AS VARCHAR) AS pa_segmentation,
          CAST(cp_orient AS VARCHAR) AS cp_orient,
          CAST(cp_121_match AS VARCHAR) AS cp_121match,
          CAST(cp_slw AS VARCHAR) AS cp_slw,
          CAST(devsp_first AS VARCHAR) AS devsp_first,
          CAST(devsp_svs AS VARCHAR) AS devsp_svs,
          CAST(devsp_final AS VARCHAR) AS devsp_final,
          CAST(devsp_ifbd AS VARCHAR) AS devsp_ifbd,
          CAST(devsp_longvowel AS VARCHAR) AS devsp_longvowel,
          CAST(devsp_rcontrol AS VARCHAR) AS devsp_rcontrol,
          CAST(devsp_vowldig AS VARCHAR) AS devsp_vowldig,
          CAST(devsp_cmplxb AS VARCHAR) AS devsp_cmplxb,
          CAST(devsp_eding AS VARCHAR) AS devsp_eding,
          CAST(devsp_doubsylj AS VARCHAR) AS devsp_doubsylj,
          CAST(rr_121_match AS VARCHAR) AS rr_121match,
          CAST(rr_holdspattern AS VARCHAR) AS rr_holdspattern,
          CAST(rr_understanding AS VARCHAR) AS rr_understanding,
          CAST(accuracy_1_a AS VARCHAR) AS accuracy_1a,
          CAST(accuracy_2_b AS VARCHAR) AS accuracy_2b,
          CAST(ra_errors AS VARCHAR) AS ra_errors,
          CAST(cc_factual AS VARCHAR) AS cc_factual,
          CAST(cc_infer AS VARCHAR) AS cc_infer,
          CAST(cc_other AS VARCHAR) AS cc_other,
          CAST(cc_ct AS VARCHAR) AS cc_ct,
          CAST(ocomp_factual AS VARCHAR) AS ocomp_factual,
          CAST(ocomp_ct AS VARCHAR) AS ocomp_ct,
          CAST(ocomp_infer AS VARCHAR) AS ocomp_infer,
          CAST(scomp_factual AS VARCHAR) AS scomp_factual,
          CAST(scomp_infer AS VARCHAR) AS scomp_infer,
          CAST(scomp_ct AS VARCHAR) AS scomp_ct,
          CAST(wcomp_fact AS VARCHAR) AS wcomp_fact,
          CAST(wcomp_infer AS VARCHAR) AS wcomp_infer,
          CAST(wcomp_ct AS VARCHAR) AS wcomp_ct,
          CAST(retelling AS VARCHAR) AS retelling,
          CAST(
            CASE
              WHEN testid = 3397
              AND reading_rate IN ('Above', 'Target') THEN 30
              WHEN testid IN (3411, 3425)
              AND reading_rate IN ('Above', 'Target') THEN 40
              WHEN testid IN (3442, 3458, 3474)
              AND reading_rate IN ('Above', 'Target') THEN 50
              WHEN testid IN (3493, 3511, 3527)
              AND reading_rate IN ('Above', 'Target') THEN 75
            END AS VARCHAR
          ) AS reading_rate,
          CAST(fluency AS VARCHAR) AS fluency,
          CAST(ROUND(fp_wpmrate, 0) AS VARCHAR) AS fp_wpmrate,
          CAST(fp_fluency AS VARCHAR) AS fp_fluency,
          CAST(fp_accuracy AS VARCHAR) AS fp_accuracy,
          CAST(fp_comp_within AS VARCHAR) AS fp_comp_within,
          CAST(fp_comp_beyond AS VARCHAR) AS fp_comp_beyond,
          CAST(fp_comp_about AS VARCHAR) AS fp_comp_about,
          CAST(cc_prof AS VARCHAR) AS cc_prof,
          CAST(ocomp_prof AS VARCHAR) AS ocomp_prof,
          CAST(scomp_prof AS VARCHAR) AS scomp_prof,
          CAST(wcomp_prof AS VARCHAR) AS wcomp_prof,
          CAST(fp_comp_prof AS VARCHAR) AS fp_comp_prof,
          CAST(cp_prof AS VARCHAR) AS cp_prof,
          CAST(rr_prof AS VARCHAR) AS rr_prof,
          CAST(devsp_prof AS VARCHAR) AS devsp_prof
        FROM
          gabby.lit.powerschool_readingscores_archive
      ) AS sub UNPIVOT (
        score FOR field IN (
          name_ass,
          ltr_nameid,
          ltr_soundid,
          pa_rhymingwds,
          pa_mfs,
          pa_segmentation,
          cp_orient,
          cp_121match,
          cp_slw,
          devsp_first,
          devsp_svs,
          devsp_final,
          devsp_ifbd,
          devsp_longvowel,
          devsp_rcontrol,
          devsp_vowldig,
          devsp_cmplxb,
          devsp_eding,
          devsp_doubsylj,
          rr_121match,
          rr_holdspattern,
          rr_understanding,
          accuracy_1a,
          accuracy_2b,
          ra_errors,
          cc_factual,
          cc_infer,
          cc_other,
          cc_ct,
          ocomp_factual,
          ocomp_ct,
          ocomp_infer,
          scomp_factual,
          scomp_infer,
          scomp_ct,
          wcomp_fact,
          wcomp_infer,
          wcomp_ct,
          retelling,
          reading_rate,
          fluency,
          fp_wpmrate,
          fp_fluency,
          fp_accuracy,
          fp_comp_within,
          fp_comp_beyond,
          fp_comp_about,
          cc_prof,
          ocomp_prof,
          scomp_prof,
          wcomp_prof,
          fp_comp_prof,
          cp_prof,
          rr_prof,
          devsp_prof
        )
      ) AS unpiv
  )
SELECT
  rs.unique_id,
  rs.student_number,
  rs.testid,
  rs.status,
  rs.field,
  rs.score,
  gleq.read_lvl,
  CASE
    WHEN rs.testid = 3273 THEN gleq.fp_lvl_num
    WHEN rs.testid != 3273 THEN gleq.lvl_num
  END AS lvl_num
FROM
  ps_scores_long AS rs
  LEFT OUTER JOIN gabby.lit.gleq ON (
    rs.testid = gleq.testid
    AND rs.read_lvl = gleq.read_lvl
  )
WHERE
  rs.testid = 3273
