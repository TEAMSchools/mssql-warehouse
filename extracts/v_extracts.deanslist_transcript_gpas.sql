USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_transcript_gpas AS

SELECT student_number
      ,academic_year            
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points / credit_hours)), 2)) AS GPA_Y1_weighted
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(unweighted_points / credit_hours)), 2)) AS GPA_Y1_unweighted
FROM
    (
     SELECT student_number
           ,academic_year
           ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
           ,ROUND(SUM(CONVERT(FLOAT,unweighted_points)),3) AS unweighted_points
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs)) END AS credit_hours
     FROM
         (
          SELECT sg.potentialcrhrs           
                ,(LEFT(sg.termid, 2) + 1990) AS academic_year
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points      
                
                ,s.student_number
                
                ,(sg.potentialcrhrs * scale_unweighted.grade_points) AS unweighted_points                
          FROM gabby.powerschool.storedgrades sg
          JOIN gabby.powerschool.students s
            ON sg.studentid = s.id
          LEFT OUTER JOIN gabby.powerschool.gradescaleitem_lookup_static scale_unweighted
            ON sg.[percent] BETWEEN scale_unweighted.min_cutoffpercentage AND scale_unweighted.max_cutoffpercentage
           AND CASE
                WHEN sg.schoolid != 73253 THEN sg.gradescale_name
                WHEN sg.termid < 2600 THEN 'NCA 2011' /* default pre-2016 */
                WHEN sg.termid >= 2600 THEN 'KIPP NJ 2016 (5-12)' /* default 2016+ */
               END = scale_unweighted.gradescale_name
          WHERE (LEFT(sg.termid, 2) + 1990) < gabby.utilities.GLOBAL_ACADEMIC_YEAR()
            AND sg.storecode = 'Y1'
            AND sg.excludefromgpa = 0
         ) sub
     GROUP BY student_number     
             ,academic_year
    ) sub

UNION ALL

SELECT co.student_number
      ,co.academic_year AS academic_year
      ,sg.cumulative_y1_gpa AS GPA_Y1_weighted
      ,sg.cumulative_y1_gpa_unweighted AS GPA_Y1_unweighted
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.gpa_cumulative sg
  ON co.studentid = sg.studentid
 AND co.schoolid = sg.schoolid
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1