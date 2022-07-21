SELECT 'f_and_p' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_on_level AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_on_level AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_on_level AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_on_level AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_on_level AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT ats.academic_year
	      ,ats.schoolid
	      ,co.iep_status
	      ,co.gender
		  ,STR(ats.grade_level) AS grade_band
		  ,CASE WHEN ats.grade_level = 0 AND ats.indep_lvl_num > 4 THEN 1
		        WHEN ats.grade_level = 1 AND ats.indep_lvl_num > 9 THEN 1
		        WHEN ats.grade_level = 2 AND ats.indep_lvl_num > 13 THEN 1
		        WHEN ats.grade_level = 3 AND ats.indep_lvl_num > 16 THEN 1
		        WHEN ats.grade_level = 4 AND ats.indep_lvl_num > 19 THEN 1
		     ELSE 0 END AS is_on_level
	
	FROM gabby.lit.achieved_by_round_static ats
	LEFT JOIN gabby.powerschool.cohort_identifiers_static co
	  ON ats.student_number = co.student_number
	 AND ats.academic_year = co.academic_year
	 AND co.is_enrolled_recent = 1
		
	WHERE ats.academic_year >= gabby.utilities.global_academic_year() - 2
	  AND ats.is_curterm = 1
	  AND ats.grade_level <= 4
	)sub
	
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band

UNION

SELECT 'hs_gpa' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.pct_met_goal AS float)),2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT gpa.academic_year
		  ,gpa.schoolid
		  ,co.iep_status
		  ,co.gender
		  ,'HS' AS grade_band
	      ,CASE WHEN gpa.gpa_y1 >= 3 THEN 1
	         ELSE 0 END AS pct_met_goal
	
	FROM powerschool.gpa_detail gpa
	LEFT JOIN powerschool.cohort_identifiers_static co
	  ON gpa.student_number = co.student_number
	 AND gpa.academic_year = co.academic_year
	 AND co.is_enrolled_recent = 1
	
	WHERE gpa.academic_year >= gabby.utilities.global_academic_year() - 2
	  AND gpa.is_curterm = 1
	  AND gpa.grade_level >= 9
	)sub

GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band
        
UNION

SELECT 'ms_gpa' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.pct_met_goal AS float)),2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.pct_met_goal AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT gpa.academic_year
		  ,gpa.schoolid
		  ,co.iep_status
		  ,co.gender
		  ,'MS' AS grade_band
	      ,CASE WHEN gpa.gpa_y1 >= 3 THEN 1
	         ELSE 0 END AS pct_met_goal
	
	FROM powerschool.gpa_detail gpa
	LEFT JOIN powerschool.cohort_identifiers_static co
	  ON gpa.student_number = co.student_number
	 AND gpa.academic_year = co.academic_year
	 AND co.is_enrolled_recent = 1
	
	WHERE gpa.academic_year >= gabby.utilities.global_academic_year() - 2
	  AND gpa.is_curterm = 1
	  AND gpa.grade_level BETWEEN 5 AND 8
	)sub

GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band

UNION

SELECT 'i-ready_typical_math' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_typ_growth AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_m
FROM
	(
	SELECT co.academic_year
		  ,'ALL' AS grade_band
		  ,co.schoolid
		  ,co.iep_status
		  ,co.gender
	      ,CASE WHEN gm.progress_typical >= 1 THEN 1 
	         ELSE 0 END AS is_typ_growth
	FROM gabby.powerschool.cohort_identifiers_static co
	LEFT JOIN gabby.iready.growth_metrics gm
	  ON co.student_number = gm.student_number
	 AND co.academic_year = gm.academic_year
	 AND gm.[subject] = 'Math'
	WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND co.rn_year = 1
	  AND co.grade_level <= 8
	  AND co.is_enrolled_recent = 1
	)sub
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
UNION

