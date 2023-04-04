{{-
    config(
        alias="stg_incidents",
        post_hook=[
            "{{ create_clustered_index(columns=['incident_id'], unique=True) }}"
        ],
    )
-}}

with
    deduplicate as (
        {{
            dbt_utils.deduplicate(
                relation=source("deanslist", "incidents"),
                partition_by="incident_id",
                order_by="_modified desc, _line desc",
            )
        }}
    )

select
    _file,
    _fivetran_synced,
    _line,
    _modified,
    actions,
    addl_reqs,
    admin_summary,
    category_id,
    category,
    context,
    create_by,
    create_first,
    create_last,
    create_middle,
    create_staff_school_id,
    create_title,
    custom_fields,
    family_meeting_notes,
    gender,
    grade_level_short,
    hearing_flag,
    homeroom_name,
    incident_id,
    infraction_type_id,
    infraction,
    is_active,
    is_referral,
    location_id,
    penalties,
    reported_details,
    reporting_incident_id,
    return_period,
    school_id,
    send_alert,
    status_id,
    student_first,
    student_id,
    student_last,
    student_middle,
    student_school_id,
    update_by,
    update_first,
    update_last,
    update_middle,
    update_staff_school_id,
    update_title,
    [location],
    [status],

    cast(json_value(return_date, '$.date') as date) as return_date,
    cast(json_value(issue_ts, '$.date') as datetime2) as issue_ts,
    cast(json_value(update_ts, '$.date') as datetime2) as update_ts,
    cast(json_value(close_ts, '$.date') as datetime2) as close_ts,
    cast(json_value(review_ts, '$.date') as datetime2) as review_ts,
    cast(json_value(create_ts, '$.date') as datetime2) as create_ts,
    cast(json_value(dl_lastupdate, '$.date') as datetime2) as dl_lastupdate,

    gabby.utilities.date_to_sy(
        cast(json_value(create_ts, '$.date') as datetime2)
    ) as create_academic_year
from deduplicate
