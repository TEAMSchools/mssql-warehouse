CREATE OR ALTER VIEW
  payroll.payroll_audit_scaffold AS
WITH
  payroll_rollup AS (
    SELECT
      file_nbr,
      dept,
      cost_nbr,
      SUBSTRING(_file, 9, 4) AS fiscal_year,
      SUBSTRING(_file, 14, 2) AS payroll_week,
      SUBSTRING(_file, 17, 1) AS payroll_run,
      SUBSTRING(_file, 19, 3) AS company_code,
      CASE
        WHEN CHARINDEX('PREV', _file) > 0 THEN SUBSTRING(_file, 34, 4)
        ELSE 'Final'
      END AS preview_or_final,
      CASE
        WHEN CHARINDEX('PREV', _file) > 0 THEN CAST(SUBSTRING(_file, 39, 1) AS INT)
      END AS preview_number,
      CAST(SUBSTRING(_file, 23, 10) AS DATE) AS payroll_date,
      CONCAT(
        SUBSTRING(_file, 19, 3),
        file_nbr
      ) AS position_id,
      gabby.dbo.GROUP_CONCAT (DISTINCT fli_code) AS fli_code,
      gabby.dbo.GROUP_CONCAT (DISTINCT rt) AS rt,
      gabby.dbo.GROUP_CONCAT (DISTINCT state_cd_1) AS state_cd_1,
      gabby.dbo.GROUP_CONCAT (DISTINCT state_cd_2) AS state_cd_2,
      gabby.dbo.GROUP_CONCAT (DISTINCT sui_sdi_code) AS sui_sdi_code,
      gabby.dbo.GROUP_CONCAT (DISTINCT void_ind) AS void_ind,
      SUM(ded_cd_3) AS ded_cd_3,
      SUM(ded_cd_4) AS ded_cd_4,
      SUM(ded_cd_403) AS ded_cd_403,
      SUM(ded_cd_73) AS ded_cd_73,
      SUM(ded_cd_74) AS ded_cd_74,
      SUM(ded_cd_75) AS ded_cd_75,
      SUM(ded_cd_76) AS ded_cd_76,
      SUM(ded_cd_acc) AS ded_cd_acc,
      SUM(ded_cd_add) AS ded_cd_add,
      SUM(ded_cd_bcp) AS ded_cd_bcp,
      SUM(ded_cd_bct) AS ded_cd_bct,
      SUM(ded_cd_c) AS ded_cd_c,
      SUM(ded_cd_ck_1) AS ded_cd_ck_1,
      SUM(ded_cd_ck_2) AS ded_cd_ck_2,
      SUM(ded_cd_ck_3) AS ded_cd_ck_3,
      SUM(ded_cd_ck_4) AS ded_cd_ck_4,
      SUM(ded_cd_sv_1) AS ded_cd_sv_1,
      SUM(ded_cd_sv_2) AS ded_cd_sv_2,
      SUM(ded_cd_sv_3) AS ded_cd_sv_3,
      SUM(ded_cd_sv_4) AS ded_cd_sv_4,
      SUM(ded_cd_den) AS ded_cd_den,
      SUM(ded_cd_dfs) AS ded_cd_dfs,
      SUM(ded_cd_e) AS ded_cd_e,
      SUM(ded_cd_ed) AS ded_cd_ed,
      SUM(ded_cd_em) AS ded_cd_em,
      SUM(ded_cd_ev) AS ded_cd_ev,
      SUM(ded_cd_hos) AS ded_cd_hos,
      SUM(ded_cd_hsa) AS ded_cd_hsa,
      SUM(ded_cd_i) AS ded_cd_i,
      SUM(ded_cd_j) AS ded_cd_j,
      SUM(ded_cd_k) AS ded_cd_k,
      SUM(ded_cd_l) AS ded_cd_l,
      SUM(ded_cd_ln_1) AS ded_cd_ln_1,
      SUM(ded_cd_ln_2) AS ded_cd_ln_2,
      SUM(ded_cd_med) AS ded_cd_med,
      SUM(ded_cd_mfs) AS ded_cd_mfs,
      SUM(ded_cd_p) AS ded_cd_p,
      SUM(ded_cd_psc) AS ded_cd_psc,
      SUM(ded_cd_q) AS ded_cd_q,
      SUM(ded_cd_trn) AS ded_cd_trn,
      SUM(ded_cd_ver) AS ded_cd_ver,
      SUM(ded_cd_vis) AS ded_cd_vis,
      SUM(ern_3_bon) AS ern_3_bon,
      SUM(ern_3_ds) AS ern_3_ds,
      SUM(ern_3_ecl) AS ern_3_ecl,
      SUM(ern_3_glc) AS ern_3_glc,
      SUM(ern_3_hwb) AS ern_3_hwb,
      SUM(ern_3_lp) AS ern_3_lp,
      SUM(ern_3_oob) AS ern_3_oob,
      SUM(ern_3_ret) AS ern_3_ret,
      SUM(ern_4_ac) AS ern_4_ac,
      SUM(ern_4_ba) AS ern_4_ba,
      SUM(ern_4_bon) AS ern_4_bon,
      SUM(ern_4_db) AS ern_4_db,
      SUM(ern_4_dc) AS ern_4_dc,
      SUM(ern_4_dei) AS ern_4_dei,
      SUM(ern_4_ds) AS ern_4_ds,
      SUM(ern_4_ecl) AS ern_4_ecl,
      SUM(ern_4_emh) AS ern_4_emh,
      SUM(ern_4_epc) AS ern_4_epc,
      SUM(ern_4_hb) AS ern_4_hb,
      SUM(ern_4_glc) AS ern_4_glc,
      SUM(ern_4_ic) AS ern_4_ic,
      SUM(ern_4_lp) AS ern_4_lp,
      SUM(ern_4_ntp) AS ern_4_ntp,
      SUM(ern_4_oob) AS ern_4_oob,
      SUM(ern_4_ret) AS ern_4_ret,
      SUM(ern_4_trs) AS ern_4_trs,
      SUM(ern_5_ret) AS ern_5_ret,
      SUM(fed_tax) AS fed_tax,
      SUM(fli_amount) AS fli_amount,
      SUM(gross) AS gross,
      SUM(hrs_4_bev) AS hrs_4_bev,
      SUM(hrs_4_cvd) AS hrs_4_cvd,
      SUM(hrs_4_prd) AS hrs_4_prd,
      SUM(hrs_4_pto) AS hrs_4_pto,
      SUM(hrs_4_rel) AS hrs_4_rel,
      SUM(hrs_4_sic) AS hrs_4_sic,
      SUM(local_cd_1) AS local_cd_1,
      SUM(local_cd_2) AS local_cd_2,
      SUM(local_tax_1) AS local_tax_1,
      SUM(local_tax_2) AS local_tax_2,
      SUM(med_surtax) AS med_surtax,
      SUM(med_tax) AS med_tax,
      SUM(net_pay) AS net_pay,
      SUM(ot_ern) AS ot_ern,
      SUM(ot_hrs) AS ot_hrs,
      SUM(rate) AS rate,
      SUM(rate_2) AS rate_2,
      SUM(rate_3) AS rate_3,
      SUM(rate_used) AS rate_used,
      SUM(rg_ern) AS rg_ern,
      SUM(rg_hrs) AS rg_hrs,
      SUM(sdi_tax) AS sdi_tax,
      SUM(ss_tax) AS ss_tax,
      SUM(state_tax_1) AS state_tax_1,
      SUM(state_tax_2) AS state_tax_2,
      SUM(sui_tax) AS sui_tax,
      SUM(ern_3_hb) AS ern_3_hb,
      SUM(ern_4_sev) AS ern_4_sev,
      SUM(ded_cd_mis) AS ded_cd_mis,
      SUM(ern_4_sic) AS ern_4_sic,
      SUM(memo_cd_b_input) AS memo_cd_b_input,
      SUM(ern_3_rlb) AS ern_3_rlb,
      SUM(ded_cd_rpe) AS ded_cd_rpe,
      SUM(memo_cd_epn_calc) AS memo_cd_epn_calc,
      SUM(hrs_4_jd) AS hrs_4_jd,
      SUM(ern_4_awa) AS ern_4_awa,
      SUM(hrs_4_awa) AS hrs_4_awa,
      SUM(hrs_4_ret) AS hrs_4_ret,
      SUM(ern_3_dc) AS ern_3_dc,
      SUM(memo_cd_epn_input) AS memo_cd_epn_input,
      SUM(ded_cd_71) AS ded_cd_71,
      SUM(ern_5_bp) AS ern_5_bp,
      SUM(ern_4_bp) AS ern_4_bp,
      SUM(ern_4_ssc) AS ern_4_ssc,
      SUM(1) AS n_records,
      SUM(
        /* trunk-ignore(sqlfluff/L016) */
        COALESCE(ded_cd_ck_1, 0) + COALESCE(ded_cd_ck_2, 0) + COALESCE(ded_cd_ck_3, 0) + COALESCE(ded_cd_ck_4, 0) + COALESCE(ded_cd_sv_1, 0) + COALESCE(ded_cd_sv_2, 0) + COALESCE(ded_cd_sv_3, 0) + COALESCE(ded_cd_sv_4, 0) + COALESCE(net_pay, 0) -- noqa: L016
      ) AS take_home_pay
    FROM
      gabby.adp.payroll_register
    GROUP BY
      _file,
      file_nbr,
      dept,
      cost_nbr
  ),
  payroll_unpivot AS (
    SELECT
      position_id,
      company_code,
      file_nbr,
      fiscal_year,
      payroll_week,
      payroll_run,
      payroll_date,
      preview_or_final,
      preview_number,
      dept,
      cost_nbr,
      fli_code,
      rt,
      state_cd_1,
      state_cd_2,
      sui_sdi_code,
      void_ind,
      code,
      code_value,
      CASE
        WHEN preview_or_final = 'Final' THEN MAX(payroll_date) OVER (
          PARTITION BY
            company_code,
            file_nbr,
            preview_or_final
        )
      END AS max_final_payroll_date
    FROM
      (
        SELECT
          position_id,
          company_code,
          file_nbr,
          fiscal_year,
          payroll_week,
          preview_or_final,
          preview_number,
          payroll_run,
          payroll_date,
          dept,
          cost_nbr,
          fli_code,
          rt,
          state_cd_1,
          state_cd_2,
          sui_sdi_code,
          void_ind,
          CAST(fed_tax AS FLOAT) AS fed_tax,
          CAST(gross AS FLOAT) AS gross,
          CAST(net_pay AS FLOAT) AS net_pay,
          CAST(take_home_pay AS FLOAT) AS take_home_pay,
          CAST(ded_cd_3 AS FLOAT) AS ded_cd_3,
          CAST(ded_cd_4 AS FLOAT) AS ded_cd_4,
          CAST(ded_cd_403 AS FLOAT) AS ded_cd_403,
          CAST(ded_cd_73 AS FLOAT) AS ded_cd_73,
          CAST(ded_cd_74 AS FLOAT) AS ded_cd_74,
          CAST(ded_cd_75 AS FLOAT) AS ded_cd_75,
          CAST(ded_cd_76 AS FLOAT) AS ded_cd_76,
          CAST(ded_cd_acc AS FLOAT) AS ded_cd_acc,
          CAST(ded_cd_add AS FLOAT) AS ded_cd_add,
          CAST(ded_cd_bcp AS FLOAT) AS ded_cd_bcp,
          CAST(ded_cd_bct AS FLOAT) AS ded_cd_bct,
          CAST(ded_cd_c AS FLOAT) AS ded_cd_c,
          CAST(ded_cd_den AS FLOAT) AS ded_cd_den,
          CAST(ded_cd_dfs AS FLOAT) AS ded_cd_dfs,
          CAST(ded_cd_e AS FLOAT) AS ded_cd_e,
          CAST(ded_cd_ed AS FLOAT) AS ded_cd_ed,
          CAST(ded_cd_em AS FLOAT) AS ded_cd_em,
          CAST(ded_cd_ev AS FLOAT) AS ded_cd_ev,
          CAST(ded_cd_hos AS FLOAT) AS ded_cd_hos,
          CAST(ded_cd_hsa AS FLOAT) AS ded_cd_hsa,
          CAST(ded_cd_i AS FLOAT) AS ded_cd_i,
          CAST(ded_cd_j AS FLOAT) AS ded_cd_j,
          CAST(ded_cd_k AS FLOAT) AS ded_cd_k,
          CAST(ded_cd_l AS FLOAT) AS ded_cd_l,
          CAST(ded_cd_ln_1 AS FLOAT) AS ded_cd_ln_1,
          CAST(ded_cd_ln_2 AS FLOAT) AS ded_cd_ln_2,
          CAST(ded_cd_med AS FLOAT) AS ded_cd_med,
          CAST(ded_cd_mfs AS FLOAT) AS ded_cd_mfs,
          CAST(ded_cd_p AS FLOAT) AS ded_cd_p,
          CAST(ded_cd_psc AS FLOAT) AS ded_cd_psc,
          CAST(ded_cd_q AS FLOAT) AS ded_cd_q,
          CAST(ded_cd_trn AS FLOAT) AS ded_cd_trn,
          CAST(ded_cd_ver AS FLOAT) AS ded_cd_ver,
          CAST(ded_cd_vis AS FLOAT) AS ded_cd_vis,
          CAST(ern_3_bon AS FLOAT) AS ern_3_bon,
          CAST(ern_3_ds AS FLOAT) AS ern_3_ds,
          CAST(ern_3_ecl AS FLOAT) AS ern_3_ecl,
          CAST(ern_3_glc AS FLOAT) AS ern_3_glc,
          CAST(ern_3_hwb AS FLOAT) AS ern_3_hwb,
          CAST(ern_3_lp AS FLOAT) AS ern_3_lp,
          CAST(ern_3_oob AS FLOAT) AS ern_3_oob,
          CAST(ern_3_ret AS FLOAT) AS ern_3_ret,
          CAST(ern_4_ac AS FLOAT) AS ern_4_ac,
          CAST(ern_4_ba AS FLOAT) AS ern_4_ba,
          CAST(ern_4_bon AS FLOAT) AS ern_4_bon,
          CAST(ern_4_db AS FLOAT) AS ern_4_db,
          CAST(ern_4_dc AS FLOAT) AS ern_4_dc,
          CAST(ern_4_dei AS FLOAT) AS ern_4_dei,
          CAST(ern_4_ds AS FLOAT) AS ern_4_ds,
          CAST(ern_4_ecl AS FLOAT) AS ern_4_ecl,
          CAST(ern_4_emh AS FLOAT) AS ern_4_emh,
          CAST(ern_4_epc AS FLOAT) AS ern_4_epc,
          CAST(ern_4_glc AS FLOAT) AS ern_4_glc,
          CAST(ern_4_hb AS FLOAT) AS ern_4_hb,
          CAST(ern_4_ic AS FLOAT) AS ern_4_ic,
          CAST(ern_4_lp AS FLOAT) AS ern_4_lp,
          CAST(ern_4_ntp AS FLOAT) AS ern_4_ntp,
          CAST(ern_4_oob AS FLOAT) AS ern_4_oob,
          CAST(ern_4_ret AS FLOAT) AS ern_4_ret,
          CAST(ern_4_trs AS FLOAT) AS ern_4_trs,
          CAST(ern_5_ret AS FLOAT) AS ern_5_ret,
          CAST(fli_amount AS FLOAT) AS fli_amount,
          CAST(hrs_4_bev AS FLOAT) AS hrs_4_bev,
          CAST(hrs_4_cvd AS FLOAT) AS hrs_4_cvd,
          CAST(hrs_4_prd AS FLOAT) AS hrs_4_prd,
          CAST(hrs_4_pto AS FLOAT) AS hrs_4_pto,
          CAST(hrs_4_rel AS FLOAT) AS hrs_4_rel,
          CAST(hrs_4_sic AS FLOAT) AS hrs_4_sic,
          CAST(local_cd_1 AS FLOAT) AS local_cd_1,
          CAST(local_cd_2 AS FLOAT) AS local_cd_2,
          CAST(local_tax_1 AS FLOAT) AS local_tax_1,
          CAST(local_tax_2 AS FLOAT) AS local_tax_2,
          CAST(med_surtax AS FLOAT) AS med_surtax,
          CAST(med_tax AS FLOAT) AS med_tax,
          CAST(ot_ern AS FLOAT) AS ot_ern,
          CAST(ot_hrs AS FLOAT) AS ot_hrs,
          CAST(rate AS FLOAT) AS rate,
          CAST(rate_2 AS FLOAT) AS rate_2,
          CAST(rate_3 AS FLOAT) AS rate_3,
          CAST(rate_used AS FLOAT) AS rate_used,
          CAST(rg_ern AS FLOAT) AS rg_ern,
          CAST(rg_hrs AS FLOAT) AS rg_hrs,
          CAST(sdi_tax AS FLOAT) AS sdi_tax,
          CAST(ss_tax AS FLOAT) AS ss_tax,
          CAST(state_tax_1 AS FLOAT) AS state_tax_1,
          CAST(state_tax_2 AS FLOAT) AS state_tax_2,
          CAST(sui_tax AS FLOAT) AS sui_tax,
          CAST(ern_3_hb AS FLOAT) AS ern_3_hb,
          CAST(ern_4_sev AS FLOAT) AS ern_4_sev,
          CAST(ded_cd_mis AS FLOAT) AS ded_cd_mis,
          CAST(ern_4_sic AS FLOAT) AS ern_4_sic,
          CAST(memo_cd_b_input AS FLOAT) AS memo_cd_b_input,
          CAST(ern_3_rlb AS FLOAT) AS ern_3_rlb,
          CAST(ded_cd_rpe AS FLOAT) AS ded_cd_rpe,
          CAST(memo_cd_epn_calc AS FLOAT) AS memo_cd_epn_calc,
          CAST(hrs_4_jd AS FLOAT) AS hrs_4_jd,
          CAST(ern_4_awa AS FLOAT) AS ern_4_awa,
          CAST(hrs_4_awa AS FLOAT) AS hrs_4_awa,
          CAST(hrs_4_ret AS FLOAT) AS hrs_4_ret,
          CAST(ern_3_dc AS FLOAT) AS ern_3_dc,
          CAST(memo_cd_epn_input AS FLOAT) AS memo_cd_epn_input,
          CAST(ded_cd_71 AS FLOAT) AS ded_cd_71,
          CAST(ern_5_bp AS FLOAT) AS ern_5_bp,
          CAST(ern_4_bp AS FLOAT) AS ern_4_bp,
          CAST(ern_4_ssc AS FLOAT) AS ern_4_ssc,
          CAST(n_records AS FLOAT) AS n_records
        FROM
          payroll_rollup
      ) AS sub UNPIVOT (
        code_value FOR code IN (
          ded_cd_3,
          ded_cd_4,
          ded_cd_403,
          ded_cd_73,
          ded_cd_74,
          ded_cd_75,
          ded_cd_76,
          ded_cd_acc,
          ded_cd_add,
          ded_cd_bcp,
          ded_cd_bct,
          ded_cd_c,
          ded_cd_den,
          ded_cd_dfs,
          ded_cd_e,
          ded_cd_ed,
          ded_cd_em,
          ded_cd_ev,
          ded_cd_hos,
          ded_cd_hsa,
          ded_cd_i,
          ded_cd_j,
          ded_cd_k,
          ded_cd_l,
          ded_cd_ln_1,
          ded_cd_ln_2,
          ded_cd_med,
          ded_cd_mfs,
          ded_cd_p,
          ded_cd_psc,
          ded_cd_q,
          ded_cd_trn,
          ded_cd_ver,
          ded_cd_vis,
          ern_3_bon,
          ern_3_ds,
          ern_3_ecl,
          ern_3_glc,
          ern_3_hwb,
          ern_3_lp,
          ern_3_oob,
          ern_3_ret,
          ern_4_ac,
          ern_4_ba,
          ern_4_bon,
          ern_4_db,
          ern_4_dc,
          ern_4_dei,
          ern_4_ds,
          ern_4_ecl,
          ern_4_emh,
          ern_4_epc,
          ern_4_glc,
          ern_4_hb,
          ern_4_ic,
          ern_4_lp,
          ern_4_ntp,
          ern_4_oob,
          ern_4_ret,
          ern_4_trs,
          ern_5_ret,
          fed_tax,
          fli_amount,
          gross,
          hrs_4_bev,
          hrs_4_cvd,
          hrs_4_prd,
          hrs_4_pto,
          hrs_4_rel,
          hrs_4_sic,
          local_cd_1,
          local_cd_2,
          local_tax_1,
          local_tax_2,
          med_surtax,
          med_tax,
          net_pay,
          ot_ern,
          ot_hrs,
          rate,
          rate_2,
          rate_3,
          rate_used,
          rg_ern,
          rg_hrs,
          sdi_tax,
          ss_tax,
          state_tax_1,
          state_tax_2,
          sui_tax,
          take_home_pay,
          ern_3_hb,
          ern_4_sev,
          ded_cd_mis,
          ern_4_sic,
          memo_cd_b_input,
          ern_3_rlb,
          ded_cd_rpe,
          memo_cd_epn_calc,
          hrs_4_jd,
          ern_4_awa,
          hrs_4_awa,
          hrs_4_ret,
          ern_3_dc,
          memo_cd_epn_input,
          ded_cd_71,
          ern_5_bp,
          ern_4_bp,
          ern_4_ssc
        )
      ) AS u
  )
