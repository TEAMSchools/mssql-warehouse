USE KIPP_NJ
GO

ALTER VIEW DL$promo_status#extract AS 

SELECT student_number
      ,academic_year
      ,term
      ,promo_status_overall
      ,promo_status_attendance
      ,promo_status_lit
      ,promo_status_grades      
      ,promo_status_credits     

      ,att_pts_pct

      ,GPA_term
      ,GPA_Y1
      ,GPA_cum
      ,GPA_term_status
      ,GPA_Y1_status
      ,GPA_cum_status
      
      ,projected_credits_earned_cum AS projected_credits_earned
      ,credits_enrolled_cum AS credits_enrolled

      ,HWQ_Y1
      ,lvls_grown_yr AS reading_lvl_growth_y1
FROM KIPP_NJ..PROMO$promo_status WITH(NOLOCK)
WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()