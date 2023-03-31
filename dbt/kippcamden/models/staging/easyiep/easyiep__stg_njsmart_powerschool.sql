{{-
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key="['_file', '_line']",
        alias="stg_njsmart_powerschool",
        post_hook=[],
    )
-}}

with
    using_clause as (
        select
            *,
            case
                when gabby.utilities.strip_characters(_file, '^0-9') = ''
                then cast(_modified as date)
                else cast(gabby.utilities.strip_characters(_file, '^0-9') as date)
            end as effective_date,
            hashbytes(
                'SHA2_512',
                concat(
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
                    special_education,
                    state_studentnumber,
                    student_number,
                    ti_serv_counseling,
                    ti_serv_occup,
                    ti_serv_other,
                    ti_serv_physical,
                    ti_serv_speech,
                )
            ) as row_hash
        from {{ source("easyiep", "njsmart_powerschool") }}
    )

    updates as (
        select *
        from {{ this }}
        where row_hash is null or effective_date is null or academic_year is null
    ),

    inserts as (
        select *
        from using_clause
        where {{ unique_key }} not in (select {{ unique_key }} from updates)
    )
{# gabby.utilities.date_to_sy(effective_date_new) as academic_year_new #}
select *
from updates

union all

select *
from
    inserts

    {# exec gabby.utilities.cache_view 'kippcamden', 'easyiep', 'njsmart_powerschool_clean' #}
    
