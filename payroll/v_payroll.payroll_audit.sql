USE gabby
GO

CREATE OR ALTER VIEW payroll.payroll_audit AS

WITH payroll_rollup AS (
  SELECT SUBSTRING(_file, 9, 4) AS fiscal_year
        ,SUBSTRING(_file, 14, CHARINDEX('-',_file,14)-14) AS payroll_week
        ,REPLACE(SUBSTRING(_file, CHARINDEX('-',_file,14)+1,2),'-','') AS payroll_run
        ,SUBSTRING(_file,CHARINDEX(' ',_file)-3,3) AS company_code
        ,CONVERT(DATE,SUBSTRING(_file,CHARINDEX(' ',_file),11)) AS payroll_date
        ,file_nbr
        ,CONCAT(SUBSTRING(_file,CHARINDEX(' ',_file)-3,3), file_nbr) AS postion_id
        ,dept
        ,cost_nbr
        ,gabby.dbo.GROUP_CONCAT(DISTINCT fli_code) AS fli_code
        ,gabby.dbo.GROUP_CONCAT(DISTINCT rt) AS rt
        ,gabby.dbo.GROUP_CONCAT(DISTINCT state_cd_1) AS state_cd_1
        ,gabby.dbo.GROUP_CONCAT(DISTINCT state_cd_2) AS state_cd_2
        ,gabby.dbo.GROUP_CONCAT(DISTINCT sui_sdi_code) AS sui_sdi_code
        ,gabby.dbo.GROUP_CONCAT(DISTINCT void_ind) AS void_ind
        ,SUM(ded_cd_3) AS ded_cd_3
        ,SUM(ded_cd_4) AS ded_cd_4
        ,SUM(ded_cd_403) AS ded_cd_403
        ,SUM(ded_cd_73) AS ded_cd_73
        ,SUM(ded_cd_74) AS ded_cd_74
        ,SUM(ded_cd_75) AS ded_cd_75
        ,SUM(ded_cd_76) AS ded_cd_76
        ,SUM(ded_cd_acc) AS ded_cd_acc
        ,SUM(ded_cd_add) AS ded_cd_add
        ,SUM(ded_cd_bcp) AS ded_cd_bcp
        ,SUM(ded_cd_bct) AS ded_cd_bct
        ,SUM(ded_cd_c) AS ded_cd_c
        ,SUM(ded_cd_ck_1) AS ded_cd_ck_1
        ,SUM(ded_cd_ck_2) AS ded_cd_ck_2
        ,SUM(ded_cd_ck_3) AS ded_cd_ck_3
        ,SUM(ded_cd_ck_4) AS ded_cd_ck_4
        ,SUM(ded_cd_sv_1) AS ded_cd_sv_1
        ,SUM(ded_cd_sv_2) AS ded_cd_sv_2
        ,SUM(ded_cd_sv_3) AS ded_cd_sv_3
        ,SUM(ded_cd_sv_4) AS ded_cd_sv_4
        ,SUM(ded_cd_den) AS ded_cd_den
        ,SUM(ded_cd_dfs) AS ded_cd_dfs
        ,SUM(ded_cd_e) AS ded_cd_e
        ,SUM(ded_cd_ed) AS ded_cd_ed
        ,SUM(ded_cd_em) AS ded_cd_em
        ,SUM(ded_cd_ev) AS ded_cd_ev
        ,SUM(ded_cd_hos) AS ded_cd_hos
        ,SUM(ded_cd_hsa) AS ded_cd_hsa
        ,SUM(ded_cd_i) AS ded_cd_i
        ,SUM(ded_cd_j) AS ded_cd_j
        ,SUM(ded_cd_k) AS ded_cd_k
        ,SUM(ded_cd_l) AS ded_cd_l
        ,SUM(ded_cd_ln_1) AS ded_cd_ln_1
        ,SUM(ded_cd_ln_2) AS ded_cd_ln_2
        ,SUM(ded_cd_med) AS ded_cd_med
        ,SUM(ded_cd_mfs) AS ded_cd_mfs
        ,SUM(ded_cd_p) AS ded_cd_p
        ,SUM(ded_cd_psc) AS ded_cd_psc
        ,SUM(ded_cd_q) AS ded_cd_q
        ,SUM(ded_cd_trn) AS ded_cd_trn
        ,SUM(ded_cd_ver) AS ded_cd_ver
        ,SUM(ded_cd_vis) AS ded_cd_vis
        ,SUM(ern_3_bon) AS ern_3_bon
        ,SUM(ern_3_ds) AS ern_3_ds
        ,SUM(ern_3_ecl) AS ern_3_ecl
        ,SUM(ern_3_glc) AS ern_3_glc
        ,SUM(ern_3_hwb) AS ern_3_hwb
        ,SUM(ern_3_lp) AS ern_3_lp
        ,SUM(ern_3_oob) AS ern_3_oob
        ,SUM(ern_3_ret) AS ern_3_ret
        ,SUM(ern_4_ac) AS ern_4_ac
        ,SUM(ern_4_ba) AS ern_4_ba
        ,SUM(ern_4_bon) AS ern_4_bon
        ,SUM(ern_4_db) AS ern_4_db
        ,SUM(ern_4_dc) AS ern_4_dc
        ,SUM(ern_4_dei) AS ern_4_dei
        ,SUM(ern_4_ds) AS ern_4_ds
        ,SUM(ern_4_ecl) AS ern_4_ecl
        ,SUM(ern_4_emh) AS ern_4_emh
        ,SUM(ern_4_epc) AS ern_4_epc
        ,SUM(ern_4_hb) AS ern_4_hb
        ,SUM(ern_4_glc) AS ern_4_glc
        ,SUM(ern_4_ic) AS ern_4_ic
        ,SUM(ern_4_lp) AS ern_4_lp
        ,SUM(ern_4_ntp) AS ern_4_ntp
        ,SUM(ern_4_oob) AS ern_4_oob
        ,SUM(ern_4_ret) AS ern_4_ret
        ,SUM(ern_4_trs) AS ern_4_trs
        ,SUM(ern_5_ret) AS ern_5_ret
        ,SUM(fed_tax) AS fed_tax
        ,SUM(fli_amount) AS fli_amount
        ,SUM(gross) AS gross
        ,SUM(hrs_4_bev) AS hrs_4_bev
        ,SUM(hrs_4_cvd) AS hrs_4_cvd
        ,SUM(hrs_4_prd) AS hrs_4_prd
        ,SUM(hrs_4_pto) AS hrs_4_pto
        ,SUM(hrs_4_rel) AS hrs_4_rel
        ,SUM(hrs_4_sic) AS hrs_4_sic
        ,SUM(local_cd_1) AS local_cd_1
        ,SUM(local_cd_2) AS local_cd_2
        ,SUM(local_tax_1) AS local_tax_1
        ,SUM(local_tax_2) AS local_tax_2
        ,SUM(med_surtax) AS med_surtax
        ,SUM(med_tax) AS med_tax
        ,SUM(net_pay) AS net_pay
        ,SUM(ot_ern) AS ot_ern
        ,SUM(ot_hrs) AS ot_hrs
        ,SUM(rate) AS rate
        ,SUM(rate_2) AS rate_2
        ,SUM(rate_3) AS rate_3
        ,SUM(rate_used) AS rate_used
        ,SUM(rg_ern) AS rg_ern
        ,SUM(rg_hrs) AS rg_hrs
        ,SUM(sdi_tax) AS sdi_tax
        ,SUM(ss_tax) AS ss_tax
        ,SUM(state_tax_1) AS state_tax_1
        ,SUM(state_tax_2) AS state_tax_2
        ,SUM(sui_tax) AS sui_tax
        ,SUM(1) AS n_records
        ,SUM(COALESCE(ded_cd_ck_1,0) + 
             COALESCE(ded_cd_ck_2,0) + 
             COALESCE(ded_cd_ck_3,0) + 
             COALESCE(ded_cd_ck_4,0) + 
             COALESCE(ded_cd_sv_1,0) + 
             COALESCE(ded_cd_sv_2,0) + 
             COALESCE(ded_cd_sv_3,0) + 
             COALESCE(ded_cd_sv_4,0) + 
             COALESCE(net_pay,0)
                                 ) AS take_home_pay
  FROM gabby.adp.payroll_register
  GROUP BY _file, file_nbr, dept, cost_nbr
 )
