/* gabby */
EXEC gabby.dbo.sp_generate_merge @table_name='ar_goals_current_static'
                                ,@target_table='ar_goals_archive'
                                ,@schema='renaissance'
                                ,@cols_to_join_on="'student_number','academic_year','reporting_term'"
                                ,@include_values=0
                                ,@delete_if_not_matched=0;
EXEC gabby.dbo.sp_generate_merge @table_name='sight_words_data_current_static'
                                ,@target_table='sight_words_data_archive'
                                ,@schema='illuminate_dna_repositories'
                                ,@cols_to_join_on="'repository_id','repository_row_id','label'"
                                ,@include_values=0
                                ,@delete_if_not_matched=0;
EXEC gabby.dbo.sp_generate_merge @table_name='ar_time_series_current_static'
                                ,@target_table='ar_time_series_archive'
                                ,@schema='tableau'
                                ,@cols_to_join_on="'student_number','date'"
                                ,@include_values=0
                                ,@delete_if_not_matched=0;
EXEC gabby.dbo.sp_generate_merge @table_name='student_assessment_scaffold_current_static'
                                ,@target_table='student_assessment_scaffold_archive'
                                ,@schema='illuminate_dna_assessments'
                                ,@cols_to_join_on="'assessment_id','student_id'"
                                ,@include_values=0
                                ,@delete_if_not_matched=0;
EXEC gabby.dbo.sp_generate_merge @table_name='agg_student_responses_all_current'
                                ,@target_table='agg_student_responses_all_archive'
                                ,@schema='illuminate_dna_assessments'
                                ,@cols_to_join_on="'assessment_id','standard_id','local_student_id','is_replacement','response_type'"
                                ,@include_values=0
                                ,@delete_if_not_matched=0;
/*
TRUNCATE TABLE gabby.renaissance.ar_goals_current_static;
TRUNCATE TABLE gabby.illuminate_dna_repositories.sight_words_data_current_static;
TRUNCATE TABLE gabby.tableau.ar_time_series_current_static;
TRUNCATE TABLE gabby.illuminate_dna_assessments.student_assessment_scaffold_current_static;
*/

/* kippnewark */
EXEC kippnewark.dbo.sp_generate_merge @table_name='attendance_clean_current_static'
                                     ,@target_table='attendance_clean_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'id'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='cohort_identifiers_scaffold_current_static'
                                     ,@target_table='cohort_identifiers_scaffold_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'student_number','date'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='course_section_scaffold_current_static'
                                     ,@target_table='course_section_scaffold_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','yearid','sectionid','term_name','course_number','gradescaleid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='gradebook_assignments_current_static'
                                     ,@target_table='gradebook_assignments_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'assignmentsectionid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='gradebook_assignments_scores_current_static'
                                     ,@target_table='gradebook_assignments_scores_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentsdcid','assignmentsectionid','assignmentid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='ps_adaadm_daily_ctod_current_static'
                                     ,@target_table='ps_adaadm_daily_ctod_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='ps_attendance_daily_current_static'
                                     ,@target_table='ps_attendance_daily_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'id'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='ps_membership_reg_current_static'
                                     ,@target_table='ps_membership_reg_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippnewark.dbo.sp_generate_merge @table_name='attendance_dashboard_current_static'
                                     ,@target_table='attendance_dashboard_archive'
                                     ,@schema='tableau'
                                     ,@cols_to_join_on="'student_number','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