SELECT
  u.position_id,
  u.fiscal_year,
  u.payroll_week,
  u.preview_or_final,
  u.preview_number,
  u.payroll_run,
  u.company_code,
  u.payroll_date,
  u.file_nbr,
  u.dept,
  u.cost_nbr,
  u.fli_code,
  u.rt,
  u.state_cd_1,
  u.state_cd_2,
  u.sui_sdi_code,
  u.void_ind,
  u.code,
  u.code_value,
  u.max_final_payroll_date,
  rcl.audit_type,
  COALESCE(rcl.display, u.code) AS code_display,
  eh.employee_number,
  eh.business_unit AS business_unit_paydate,
  eh.[location] AS location_paydate,
  eh.home_department AS department_paydate,
  eh.job_title AS job_title_paydate,
  eh.annual_salary AS salary_paydate,
  eh.position_status AS status_paydate,
  r.preferred_name,
  r.legal_entity_name AS business_unit_curr,
  r.primary_site AS location_curr,
  r.primary_on_site_department AS department_curr,
  r.primary_job AS job_title_curr,
  r.annual_salary AS salary_curr,
  r.[status] AS status_curr
FROM
  payroll_unpivot AS u
  LEFT JOIN gabby.payroll.register_code_lookup AS rcl ON (
    u.company_code = rcl.company_code
    AND u.code = rcl.field_name
  )
  INNER JOIN gabby.people.employment_history_static AS eh ON (
    u.position_id = eh.position_id
    AND (
      u.payroll_date BETWEEN eh.effective_start_date AND eh.effective_end_date
    )
  )
  INNER JOIN gabby.people.staff_crosswalk_static AS r ON (
    eh.employee_number = r.df_employee_number
  )
