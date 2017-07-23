WITH ps_scores_long AS (
  SELECT unique_id      
        ,testid
        ,student_number
        ,read_lvl
        ,status
        ,field
        ,score
  FROM
      (
       SELECT unique_id      
             ,testid
             ,student_number
             ,CASE WHEN academic_year = 2015 AND testid = 3273 THEN instruct_lvl ELSE read_lvl END AS read_lvl
             ,ISNULL(status,'Did Not Achieve') AS status
             ,CONVERT(VARCHAR,name_ass) AS name_ass
             ,CONVERT(VARCHAR,ltr_nameid) AS ltr_nameid
             ,CONVERT(VARCHAR,ltr_soundid) AS ltr_soundid
             ,CONVERT(VARCHAR,pa_rhymingwds) AS pa_rhymingwds
             ,CONVERT(VARCHAR,pa_mfs) AS pa_mfs
             ,CONVERT(VARCHAR,pa_segmentation) AS pa_segmentation
             ,CONVERT(VARCHAR,cp_orient) AS cp_orient
             ,CONVERT(VARCHAR,cp_121_match) AS cp_121match
             ,CONVERT(VARCHAR,cp_slw) AS cp_slw
             ,CONVERT(VARCHAR,devsp_first) AS devsp_first
             ,CONVERT(VARCHAR,devsp_svs) AS devsp_svs
             ,CONVERT(VARCHAR,devsp_final) AS devsp_final             
             ,CONVERT(VARCHAR,devsp_ifbd) AS devsp_ifbd
             ,CONVERT(VARCHAR,devsp_longvowel) AS devsp_longvowel
             ,CONVERT(VARCHAR,devsp_rcontrol) AS devsp_rcontrol                          
             ,CONVERT(VARCHAR,devsp_vowldig) AS devsp_vowldig
             ,CONVERT(VARCHAR,devsp_cmplxb) AS devsp_cmplxb
             ,CONVERT(VARCHAR,devsp_eding) AS devsp_eding
             ,CONVERT(VARCHAR,devsp_doubsylj) AS devsp_doubsylj             
             ,CONVERT(VARCHAR,rr_121_match) AS rr_121match
             ,CONVERT(VARCHAR,rr_holdspattern) AS rr_holdspattern
             ,CONVERT(VARCHAR,rr_understanding) AS rr_understanding             
             ,CONVERT(VARCHAR,accuracy_1_a) AS accuracy_1a
             ,CONVERT(VARCHAR,accuracy_2_b) AS accuracy_2b
             ,CONVERT(VARCHAR,ra_errors) AS ra_errors
             ,CONVERT(VARCHAR,cc_factual) AS cc_factual
             ,CONVERT(VARCHAR,cc_infer) AS cc_infer
             ,CONVERT(VARCHAR,cc_other) AS cc_other
             ,CONVERT(VARCHAR,cc_ct) AS cc_ct
             ,CONVERT(VARCHAR,ocomp_factual) AS ocomp_factual
             ,CONVERT(VARCHAR,ocomp_ct) AS ocomp_ct
             ,CONVERT(VARCHAR,ocomp_infer) AS ocomp_infer
             ,CONVERT(VARCHAR,scomp_factual) AS scomp_factual
             ,CONVERT(VARCHAR,scomp_infer) AS scomp_infer
             ,CONVERT(VARCHAR,scomp_ct) AS scomp_ct
             ,CONVERT(VARCHAR,wcomp_fact) AS wcomp_fact
             ,CONVERT(VARCHAR,wcomp_infer) AS wcomp_infer
             ,CONVERT(VARCHAR,wcomp_ct) AS wcomp_ct
             ,CONVERT(VARCHAR,retelling) AS retelling             
             ,CONVERT(VARCHAR,
                CASE
                 WHEN testid = 3397 AND reading_rate IN ('Above','Target') THEN 30
                 WHEN testid IN (3411,3425) AND reading_rate IN ('Above','Target') THEN 40
                 WHEN testid IN (3442,3458,3474) AND reading_rate IN ('Above','Target') THEN 50
                 WHEN testid IN (3493,3511,3527) AND reading_rate IN ('Above','Target') THEN 75        
                END) AS reading_rate             
             ,CONVERT(VARCHAR,fluency) AS fluency
             ,CONVERT(VARCHAR,ROUND(fp_wpmrate,0)) AS fp_wpmrate
             ,CONVERT(VARCHAR,fp_fluency) AS fp_fluency
             ,CONVERT(VARCHAR,fp_accuracy) AS fp_accuracy
             ,CONVERT(VARCHAR,fp_comp_within) AS fp_comp_within
             ,CONVERT(VARCHAR,fp_comp_beyond) AS fp_comp_beyond
             ,CONVERT(VARCHAR,fp_comp_about) AS fp_comp_about           
             ,CONVERT(VARCHAR,cc_prof) AS cc_prof
             ,CONVERT(VARCHAR,ocomp_prof) AS ocomp_prof
             ,CONVERT(VARCHAR,scomp_prof) AS scomp_prof
             ,CONVERT(VARCHAR,wcomp_prof) AS wcomp_prof
             ,CONVERT(VARCHAR,fp_comp_prof) AS fp_comp_prof
             ,CONVERT(VARCHAR,cp_prof) AS cp_prof
             ,CONVERT(VARCHAR,rr_prof) AS rr_prof
             ,CONVERT(VARCHAR,devsp_prof) AS devsp_prof             
       FROM gabby.lit.powerschool_readingscores_archive rs
       JOIN gabby.powerschool.students s
         ON rs.studentid = s.id
      ) sub
  UNPIVOT (
    score
    FOR field IN (name_ass
                 ,ltr_nameid
                 ,ltr_soundid
                 ,pa_rhymingwds
                 ,pa_mfs
                 ,pa_segmentation
                 ,cp_orient
                 ,cp_121match
                 ,cp_slw
                 ,devsp_first
                 ,devsp_svs
                 ,devsp_final                       
                 ,devsp_ifbd
                 ,devsp_longvowel
                 ,devsp_rcontrol                       
                 ,devsp_vowldig
                 ,devsp_cmplxb
                 ,devsp_eding
                 ,devsp_doubsylj                       
                 ,rr_121match
                 ,rr_holdspattern
                 ,rr_understanding                       
                 ,accuracy_1a
                 ,accuracy_2b
                 ,ra_errors
                 ,cc_factual
                 ,cc_infer
                 ,cc_other
                 ,cc_ct
                 ,ocomp_factual
                 ,ocomp_ct
                 ,ocomp_infer
                 ,scomp_factual
                 ,scomp_infer
                 ,scomp_ct
                 ,wcomp_fact
                 ,wcomp_infer
                 ,wcomp_ct
                 ,retelling                       
                 ,reading_rate                       
                 ,fluency
                 ,fp_wpmrate
                 ,fp_fluency
                 ,fp_accuracy
                 ,fp_comp_within
                 ,fp_comp_beyond
                 ,fp_comp_about                     
                 ,cc_prof
                 ,ocomp_prof
                 ,scomp_prof
                 ,wcomp_prof
                 ,fp_comp_prof
                 ,cp_prof
                 ,rr_prof
                 ,devsp_prof)
   ) unpiv
 )

SELECT rs.unique_id
      ,rs.student_number
      ,rs.testid
      ,rs.status
      ,rs.field
      ,rs.score
           
      ,gleq.read_lvl
      ,CASE
          WHEN rs.testid = 3273 THEN gleq.fp_lvl_num 
          WHEN rs.testid != 3273 THEN gleq.lvl_num
         END AS lvl_num           
FROM ps_scores_long rs
LEFT OUTER JOIN gabby.lit.gleq
  ON rs.testid = gleq.testid 
 AND rs.read_lvl = gleq.read_lvl   
WHERE rs.testid = 3273