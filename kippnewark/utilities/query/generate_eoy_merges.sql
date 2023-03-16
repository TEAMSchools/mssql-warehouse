EXEC sp_generate_merge @table_name = 'attendance_clean_current_static',
@target_table = 'attendance_clean_archive',
@schema = 'powerschool',
@cols_to_join_on = "'id'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'cohort_identifiers_scaffold_current_static',
@target_table = 'cohort_identifiers_scaffold_archive',
@schema = 'powerschool',
@cols_to_join_on = "'student_number','date'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'course_section_scaffold_current_static',
@target_table = 'course_section_scaffold_archive',
@schema = 'powerschool',
@cols_to_join_on = "'studentid','yearid','sectionid','term_name','course_number','gradescaleid'", -- noqa: L016
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'gradebook_assignments_current_static',
@target_table = 'gradebook_assignments_archive',
@schema = 'powerschool',
@cols_to_join_on = "'assignmentsectionid'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'gradebook_assignments_scores_current_static',
@target_table = 'gradebook_assignments_scores_archive',
@schema = 'powerschool',
@cols_to_join_on = "'studentsdcid','assignmentsectionid','assignmentid'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'ps_adaadm_daily_ctod_current_static',
@target_table = 'ps_adaadm_daily_ctod_archive',
@schema = 'powerschool',
@cols_to_join_on = "'studentid','calendardate'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'ps_attendance_daily_current_static',
@target_table = 'ps_attendance_daily_archive',
@schema = 'powerschool',
@cols_to_join_on = "'id'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'ps_membership_reg_current_static',
@target_table = 'ps_membership_reg_archive',
@schema = 'powerschool',
@cols_to_join_on = "'studentid','calendardate'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'attendance_dashboard_current_static',
@target_table = 'attendance_dashboard_archive',
@schema = 'tableau',
@cols_to_join_on = "'student_number','calendardate'",
@include_values = 0,
@delete_if_not_matched = 0;

/*
-- INSERT INTO
--   [powerschool].[course_enrollments_archive] (
--     [studentid],
--     [schoolid],
--     [termid],
--     [cc_id],
--     [course_number],
--     [section_number],
--     [dateenrolled],
--     [dateleft],
--     [lastgradeupdate],
--     [sectionid],
--     [expression],
--     [yearid],
--     [academic_year],
--     [student_number],
--     [students_dcid],
--     [credittype],
--     [course_name],
--     [credit_hours],
--     [gradescaleid],
--     [excludefromgpa],
--     [excludefromstoredgrades],
--     [teachernumber],
--     [teacher_name],
--     [section_enroll_status],
--     [map_measurementscale],
--     [illuminate_subject],
--     [abs_sectionid],
--     [abs_termid],
--     [course_enroll_status],
--     [sections_dcid],
--     [rn_subject],
--     [rn_course_yr],
--     [rn_illuminate_subject]
--   )
-- SELECT
--   [studentid],
--   [schoolid],
--   [termid],
--   [cc_id],
--   [course_number],
--   [section_number],
--   [dateenrolled],
--   [dateleft],
--   [lastgradeupdate],
--   [sectionid],
--   [expression],
--   [yearid],
--   [academic_year],
--   [student_number],
--   [students_dcid],
--   [credittype],
--   [course_name],
--   [credit_hours],
--   [gradescaleid],
--   [excludefromgpa],
--   [excludefromstoredgrades],
--   [teachernumber],
--   [teacher_name],
--   [section_enroll_status],
--   [map_measurementscale],
--   [illuminate_subject],
--   [abs_sectionid],
--   [abs_termid],
--   [course_enroll_status],
--   [sections_dcid],
--   [rn_subject],
--   [rn_course_yr],
--   [rn_illuminate_subject]
-- FROM
--   [powerschool].[course_enrollments_current_static];
--*/
/*
TRUNCATE TABLE powerschool.attendance_clean_current_static;
TRUNCATE TABLE powerschool.cohort_identifiers_scaffold_current_static;
TRUNCATE TABLE powerschool.course_section_scaffold_current_static;
TRUNCATE TABLE powerschool.gradebook_assignments_current_static;
TRUNCATE TABLE powerschool.gradebook_assignments_scores_current_static;
TRUNCATE TABLE powerschool.ps_adaadm_daily_ctod_current_static;
TRUNCATE TABLE powerschool.ps_attendance_daily_current_static;
TRUNCATE TABLE powerschool.ps_membership_reg_current_static;
TRUNCATE TABLE tableau.attendance_dashboard_current_static;
TRUNCATE TABLE powerschool.course_enrollments_current_static;
*/