SELECT 'i-ready_typical_read' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_typ_growth AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_typ_growth AS float) ELSE NULL END), 2) AS pct_met_m
FROM
	(
	SELECT co.academic_year
		  ,'ALL' AS grade_band
		  ,co.schoolid
		  ,co.iep_status
		  ,co.gender
	      ,CASE WHEN gm.progress_typical >= 1 THEN 1 
	         ELSE 0 END AS is_typ_growth
	FROM gabby.powerschool.cohort_identifiers_static co
	LEFT JOIN gabby.iready.growth_metrics gm
	  ON co.student_number = gm.student_number
	 AND co.academic_year = gm.academic_year
	 AND gm.[subject] = 'Reading'
	WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND co.rn_year = 1
	  AND co.grade_level BETWEEN 5 AND 8
	  AND co.is_enrolled_recent = 1
	)sub
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
	   
UNION

SELECT 'i-ready_on_grade_math' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_on_grade AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_m
      
FROM
	(
	SELECT co.academic_year
		  ,STR(co.grade_level) AS grade_band
	      ,co.schoolid
	      ,co.iep_status
	      ,co.gender
	      ,di.diagnostic_overall_relative_placement_most_recent_
 	      ,CASE WHEN di.diagnostic_overall_relative_placement_most_recent_ IN ('On Level', 'Above Level') THEN 1
 	         ELSE 0 END AS is_on_grade
	
	FROM gabby.iready.diagnostic_and_instruction di
	LEFT JOIN gabby.powerschool.cohort_identifiers_static co
	  ON di.student_id = co.student_number
	 AND LEFT(di.academic_year, 4) = co.academic_year
	
	WHERE di.[subject] = 'Math'
	  AND co.grade_level <= 2
	  AND co.is_enrolled_recent = 1
	  AND co.academic_year >= gabby.utilities.global_academic_year() - 2
	)sub
	
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
	    
UNION

SELECT 'i-ready_on_grade_read' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_on_grade AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_on_grade AS float) ELSE NULL END), 2) AS pct_met_m
      
FROM
	(
	SELECT co.academic_year
		  ,STR(co.grade_level) AS grade_band
	      ,co.schoolid
	      ,co.iep_status
	      ,co.gender
	      ,di.diagnostic_overall_relative_placement_most_recent_
 	      ,CASE WHEN di.diagnostic_overall_relative_placement_most_recent_ IN ('On Level', 'Above Level') THEN 1
 	         ELSE 0 END AS is_on_grade
	
	FROM gabby.iready.diagnostic_and_instruction di
	LEFT JOIN gabby.powerschool.cohort_identifiers_static co
	  ON di.student_id = co.student_number
	 AND LEFT(di.academic_year, 4) = co.academic_year
	
	WHERE di.[subject] = 'Reading'
	  AND co.grade_level <= 2
	  AND co.is_enrolled_recent = 1
	  AND co.academic_year >= gabby.utilities.global_academic_year() - 2
	)sub
	
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
	    
UNION

