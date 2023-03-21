CREATE OR ALTER VIEW surveys.miami_enrollment AS

WITH survey_pivot AS (
    SELECT
        survey_id,
        survey_response_id,
        date_submitted,
        [student_number],
        [region],
        [miami_transport_consent],
        [miami_shirt],
        [miami_plan],
        [miami_phone],
        [miami_not_returning],
        [miami_middle],
        [miami_last],
        [miami_first],
        [miami_email],
        [miami_bus],
        [miami_bus_stop],
        [miami_address]
    FROM
        (
            SELECT
                question_shortname,
                answer,
                survey_id,
                survey_response_id,
                date_submitted
            FROM
                gabby.surveygizmo.survey_detail
            WHERE
                survey_id = 6829997
        ) AS sub PIVOT (
            MAX(answer) FOR question_shortname IN (
                [student_number], [region], [miami_transport_consent],
                [miami_shirt], [miami_plan], [miami_phone],
                [miami_not_returning], [miami_middle],
                [miami_last], [miami_first], [miami_email],
                [miami_bus], [miami_bus_stop],[miami_address]
            )
        ) p
)
SELECT
    region,
    miami_plan,
    miami_not_returning,
    miami_first,
    miami_middle,
    miami_last,
    miami_phone,
    miami_email,
    miami_address,
    miami_bus,
    miami_bus_stop,
    miami_transport_consent,
    miami_shirt,
    student_number,
    survey_id,
    survey_response_id,
    date_submitted
FROM
    survey_pivot
/*JOIN to student data for school, cohort, IEP, gender, race, other*/
WHERE
    region = 'KMS'