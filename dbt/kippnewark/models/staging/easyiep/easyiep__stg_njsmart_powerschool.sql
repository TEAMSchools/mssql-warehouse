{{-
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key="row_hash",
        alias="stg_njsmart_powerschool",
        post_hook=[
            "{{ create_clustered_index(columns=['row_hash'], unique=True) }}"
        ],
    )
-}}

with
    clean_data as (
        select
            _file,
            _line,
            case_manager,
            iepgraduation_attendance,
            iepgraduation_course_requirement,
            cast(state_studentnumber as bigint) as state_studentnumber,
            cast(nj_se_referraldate as date) as nj_se_referraldate,
            cast(nj_se_parentalconsentdate as date) as nj_se_parentalconsentdate,
            cast(nj_se_eligibilityddate as date) as nj_se_eligibilityddate,
            cast(nj_se_initialiepmeetingdate as date) as nj_se_initialiepmeetingdate,
            cast(nj_se_consenttoimplementdate as date) as nj_se_consenttoimplementdate,
            cast(nj_se_lastiepmeetingdate as date) as nj_se_lastiepmeetingdate,
            cast(nj_se_reevaluationdate as date) as nj_se_reevaluationdate,
            cast(iepbegin_date as date) as iepbegin_date,
            cast(iepend_date as date) as iepend_date,
            cast(nj_timeinregularprogram as float) as nj_timeinregularprogram,
            cast(nj_se_delayreason as nvarchar(2)) as nj_se_delayreason,
            cast(nj_se_placement as nvarchar(2)) as nj_se_placement,
            cast(
                nj_se_parental_consentobtained as nvarchar(1)
            ) as nj_se_parental_consentobtained,
            cast(ti_serv_counseling as nvarchar(1)) as ti_serv_counseling,
            cast(ti_serv_occup as nvarchar(1)) as ti_serv_occup,
            cast(ti_serv_physical as nvarchar(1)) as ti_serv_physical,
            cast(ti_serv_speech as nvarchar(1)) as ti_serv_speech,
            cast(ti_serv_other as nvarchar(1)) as ti_serv_other,

            right('0' + cast(special_education as nvarchar), 2) as special_education,
            cast(
                try_parse(cast(student_number as nvarchar(32)) as bigint) as bigint
            ) as student_number,
            case
                when
                    gabby.utilities.strip_characters(
                        _file, '^0-9'
                    ) collate latin1_general_bin
                    = ''
                then cast(_modified as date)
                else cast(gabby.utilities.strip_characters(_file, '^0-9') as date)
            end as effective_date
        from {{ source("easyiep", "njsmart_powerschool") }}
        {% if is_incremental() %}
        where _modified >= datefromparts(gabby.utilities.global_academic_year(), 7, 1)
        {% endif %}
    ),

    translations as (
        select
            _file,
            _line,
            student_number,
            effective_date,
            special_education,
            case_manager,
            iepbegin_date,
            iepend_date,
            iepgraduation_attendance,
            iepgraduation_course_requirement,
            nj_se_consenttoimplementdate,
            nj_se_delayreason,
            nj_se_eligibilityddate,
            nj_se_initialiepmeetingdate,
            nj_se_lastiepmeetingdate,
            nj_se_parental_consentobtained,
            nj_se_parentalconsentdate,
            nj_se_placement,
            nj_se_reevaluationdate,
            nj_se_referraldate,
            nj_timeinregularprogram,
            ti_serv_counseling,
            ti_serv_occup,
            ti_serv_other,
            ti_serv_physical,
            ti_serv_speech,

            coalesce(state_studentnumber, student_number) as state_studentnumber,
            gabby.utilities.date_to_sy(effective_date) as academic_year,
            case
                when special_education = ''
                then null
                when special_education is null
                then null
                when nj_se_parental_consentobtained = 'R'
                then null
                when special_education in ('00', '99')
                then null
                when special_education = '17'
                then 'SPED SPEECH'
                else 'SPED'
            end as spedlep,
            case
                when nj_se_parental_consentobtained = 'R'
                then null
                when special_education = '01'
                then 'AI'
                when special_education = '02'
                then 'AUT'
                when special_education = '03'
                then 'CMI'
                when special_education = '04'
                then 'CMO'
                when special_education = '05'
                then 'CSE'
                when special_education = '06'
                then 'CI'
                when special_education = '07'
                then 'ED'
                when special_education = '08'
                then 'MD'
                when special_education = '09'
                then 'DB'
                when special_education = '10'
                then 'OI'
                when special_education = '11'
                then 'OHI'
                when special_education = '12'
                then 'PSD'
                when special_education = '13'
                then 'SM'
                when special_education = '14'
                then 'SLD'
                when special_education = '15'
                then 'TBI'
                when special_education = '16'
                then 'VI'
                when special_education = '17'
                then 'ESLS'
                when special_education = '99'
                then '99'
                when special_education = '00'
                then '00'
            end as special_education_code,
            hashbytes(
                'SHA2_512',
                concat(
                    case_manager,
                    '_',
                    iepbegin_date,
                    '_',
                    iepend_date,
                    '_',
                    iepgraduation_attendance,
                    '_',
                    iepgraduation_course_requirement,
                    '_',
                    nj_se_consenttoimplementdate,
                    '_',
                    nj_se_delayreason,
                    '_',
                    nj_se_eligibilityddate,
                    '_',
                    nj_se_initialiepmeetingdate,
                    '_',
                    nj_se_lastiepmeetingdate,
                    '_',
                    nj_se_parental_consentobtained,
                    '_',
                    nj_se_parentalconsentdate,
                    '_',
                    nj_se_placement,
                    '_',
                    nj_se_reevaluationdate,
                    '_',
                    nj_se_referraldate,
                    '_',
                    nj_timeinregularprogram,
                    '_',
                    special_education,
                    '_',
                    state_studentnumber,
                    '_',
                    student_number,
                    '_',
                    ti_serv_counseling,
                    '_',
                    ti_serv_occup,
                    '_',
                    ti_serv_other,
                    '_',
                    ti_serv_physical,
                    '_',
                    ti_serv_speech,
                    '_',
                    gabby.utilities.date_to_sy(effective_date)
                )
            ) as row_hash
        from clean_data
    ),

    deduplicate as (
        {{
            dbt_utils.deduplicate(
                relation="translations",
                partition_by="row_hash",
                order_by="effective_date asc",
            )
        }}
    )

select
    *,
    coalesce(
        dateadd(
            day,
            -1,
            lead(effective_date, 1) over (
                partition by student_number, academic_year order by effective_date asc
            )
        ),
        datefromparts(academic_year + 1, 6, 30)
    ) as effective_end_date,
    row_number() over (
        partition by student_number, academic_year order by effective_date desc
    ) as rn_stu_yr
from deduplicate