SELECT 'ada' AS domain
	  ,co.academic_year
      ,co.schoolid
      ,'ALL' AS grade_band	  
      ,ROUND(AVG(CONVERT(FLOAT, mem.attendancevalue)), 3) AS pct_met_goal
	  ,ROUND(AVG(CASE WHEN co.iep_status = 'SPED' THEN CAST(mem.attendancevalue AS float) ELSE NULL END), 2) AS pct_met_iep
	  ,ROUND(AVG(CASE WHEN co.iep_status <> 'SPED' THEN CAST(mem.attendancevalue AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN co.gender = 'F' THEN CAST(mem.attendancevalue AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN co.gender = 'M' THEN CAST(mem.attendancevalue AS float) ELSE NULL END), 2) AS pct_met_m

FROM gabby.powerschool.ps_adaadm_daily_ctod_current_static mem
LEFT JOIN gabby.powerschool.cohort_identifiers_static co
  ON mem.studentid = co.studentid
 AND mem.[db_name] = co.[db_name]
WHERE mem.membershipvalue = 1
  AND mem.calendardate <= GETDATE()
  AND co.academic_year >= gabby.utilities.global_academic_year() - 2
  AND co.is_enrolled_y1 = 1
  AND co.rn_year = 1
GROUP BY co.academic_year
        ,co.schoolid
          
UNION

SELECT 'suspension' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_suspended AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_suspended AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_suspended AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_suspended AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_suspended AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT co.academic_year
	      ,'ALL' AS grade_band
	      ,co.schoolid
		  ,co.iep_status
		  ,co.gender
		  ,CASE WHEN ips.issuspension IS NULL THEN 0
		     ELSE ips.issuspension END AS is_suspended
	
	FROM gabby.powerschool.cohort_identifiers_static co
	LEFT JOIN gabby.deanslist.incidents_clean_static ics
	  ON co.student_number = ics.student_school_id
	 AND co.academic_year = ics.create_academic_year
	LEFT JOIN gabby.deanslist.incidents_penalties_static ips
	  ON ips.incident_id = ics.incident_id
	 AND ips.[db_name] = ics.[db_name]
	 AND ips.issuspension = 1
	
	WHERE co.rn_year = 1
	  AND co.is_enrolled_y1 = 1
	  AND co.academic_year >= gabby.utilities.global_academic_year() - 2
	 )sub
	 
GROUP BY sub.academic_year
        ,sub.schoolid
        ,sub.grade_band
        
UNION

SELECT 'act' AS domain
	  ,co.academic_year
      ,co.schoolid
      ,STR(co.grade_level) AS grade_band
      ,ROUND(AVG(CAST(sub.is_act_20 AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN co.iep_status = 'SPED' THEN CAST(sub.is_act_20 AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN co.iep_status <> 'SPED' THEN CAST(sub.is_act_20 AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN co.gender = 'F' THEN CAST(sub.is_act_20 AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN co.gender = 'M' THEN CAST(sub.is_act_20 AS float) ELSE NULL END), 2) AS pct_met_m

FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN
	(
	SELECT ktc.student_number
	      ,CASE WHEN MAX(stl.score) >= 20 THEN 1 ELSE 0 END AS is_act_20
	
	FROM gabby.alumni.standardized_test_long stl
	LEFT JOIN gabby.alumni.ktc_roster ktc
	  ON ktc.sf_contact_id = stl.contact_c
	 AND stl.test_type = 'ACT'
	 AND stl.score_type = 'act_composite_c'
	
	WHERE stl.test_type = 'ACT'
	  AND stl.score_type = 'act_composite_c'

	 
	GROUP BY ktc.student_number
	)sub ON sub.student_number = co.student_number
	
WHERE co.academic_year >= gabby.utilities.global_academic_year() - 2
  AND co.grade_level IN (11, 12)
  AND co.rn_year = 1
  AND co.is_enrolled_y1 = 1

GROUP BY co.academic_year
      	,co.schoolid
      	,co.grade_level
      	
UNION

SELECT 'njsla_math' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_proficient AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT  co.academic_year
		   ,STR(co.grade_level) AS grade_band
		   ,co.schoolid
		   ,co.iep_status
		   ,co.gender
	       ,CASE WHEN nj.test_performance_level >= 3 THEN 1 ELSE 0 END AS is_proficient
	
	FROM gabby.parcc.summative_record_file_clean nj
	JOIN gabby.powerschool.cohort_identifiers_static co
	  ON nj.local_student_identifier = co.student_number
	 AND nj.academic_year = co.academic_year
	 AND co.grade_level < 9
	
	WHERE nj.academic_year IN (2017, 2018)
	  AND nj.subject IN ('Mathematics', 'Algebra I')
	  )sub
	  
GROUP BY sub.academic_year
      	,sub.schoolid
      	,sub.grade_band
      	
UNION

SELECT 'njsla_ela' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_proficient AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_proficient AS float) ELSE NULL END), 2) AS pct_met_m

FROM
	(
	SELECT  co.academic_year
		   ,STR(co.grade_level) AS grade_band
		   ,co.schoolid
		   ,co.iep_status
		   ,co.gender
	       ,CASE WHEN nj.test_performance_level >= 3 THEN 1 ELSE 0 END AS is_proficient
	
	FROM gabby.parcc.summative_record_file_clean nj
	JOIN gabby.powerschool.cohort_identifiers_static co
	  ON nj.local_student_identifier = co.student_number
	 AND nj.academic_year = co.academic_year
	 AND co.grade_level < 9
	
	WHERE nj.academic_year IN (2017, 2018)
	  AND nj.subject = 'English Language Arts/Literacy'
	  )sub
	  
GROUP BY sub.academic_year
      	,sub.schoolid
      	,sub.grade_band
      	
UNION

SELECT 'i-ready_stretch_math' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_str_growth AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_m
FROM
	(
	SELECT co.academic_year
		  ,'ALL' AS grade_band
		  ,co.schoolid
		  ,co.iep_status
		  ,co.gender
	      ,CASE WHEN gm.progress_stretch >= 1 THEN 1 
	         ELSE 0 END AS is_str_growth
	FROM gabby.powerschool.cohort_identifiers_static co
	LEFT JOIN gabby.iready.growth_metrics gm
	  ON co.student_number = gm.student_number
	 AND co.academic_year = gm.academic_year
	 AND gm.[subject] = 'Math'
	WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND co.rn_year = 1
	  AND co.grade_level <= 8
	  AND co.is_enrolled_recent = 1
	)sub
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band

UNION

SELECT 'i-ready_stretch_read' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(AVG(CAST(sub.is_str_growth AS float)), 2) AS pct_met_goal
      ,ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_iep
      ,ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_no_iep
      ,ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_f
      ,ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_str_growth AS float) ELSE NULL END), 2) AS pct_met_m
