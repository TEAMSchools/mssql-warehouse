USE KIPP_NJ
GO

ALTER VIEW DL$transcript_gpas#extract AS

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
          SELECT s.student_number
                ,sg.academic_year
                ,sg.potentialcrhrs           
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points      
                ,(sg.potentialcrhrs * scale_unweighted.grade_points) AS unweighted_points
          FROM KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
          JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
            ON sg.STUDENTID = s.ID
          LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale_unweighted WITH(NOLOCK)
            ON sg.[percent] >= scale_unweighted.low_cut
           AND sg.[percent] < scale_unweighted.high_cut
           AND CASE
                WHEN sg.schoolid != 73253 THEN sg.GRADESCALE_NAME
                WHEN sg.academic_year <= 2015 THEN 'NCA 2011' /* default pre-2016 */
                WHEN sg.academic_year >= 2016 THEN 'KIPP NJ 2016 (5-12)' /* default 2016+ */
               END = scale_unweighted.scale_name
          WHERE sg.academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND sg.EXCLUDEFROMGPA = 0
         ) sub
     GROUP BY student_number     
             ,academic_year
    ) sub

UNION ALL

SELECT co.student_number
      ,co.year AS academic_year
      ,sg.cumulative_y1_gpa AS GPA_Y1_weighted
      ,sg.cumulative_y1_gpa_unweighted AS GPA_Y1_unweighted
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..GRADES$GPA_cumulative#static sg WITH(NOLOCK)
  ON co.studentid = sg.studentid
 AND co.schoolid = sg.schoolid
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1