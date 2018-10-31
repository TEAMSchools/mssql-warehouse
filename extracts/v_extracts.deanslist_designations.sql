USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_designations AS

WITH ada AS (
  SELECT psa.studentid
        ,psa.db_name
        ,psa.yearid + 1990 AS academic_year
        ,ROUND(AVG(CAST(psa.attendancevalue AS FLOAT)), 2) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod psa   
  WHERE psa.membershipvalue = 1
    AND psa.calendardate <= CAST(SYSDATETIME() AS DATE)
  GROUP BY psa.studentid
          ,psa.yearid
          ,psa.db_name
 )

,sp AS (
  SELECT p.db_name
        ,p.academic_year
        ,p.studentid
      
        ,p.[NCCS]
        ,p.[Americorps]
        ,p.[Out of District]
        ,p.[Whittier ES]
        ,p.[Pathways MS]
        ,p.[Pathways ES]
        ,p.[Home Instruction]
  FROM
      (
       SELECT sp.db_name
             ,sp.academic_year      
             ,sp.studentid
             ,sp.specprog_name
             ,1 AS n
       FROM gabby.powerschool.spenrollments_gen sp
      ) sub
  PIVOT(
    MAX(n)
    FOR specprog_name IN ([Pathways ES]
                         ,[Pathways MS]
                         ,[Whittier ES]
                         ,[Out of District]
                         ,[Americorps]
                         ,[NCCS]
                         ,[Home Instruction])
   ) p
 )

,designation AS (
  SELECT co.student_number
        ,co.academic_year

        ,CASE WHEN co.iep_status <> 'No IEP' THEN 'IEP' ELSE NULL END AS is_iep 
        ,CASE WHEN co.c_504_status = 1 THEN '504' ELSE NULL END AS is_504
		      ,CASE WHEN co.lep_status = 1 THEN 'LEP' ELSE NULL END AS is_lep 
        
        ,CASE WHEN gpa.gpa_term >= 3 THEN 'Quarter GPA 3.0+' ELSE NULL END AS is_quarter_gpa_3plus
        ,CASE WHEN gpa.gpa_term >= 3.5 THEN 'Quarter GPA 3.5+' ELSE NULL END AS is_quarter_gpa_35plus


        ,CASE WHEN sp.[Out of District] IS NOT NULL THEN 'Out-of-District Placement' ELSE NULL END AS is_ood
        ,CASE WHEN sp.[NCCS] IS NOT NULL THEN 'NCCS' ELSE NULL END AS is_nccs
        ,CASE WHEN sp.[Pathways MS] IS NOT NULL OR sp.[Pathways ES] IS NOT NULL THEN 'Pathways' ELSE NULL END AS is_pathways
        ,CASE WHEN sp.[Home Instruction] IS NOT NULL THEN 'Home Instruction' ELSE NULL END AS is_home_instruction
        
        ,CASE WHEN ada.ada < 0.9 THEN 'Chronic Absence' ELSE NULL END AS is_chronic_absentee
  FROM gabby.powerschool.cohort_identifiers_static co
  LEFT JOIN gabby.powerschool.gpa_detail gpa
    ON co.student_number = gpa.student_number
   AND co.academic_year = gpa.academic_year
   AND co.db_name = gpa.db_name
   AND gpa.is_curterm = 1
  LEFT JOIN sp
    ON co.studentid = sp.studentid
   AND co.academic_year = sp.academic_year
   AND co.db_name = sp.db_name
  LEFT JOIN ada
    ON co.studentid = ada.studentid
   AND co.academic_year = ada.academic_year
   AND co.db_name = ada.db_name
  WHERE co.rn_year = 1
 )

SELECT student_number
      ,academic_year            
      ,value AS designation_name
FROM (
      SELECT student_number          
            ,academic_year

            ,CAST(is_iep AS VARCHAR(250)) AS is_iep
            ,CAST(is_504 AS VARCHAR(250)) AS is_504
            ,CAST(is_lep AS VARCHAR(250)) AS is_lep
            ,CAST(is_quarter_gpa_3plus AS VARCHAR(250)) AS is_quarter_gpa_3plus
			,CAST(is_quarter_gpa_35plus AS VARCHAR(250)) AS is_quarter_gpa_35plus
            ,CAST(is_ood AS VARCHAR(250)) AS is_ood
            ,CAST(is_nccs AS VARCHAR(250)) AS is_nccs
            ,CAST(is_pathways AS VARCHAR(250)) AS is_pathways
            ,CAST(is_home_instruction AS VARCHAR(250)) AS is_home_instruction
            ,CAST(is_chronic_absentee AS VARCHAR(250)) AS is_chronic_absentee
      FROM designation
      WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
     ) sub
UNPIVOT (
  value
  FOR field IN (is_iep, is_504, is_lep, is_quarter_gpa_3plus, is_quarter_gpa_35plus, is_ood, is_nccs, is_pathways, is_home_instruction, is_chronic_absentee)
 ) u