FROM
	(
	SELECT co.academic_year
		  ,'ALL' AS grade_band
		  ,co.schoolid
		  ,co.iep_status
		  ,co.gender
	      ,CASE WHEN gm.progress_stretch >= 1 THEN 1 
	         ELSE 0 END AS is_str_growth
	FROM gabby.powerschool.cohort_identifiers_static co
	LEFT JOIN gabby.iready.growth_metrics gm
	  ON co.student_number = gm.student_number
	 AND co.academic_year = gm.academic_year
	 AND gm.[subject] = 'Reading'
	WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND co.rn_year = 1
	  AND co.grade_level BETWEEN 5 AND 8
	  AND co.is_enrolled_recent = 1
	)sub
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
	    
UNION

SELECT 'student_attrition' AS domain
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_band
      ,ROUND(1 - ROUND(AVG(CAST(sub.is_enrolled_next AS float)), 2), 2) AS pct_met_goal
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.iep_status = 'SPED' THEN CAST(sub.is_enrolled_next AS float) ELSE NULL END), 2), 2) AS pct_met_iep
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.iep_status <> 'SPED' THEN CAST(sub.is_enrolled_next AS float) ELSE NULL END), 2), 2) AS pct_met_no_iep
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.gender = 'F' THEN CAST(sub.is_enrolled_next AS float) ELSE NULL END), 2), 2) AS pct_met_f
      ,ROUND(1 - ROUND(AVG(CASE WHEN sub.gender = 'M' THEN CAST(sub.is_enrolled_next AS float) ELSE NULL END), 2), 2) AS pct_met_m
FROM
	(
	SELECT co.schoolid
	      ,co.academic_year
	      ,co.iep_status
	      ,co.gender
		  ,'All' AS grade_band
	      ,CASE WHEN co.exitcode = 'G1' THEN NULL 
	            WHEN co.exitcode IS NULL THEN NULL
	         ELSE LEAD(co.is_enrolled_oct01, 1, 0) OVER(PARTITION BY co.student_number ORDER BY co.academic_year) END AS is_enrolled_next
	FROM gabby.powerschool.cohort_identifiers_static co
	WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND co.is_enrolled_oct01 = 1
	  AND co.rn_year = 1
	 )sub