,payroll_unpivot AS (
  SELECT employee_number
        ,fiscal_year
        ,payroll_week
        ,payroll_run
        ,company_code
        ,payroll_date
        ,file_nbr
        ,dept
        ,cost_nbr
        ,fli_code
        ,rt
        ,state_cd_1
        ,state_cd_2
        ,sui_sdi_code
        ,void_ind
        ,code
        ,code_value
        ,position_id
        ,LAG(code_value, 1) OVER(PARTITION BY fiscal_year, employee_number, code ORDER BY payroll_week, payroll_run) AS prev_code_value
        ,LAG(payroll_date, 1) OVER(PARTITION BY fiscal_year, employee_number, code ORDER BY payroll_week, payroll_run) AS prev_payroll_date
  FROM
      (
       SELECT eh.employee_number
             ,fiscal_year
             ,payroll_week
             ,payroll_run
             ,company_code
             ,payroll_date
             ,file_nbr
             ,position_id
             ,dept
             ,cost_nbr
             ,fli_code
             ,rt
             ,state_cd_1
             ,state_cd_2
             ,sui_sdi_code
             ,void_ind
             ,CONVERT(NVARCHAR(16), fed_tax) AS fed_tax
             ,CONVERT(NVARCHAR(16), gross) AS gross
             ,CONVERT(NVARCHAR(16), net_pay) AS net_pay
             ,CONVERT(NVARCHAR(16), take_home_pay) AS take_home_pay
             ,CONVERT(NVARCHAR(16), ded_cd_3) AS ded_cd_3
             ,CONVERT(NVARCHAR(16), ded_cd_4) AS ded_cd_4
             ,CONVERT(NVARCHAR(16), ded_cd_403) AS ded_cd_403
             ,CONVERT(NVARCHAR(16), ded_cd_73) AS ded_cd_73
             ,CONVERT(NVARCHAR(16), ded_cd_74) AS ded_cd_74
             ,CONVERT(NVARCHAR(16), ded_cd_75) AS ded_cd_75
             ,CONVERT(NVARCHAR(16), ded_cd_76) AS ded_cd_76
             ,CONVERT(NVARCHAR(16), ded_cd_acc) AS ded_cd_acc
             ,CONVERT(NVARCHAR(16), ded_cd_add) AS ded_cd_add
             ,CONVERT(NVARCHAR(16), ded_cd_bcp) AS ded_cd_bcp
             ,CONVERT(NVARCHAR(16), ded_cd_bct) AS ded_cd_bct
             ,CONVERT(NVARCHAR(16), ded_cd_c) AS ded_cd_c
             ,CONVERT(NVARCHAR(16), ded_cd_den) AS ded_cd_den
             ,CONVERT(NVARCHAR(16), ded_cd_dfs) AS ded_cd_dfs
             ,CONVERT(NVARCHAR(16), ded_cd_e) AS ded_cd_e
             ,CONVERT(NVARCHAR(16), ded_cd_ed) AS ded_cd_ed
             ,CONVERT(NVARCHAR(16), ded_cd_em) AS ded_cd_em
             ,CONVERT(NVARCHAR(16), ded_cd_ev) AS ded_cd_ev
             ,CONVERT(NVARCHAR(16), ded_cd_hos) AS ded_cd_hos
             ,CONVERT(NVARCHAR(16), ded_cd_hsa) AS ded_cd_hsa
             ,CONVERT(NVARCHAR(16), ded_cd_i) AS ded_cd_i
             ,CONVERT(NVARCHAR(16), ded_cd_j) AS ded_cd_j
             ,CONVERT(NVARCHAR(16), ded_cd_k) AS ded_cd_k
             ,CONVERT(NVARCHAR(16), ded_cd_l) AS ded_cd_l
             ,CONVERT(NVARCHAR(16), ded_cd_ln_1) AS ded_cd_ln_1
             ,CONVERT(NVARCHAR(16), ded_cd_ln_2) AS ded_cd_ln_2
             ,CONVERT(NVARCHAR(16), ded_cd_med) AS ded_cd_med
             ,CONVERT(NVARCHAR(16), ded_cd_mfs) AS ded_cd_mfs
             ,CONVERT(NVARCHAR(16), ded_cd_p) AS ded_cd_p
             ,CONVERT(NVARCHAR(16), ded_cd_psc) AS ded_cd_psc
             ,CONVERT(NVARCHAR(16), ded_cd_q) AS ded_cd_q
             ,CONVERT(NVARCHAR(16), ded_cd_trn) AS ded_cd_trn
             ,CONVERT(NVARCHAR(16), ded_cd_ver) AS ded_cd_ver
             ,CONVERT(NVARCHAR(16), ded_cd_vis) AS ded_cd_vis
             ,CONVERT(NVARCHAR(16), ern_3_bon) AS ern_3_bon
             ,CONVERT(NVARCHAR(16), ern_3_ds) AS ern_3_ds
             ,CONVERT(NVARCHAR(16), ern_3_ecl) AS ern_3_ecl
             ,CONVERT(NVARCHAR(16), ern_3_glc) AS ern_3_glc
             ,CONVERT(NVARCHAR(16), ern_3_hwb) AS ern_3_hwb
             ,CONVERT(NVARCHAR(16), ern_3_lp) AS ern_3_lp
             ,CONVERT(NVARCHAR(16), ern_3_oob) AS ern_3_oob
             ,CONVERT(NVARCHAR(16), ern_3_ret) AS ern_3_ret
             ,CONVERT(NVARCHAR(16), ern_4_ac) AS ern_4_ac
             ,CONVERT(NVARCHAR(16), ern_4_ba) AS ern_4_ba
             ,CONVERT(NVARCHAR(16), ern_4_bon) AS ern_4_bon
             ,CONVERT(NVARCHAR(16), ern_4_db) AS ern_4_db
             ,CONVERT(NVARCHAR(16), ern_4_dc) AS ern_4_dc
             ,CONVERT(NVARCHAR(16), ern_4_dei) AS ern_4_dei
             ,CONVERT(NVARCHAR(16), ern_4_ds) AS ern_4_ds
             ,CONVERT(NVARCHAR(16), ern_4_ecl) AS ern_4_ecl
             ,CONVERT(NVARCHAR(16), ern_4_emh) AS ern_4_emh
             ,CONVERT(NVARCHAR(16), ern_4_epc) AS ern_4_epc
             ,CONVERT(NVARCHAR(16), ern_4_glc) AS ern_4_glc
             ,CONVERT(NVARCHAR(16), ern_4_hb) AS ern_4_hb
             ,CONVERT(NVARCHAR(16), ern_4_ic) AS ern_4_ic
             ,CONVERT(NVARCHAR(16), ern_4_lp) AS ern_4_lp
             ,CONVERT(NVARCHAR(16), ern_4_ntp) AS ern_4_ntp
             ,CONVERT(NVARCHAR(16), ern_4_oob) AS ern_4_oob
             ,CONVERT(NVARCHAR(16), ern_4_ret) AS ern_4_ret
             ,CONVERT(NVARCHAR(16), ern_4_trs) AS ern_4_trs
             ,CONVERT(NVARCHAR(16), ern_5_ret) AS ern_5_ret
             ,CONVERT(NVARCHAR(16), fli_amount) AS fli_amount
             ,CONVERT(NVARCHAR(16), hrs_4_bev) AS hrs_4_bev
             ,CONVERT(NVARCHAR(16), hrs_4_cvd) AS hrs_4_cvd
             ,CONVERT(NVARCHAR(16), hrs_4_prd) AS hrs_4_prd
             ,CONVERT(NVARCHAR(16), hrs_4_pto) AS hrs_4_pto
             ,CONVERT(NVARCHAR(16), hrs_4_rel) AS hrs_4_rel
             ,CONVERT(NVARCHAR(16), hrs_4_sic) AS hrs_4_sic
             ,CONVERT(NVARCHAR(16), local_cd_1) AS local_cd_1
             ,CONVERT(NVARCHAR(16), local_cd_2) AS local_cd_2
             ,CONVERT(NVARCHAR(16), local_tax_1) AS local_tax_1
             ,CONVERT(NVARCHAR(16), local_tax_2) AS local_tax_2
             ,CONVERT(NVARCHAR(16), med_surtax) AS med_surtax
             ,CONVERT(NVARCHAR(16), med_tax) AS med_tax
             ,CONVERT(NVARCHAR(16), ot_ern) AS ot_ern
             ,CONVERT(NVARCHAR(16), ot_hrs) AS ot_hrs
             ,CONVERT(NVARCHAR(16), rate) AS rate
             ,CONVERT(NVARCHAR(16), rate_2) AS rate_2
             ,CONVERT(NVARCHAR(16), rate_3) AS rate_3
             ,CONVERT(NVARCHAR(16), rate_used) AS rate_used
             ,CONVERT(NVARCHAR(16), rg_ern) AS rg_ern
             ,CONVERT(NVARCHAR(16), rg_hrs) AS rg_hrs
             ,CONVERT(NVARCHAR(16), sdi_tax) AS sdi_tax
             ,CONVERT(NVARCHAR(16), ss_tax) AS ss_tax
             ,CONVERT(NVARCHAR(16), state_tax_1) AS state_tax_1
             ,CONVERT(NVARCHAR(16), state_tax_2) AS state_tax_2
             ,CONVERT(NVARCHAR(16), sui_tax) AS sui_tax
             ,CONVERT(NVARCHAR(16), n_records) AS n_records

       FROM payroll_rollup r
       LEFT JOIN (SELECT DISTINCT employee_number, position_id FROM gabby.people.employment_history) eh
         ON CONCAT(company_code, file_nbr) = eh.position_id
      ) sub
  UNPIVOT(
    code_value 
    FOR code IN (
           ded_cd_3, ded_cd_4, ded_cd_403, ded_cd_73, ded_cd_74, ded_cd_75
          ,ded_cd_76, ded_cd_acc, ded_cd_add, ded_cd_bcp, ded_cd_bct, ded_cd_c
          ,ded_cd_den, ded_cd_dfs, ded_cd_e, ded_cd_ed, ded_cd_em, ded_cd_ev
          ,ded_cd_hos, ded_cd_hsa, ded_cd_i, ded_cd_j, ded_cd_k, ded_cd_l
          ,ded_cd_ln_1, ded_cd_ln_2, ded_cd_med, ded_cd_mfs, ded_cd_p, ded_cd_psc
          ,ded_cd_q, ded_cd_trn, ded_cd_ver, ded_cd_vis, ern_3_bon, ern_3_ds
          ,ern_3_ecl, ern_3_glc, ern_3_hwb, ern_3_lp, ern_3_oob, ern_3_ret
          ,ern_4_ac, ern_4_ba, ern_4_bon, ern_4_db, ern_4_dc, ern_4_dei, ern_4_ds
          ,ern_4_ecl, ern_4_emh, ern_4_epc, ern_4_glc, ern_4_hb, ern_4_ic, ern_4_lp
          ,ern_4_ntp, ern_4_oob, ern_4_ret, ern_4_trs, ern_5_ret, fli_amount
          ,hrs_4_bev, hrs_4_cvd, hrs_4_prd, hrs_4_pto, hrs_4_rel
          ,hrs_4_sic, local_cd_1, local_cd_2, local_tax_1, local_tax_2, med_surtax
          ,med_tax, n_records, ot_ern, ot_hrs, rate, rate_2, rate_3, rate_used
          ,rg_ern, rg_hrs, sdi_tax, ss_tax, state_tax_1, state_tax_2, sui_tax
          ,fed_tax, gross, net_pay, take_home_pay
                )
   ) u
 )
