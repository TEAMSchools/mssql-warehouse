USE gabby GO
CREATE OR ALTER VIEW
    extracts.cpn_parcc AS
SELECT
    student_number,
    academic_year,
    test_code,
    subject,
    test_scale_score,
    test_performance_level,
    is_proficient,
    test_standard_error
FROM
    gabby.tableau.state_assessment_dashboard
WHERE
    region = 'KCNA'
    AND test_type = 'PARCC'