GROUP BY sub.academic_year
	    ,sub.schoolid
	    ,sub.grade_band
	    
UNION

SELECT 'q12' AS domain
	  ,sub.academic_year
      ,sub.schoolid
      ,'ALL' AS grade_band
      ,ROUND(AVG(CAST(sub.avg_response AS float)), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m

FROM
	(
	SELECT sc.ps_school_id AS schoolid
	      ,cm.campaign_academic_year AS academic_year
	      ,cm.respondent_df_employee_number
	      ,CASE WHEN ROUND(AVG(CAST(cm.answer_value AS float)), 2) >= 4 THEN 1 ELSE 0 END AS avg_response
	
	FROM gabby.surveys.cmo_engagement_regional_survey_detail cm
	JOIN gabby.people.school_crosswalk sc
	  ON cm.respondent_primary_site = sc.site_name
	 AND sc.ps_school_id <> 0
	 AND sc.ps_school_id IS NOT NULL
	
	WHERE cm.campaign_academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
	  AND cm.is_open_ended = 'N'
	  AND cm.question_shortname LIKE '%Q12%'
	   
	GROUP BY sc.ps_school_id
		    ,cm.campaign_academic_year
		    ,cm.respondent_df_employee_number
	)sub
	
GROUP BY sub.academic_year
        ,sub.schoolid
        
UNION

SELECT 'staff_retention' AS domain
	  ,sa.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(1-SUM(sa.is_attrition)/CONVERT(FLOAT,SUM(sa.is_denominator)), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m

FROM gabby.tableau.compliance_staff_attrition sa
JOIN people.school_crosswalk cw
  ON sa.primary_site = cw.site_name
WHERE sa.is_denominator <> 0
  AND sa.primary_job <> 'Intern'
  AND sa.academic_year > (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 4)
  AND cw.ps_school_id <> 0
GROUP BY sa.academic_year, cw.ps_school_id
​
UNION
​
SELECT 'teacger_retention' AS domain
	  ,sa.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(1-SUM(sa.is_attrition)/CONVERT(FLOAT,SUM(sa.is_denominator)), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM gabby.tableau.compliance_staff_attrition sa
JOIN people.school_crosswalk cw
  ON sa.primary_site = cw.site_name
WHERE sa.is_denominator <> 0
  AND sa.primary_job IN ('Co-Teacher'
                     ,'Co-Teacher_HISTORICAL'
                     ,'Learning Specialist'
                     ,'Learning Specialist Coordinator'
                     ,'Teacher'
                     ,'Teacher ESL'
                     ,'Teacher Fellow'
                     ,'Teacher in Residence'
                     ,'Teacher, ESL'
                     ,'Temporary Teacher')
  AND sa.academic_year > (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 4)
  AND cw.ps_school_id <> 0
GROUP BY sa.academic_year, cw.ps_school_id

UNION

SELECT 'etr_average' AS domain
	  ,lb.academic_year
      ,cw.ps_school_id
      ,'ALL' AS grade_band
      ,ROUND(AVG(CASE WHEN metric_value >= 3 THEN 1.0 ELSE 0 END), 2) AS pct_met_goal
      ,NULL AS pct_met_iep
      ,NULL AS pct_met_no_iep
      ,NULL AS pct_met_f
      ,NULL AS pct_met_m
FROM pm.teacher_goals_lockbox_wide lb
JOIN people.employment_history_static eh
  ON lb.df_employee_number = eh.employee_number
 AND lb.pm_term = 'PM4'
 AND DATEFROMPARTS(lb.academic_year+1,4,30) BETWEEN eh.effective_start_date AND eh.effective_end_date
 AND primary_position = 'Yes'
 AND lb.metric_name = 'etr_overall_score'
JOIN people.school_crosswalk cw
  ON eh.location = cw.site_name
WHERE lb.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 2
  AND cw.ps_school_id <> 0
GROUP BY lb.academic_year, cw.ps_school_id