SELECT u.employee_number
      ,u.position_id
      ,u.fiscal_year
      ,u.payroll_week
      ,u.payroll_run
      ,u.company_code
      ,u.payroll_date
      ,u.prev_payroll_date
      ,u.file_nbr
      ,u.dept
      ,u.cost_nbr
      ,u.fli_code
      ,u.rt
      ,u.state_cd_1
      ,u.state_cd_2
      ,u.sui_sdi_code
      ,u.void_ind
      ,u.code
      ,u.code_value
      ,u.prev_code_value
      ,CONVERT(FLOAT, u.code_value) - CONVERT(FLOAT, u.prev_code_value) AS code_value_diff

      ,COALESCE(rcl.display,u.code) AS code_display
      ,CASE 
        WHEN u.payroll_date = u.prev_payroll_date THEN 'New Payroll Code'
        ELSE rcl.audit_type
       END AS audit_type

      ,r.preferred_name
      ,r.business_unit AS business_unit_curr
      ,r.[location] AS location_curr
      ,r.home_department AS department_curr
      ,r.job_title AS job_title_curr
      ,r.annual_salary AS salary_curr
      ,r.position_status AS status_curr
      
      ,eh.business_unit AS business_unit_paydate
      ,eh.[location] AS location_paydate
      ,eh.home_department AS department_paydate
      ,eh.job_title AS job_title_paydate
      ,eh.annual_salary AS salary_paydate
      ,eh.position_status AS status_paydate

      ,ehp.business_unit AS business_unit_prev_paydate
      ,ehp.[location] AS location_prev_paydate
      ,ehp.home_department AS department_prev_paydate
      ,ehp.job_title AS job_title_prev_paydate
      ,ehp.annual_salary AS salary_prev_paydate
      ,ehp.position_status AS status_prev_paydate

FROM payroll_unpivot u
LEFT JOIN gabby.payroll.register_code_lookup rcl
  ON u.company_code = rcl.company_code
 AND u.code = rcl.field_name
JOIN gabby.people.employment_history eh
  ON u.position_id = eh.position_id
 AND u.payroll_date BETWEEN eh.effective_start_date AND eh.effective_end_date
JOIN gabby.people.employment_history ehp
  ON u.position_id = ehp.position_id
 AND u.prev_payroll_date BETWEEN ehp.effective_start_date AND ehp.effective_end_date
JOIN gabby.people.staff_roster r
  ON eh.employee_number = r.employee_number