INSERT INTO [kippnewark].[powerschool].[course_enrollments_archive] (
   [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
  ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
  ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
  ,[rn_illuminate_subject]
 )
SELECT [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
      ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
      ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
      ,[rn_illuminate_subject]
FROM [kippnewark].[powerschool].[course_enrollments_current_static];
/*
TRUNCATE TABLE kippnewark.powerschool.attendance_clean_current_static;
TRUNCATE TABLE kippnewark.powerschool.cohort_identifiers_scaffold_current_static;
TRUNCATE TABLE kippnewark.powerschool.course_section_scaffold_current_static;
TRUNCATE TABLE kippnewark.powerschool.gradebook_assignments_current_static;
TRUNCATE TABLE kippnewark.powerschool.gradebook_assignments_scores_current_static;
TRUNCATE TABLE kippnewark.powerschool.ps_adaadm_daily_ctod_current_static;
TRUNCATE TABLE kippnewark.powerschool.ps_attendance_daily_current_static;
TRUNCATE TABLE kippnewark.powerschool.ps_membership_reg_current_static;
TRUNCATE TABLE kippnewark.tableau.attendance_dashboard_current_static;
TRUNCATE TABLE kippnewark.powerschool.course_enrollments_current_static;
*/

/* kippcamden */
EXEC kippcamden.dbo.sp_generate_merge @table_name='attendance_clean_current_static'
                                     ,@target_table='attendance_clean_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'id'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='cohort_identifiers_scaffold_current_static'
                                     ,@target_table='cohort_identifiers_scaffold_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'student_number','date'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='course_section_scaffold_current_static'
                                     ,@target_table='course_section_scaffold_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','yearid','sectionid','term_name','course_number','gradescaleid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='gradebook_assignments_current_static'
                                     ,@target_table='gradebook_assignments_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'assignmentsectionid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='gradebook_assignments_scores_current_static'
                                     ,@target_table='gradebook_assignments_scores_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentsdcid','assignmentsectionid','assignmentid'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='ps_adaadm_daily_ctod_current_static'
                                     ,@target_table='ps_adaadm_daily_ctod_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='ps_attendance_daily_current_static'
                                     ,@target_table='ps_attendance_daily_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'id'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='ps_membership_reg_current_static'
                                     ,@target_table='ps_membership_reg_archive'
                                     ,@schema='powerschool'
                                     ,@cols_to_join_on="'studentid','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
EXEC kippcamden.dbo.sp_generate_merge @table_name='attendance_dashboard_current_static'
                                     ,@target_table='attendance_dashboard_archive'
                                     ,@schema='tableau'
                                     ,@cols_to_join_on="'student_number','calendardate'"
                                     ,@include_values=0
                                     ,@delete_if_not_matched=0;
INSERT INTO [kippcamden].[powerschool].[course_enrollments_archive] (
   [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
  ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
  ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
  ,[rn_illuminate_subject]
 )
SELECT [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
      ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
      ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
      ,[rn_illuminate_subject]
FROM [kippcamden].[powerschool].[course_enrollments_current_static];
/*
TRUNCATE TABLE kippcamden.powerschool.attendance_clean_current_static;
TRUNCATE TABLE kippcamden.powerschool.cohort_identifiers_scaffold_current_static;
TRUNCATE TABLE kippcamden.powerschool.course_section_scaffold_current_static;
TRUNCATE TABLE kippcamden.powerschool.gradebook_assignments_current_static;
TRUNCATE TABLE kippcamden.powerschool.gradebook_assignments_scores_current_static;
TRUNCATE TABLE kippcamden.powerschool.ps_adaadm_daily_ctod_current_static;
TRUNCATE TABLE kippcamden.powerschool.ps_attendance_daily_current_static;
TRUNCATE TABLE kippcamden.powerschool.ps_membership_reg_current_static;
TRUNCATE TABLE kippcamden.tableau.attendance_dashboard_current_static;
TRUNCATE TABLE kippcamden.powerschool.course_enrollments_current_static;
*/

/* kippmiami */
EXEC kippmiami.dbo.sp_generate_merge @table_name='attendance_clean_current_static'
                                    ,@target_table='attendance_clean_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'id'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='cohort_identifiers_scaffold_current_static'
                                    ,@target_table='cohort_identifiers_scaffold_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'student_number','date'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='course_section_scaffold_current_static'
                                    ,@target_table='course_section_scaffold_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'studentid','yearid','sectionid','term_name','course_number','gradescaleid'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='gradebook_assignments_current_static'
                                    ,@target_table='gradebook_assignments_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'assignmentsectionid'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='gradebook_assignments_scores_current_static'
                                    ,@target_table='gradebook_assignments_scores_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'studentsdcid','assignmentsectionid','assignmentid'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='ps_adaadm_daily_ctod_current_static'
                                    ,@target_table='ps_adaadm_daily_ctod_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'studentid','calendardate'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='ps_attendance_daily_current_static'
                                    ,@target_table='ps_attendance_daily_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'id'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='ps_membership_reg_current_static'
                                    ,@target_table='ps_membership_reg_archive'
                                    ,@schema='powerschool'
                                    ,@cols_to_join_on="'studentid','calendardate'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
EXEC kippmiami.dbo.sp_generate_merge @table_name='attendance_dashboard_current_static'
                                    ,@target_table='attendance_dashboard_archive'
                                    ,@schema='tableau'
                                    ,@cols_to_join_on="'student_number','calendardate'"
                                    ,@include_values=0
                                    ,@delete_if_not_matched=0;
INSERT INTO [kippmiami].[powerschool].[course_enrollments_archive] (
   [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
  ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
  ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
  ,[rn_illuminate_subject]
 )
SELECT [studentid],[schoolid],[termid],[cc_id],[course_number],[section_number],[dateenrolled],[dateleft],[lastgradeupdate],[sectionid],[expression],[yearid],[academic_year]
      ,[student_number],[students_dcid],[credittype],[course_name],[credit_hours],[gradescaleid],[excludefromgpa],[excludefromstoredgrades],[teachernumber],[teacher_name]
      ,[section_enroll_status],[map_measurementscale],[illuminate_subject],[abs_sectionid],[abs_termid],[course_enroll_status],[sections_dcid],[rn_subject],[rn_course_yr]
      ,[rn_illuminate_subject]
FROM [kippmiami].[powerschool].[course_enrollments_current_static];
/*
TRUNCATE TABLE kippmiami.powerschool.attendance_clean_current_static;
TRUNCATE TABLE kippmiami.powerschool.cohort_identifiers_scaffold_current_static;
TRUNCATE TABLE kippmiami.powerschool.course_section_scaffold_current_static;
TRUNCATE TABLE kippmiami.powerschool.gradebook_assignments_current_static;
TRUNCATE TABLE kippmiami.powerschool.gradebook_assignments_scores_current_static;
TRUNCATE TABLE kippmiami.powerschool.ps_adaadm_daily_ctod_current_static;
TRUNCATE TABLE kippmiami.powerschool.ps_attendance_daily_current_static;
TRUNCATE TABLE kippmiami.powerschool.ps_membership_reg_current_static;
TRUNCATE TABLE kippmiami.tableau.attendance_dashboard_current_static;
TRUNCATE TABLE kippmiami.powerschool.course_enrollments_current_static;
*/