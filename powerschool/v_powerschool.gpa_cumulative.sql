CREATE OR ALTER VIEW powerschool.gpa_cumulative AS

SELECT studentid
      ,schoolid
      
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points / potentialcrhrs)), 2)) AS cumulative_Y1_gpa
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(unweighted_points / potentialcrhrs)), 2)) AS cumulative_Y1_gpa_unweighted
      ,earned_credits_cum      
      ,potential_credits_cum

      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points_projected / credit_hours_projected)), 2)) AS cumulative_Y1_gpa_projected
      ,earned_credits_cum_projected

      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points_projected_s1 / credit_hours_projected_s1)), 2)) AS cumulative_Y1_gpa_projected_s1
      ,earned_credits_cum_projected_s1
FROM
    (
     SELECT studentid AS studentid
           ,schoolid AS schoolid
           
           ,SUM(CASE WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() THEN earnedcrhrs ELSE potentialcrhrs END) AS potential_credits_cum                       
           ,SUM(CONVERT(FLOAT,unweighted_points)) AS unweighted_points

           ,SUM(CONVERT(FLOAT,weighted_points)) AS weighted_points           
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs)) END AS potentialcrhrs
           ,SUM(earnedcrhrs) AS earned_credits_cum           

           ,SUM(CONVERT(FLOAT,weighted_points_projected)) AS weighted_points_projected
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs_projected)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs_projected)) END AS credit_hours_projected
           ,SUM(earnedcrhrs_projected) AS earned_credits_cum_projected

           ,SUM(CONVERT(FLOAT,weighted_points_projected_s1)) AS weighted_points_projected_s1
           ,CASE WHEN SUM(CONVERT(FLOAT,potentialcrhrs_projected_s1)) = 0 THEN NULL ELSE SUM(CONVERT(FLOAT,potentialcrhrs_projected_s1)) END AS credit_hours_projected_s1
           ,SUM(earnedcrhrs_projected_s1) AS earned_credits_cum_projected_s1
     FROM 
         (
          SELECT CONVERT(INT,sg.studentid) AS studentid
                ,(LEFT(sg.termid, 2) + 1990) AS academic_year
                ,CONVERT(INT,sg.schoolid) AS schoolid
                ,sg.course_number
                ,sg.potentialcrhrs                   
                ,sg.earnedcrhrs                   
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points
                ,(sg.potentialcrhrs * scale_unweighted.grade_points) AS unweighted_points
                
                ,sg.potentialcrhrs AS potentialcrhrs_projected
                ,sg.earnedcrhrs AS earnedcrhrs_projected
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points_projected

                ,sg.potentialcrhrs AS potentialcrhrs_projected_s1
                ,sg.earnedcrhrs AS earnedcrhrs_projected_s1
                ,(sg.potentialcrhrs * sg.gpa_points) AS weighted_points_projected_s1
          FROM powerschool.storedgrades sg
          LEFT JOIN powerschool.gradescaleitem_lookup_static scale_unweighted 
            ON sg.[percent] BETWEEN scale_unweighted.min_cutoffpercentage AND scale_unweighted.max_cutoffpercentage
           AND CASE
                WHEN sg.schoolid != 73253 THEN sg.gradescale_name
                WHEN sg.termid < 2600 THEN 'NCA 2011' /* default pre-2016 */
                WHEN sg.termid >= 2600 THEN 'KIPP NJ 2016 (5-12)' /* default 2016+ */
               END = scale_unweighted.gradescale_name
          WHERE sg.storecode = 'Y1'
            AND sg.excludefromgpa = 0
          
          UNION ALL

          SELECT CONVERT(INT,gr.studentid) AS studentid
                ,gr.academic_year
                ,gr.schoolid
                ,gr.course_number
                ,NULL AS potentialcrhrs
                ,NULL AS earnedcrhrs
                ,NULL AS weighted_points
                ,NULL AS unweighted_points
                
                ,gr.credit_hours AS potentialcrhrs_projected
                ,CASE WHEN gr.y1_grade_letter NOT LIKE 'F%' THEN gr.credit_hours ELSE 0 END AS earnedcrhrs_projected
                ,(gr.credit_hours * gr.y1_gpa_points) AS weighted_points_projected

                ,NULL AS potentialcrhrs_projected_s1
                ,NULL AS earnedcrhrs_projected_s1
                ,NULL AS weighted_points_projected_s1
          FROM powerschool.final_grades_static gr 
          LEFT JOIN powerschool.storedgrades sg 
             ON gr.studentid = sg.studentid
            AND gr.course_number = sg.course_number
            AND gr.academic_year = (LEFT(sg.termid, 2) + 1990)
            AND sg.storecode = 'Y1'           
          WHERE gr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
            AND gr.is_curterm = 1
            AND gr.excludefromgpa = 0
            AND sg.studentid IS NULL /* ensures already stored grades are excluded */

          UNION ALL

          SELECT CONVERT(INT,gr.studentid) AS studentid
                ,gr.academic_year
                ,gr.schoolid
                ,gr.course_number
                ,NULL AS potentialcrhrs
                ,NULL AS earnedcrhrs
                ,NULL AS weighted_points
                ,NULL AS unweighted_points
                
                ,NULL AS potentialcrhrs_projected
                ,NULL AS earnedcrhrs_projected
                ,NULL AS weighted_points_projected

                ,gr.credit_hours AS potentialcrhrs_projected_s1
                ,CASE WHEN gr.y1_grade_letter NOT LIKE 'F%' THEN gr.credit_hours ELSE 0 END AS earnedcrhrs_projected_s1
                ,(gr.credit_hours * gr.y1_gpa_points) AS weighted_points_projected_s1
          FROM powerschool.final_grades_static gr 
          LEFT JOIN powerschool.storedgrades sg 
            ON gr.studentid = sg.studentid
           AND gr.course_number = sg.course_number
           AND gr.academic_year = (LEFT(sg.termid, 2) + 1990)
           AND sg.storecode = 'Y1'           
          WHERE gr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
            AND gr.term_name = 'Q2' /* Y1 as of Q2 (aka Semester 1) */
            AND gr.excludefromgpa = 0
            AND sg.studentid IS NULL /* ensures already stored grades are excluded */
         ) sub
     GROUP BY studentid, schoolid
    ) sub