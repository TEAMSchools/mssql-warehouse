with
    hashes as (
        select
            _file,
            _line,
            _modified,
            position_id,
            hashbytes(
                'SHA2_512',
                concat(
                    annual_salary,
                    associate_id,
                    attended_relay,
                    birth_date,
                    business_unit_description,
                    ethnicity,
                    file_number,
                    first_name,
                    flsa_description,
                    gender,
                    gender_for_insurance_coverage,
                    hire_date,
                    home_department_description,
                    job_title_code,
                    job_title_description,
                    kipp_alumni_status,
                    last_name,
                    life_experience_in_communities_we_serve,
                    location_description,
                    miami_aces_number,
                    middle_name,
                    payroll_company_name,
                    personal_contact_personal_email,
                    personal_contact_personal_mobile,
                    position_effective_end_date,
                    position_start_date,
                    position_status,
                    preferred_first_name,
                    preferred_name,
                    preferred_race_ethnicity,
                    primary_address_address_line_1,
                    primary_address_address_line_2,
                    primary_address_city,
                    primary_address_state_territory_code,
                    primary_address_zip_postal_code,
                    primary_position,
                    professional_experience_in_communities_we_serve,
                    race_description,
                    rehire_date,
                    reports_to_associate_id,
                    reports_to_email,
                    salutation,
                    teacher_prep_program,
                    termination_date,
                    termination_reason_description,
                    wfmgr_accrual_profile,
                    wfmgr_badge_number,
                    wfmgr_ee_type,
                    wfmgr_pay_rule,
                    worker_category_description,
                    years_of_professional_experience_before_joining,
                    years_teaching_in_any_state,
                    years_teaching_in_nj_or_fl
                )
            ) as row_hash
        from adp.employees_archive
        where position_id is not null
    ),
    hash_rn as (
        select
            row_hash,
            concat(_file, _line, _modified) as row_id,
            lag(row_hash, 1) over (
                partition by position_id order by _modified
            ) as row_hash_prev
        from hashes
    )

delete from adp.employees_archive
where
    concat(_file, _line, _modified)
    in (select row_id from hash_rn where row_hash = row_hash_prev)
