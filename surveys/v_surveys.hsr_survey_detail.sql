USE gabby
GO

CREATE OR ALTER VIEW surveys.hsr_survey_detail AS

WITH responses_rollup AS (
  SELECT school
        ,academic_year
        ,role
        ,survey_question
        ,COUNT(likert_response_scale_5) AS n_responses
        ,SUM(CASE 
              WHEN likert_response_scale_5 >= 4 THEN 1.0 
              WHEN likert_response_scale_5 < 4 THEN 0.0
             END) AS n_responses_positive
  FROM
      (
       SELECT kipp_new_jersey_select_your_school_ AS school
             ,school_year AS academic_year
             ,role
             ,survey_question
             ,CASE
               WHEN response IN ('Strongly Agree', 'Extremely well', 'Not a problem at all', 'Extremely good', 'Almost always', 'Weekly or more', 'Extremely comfortable'
                                ,'Extremely excited', 'Encourage me a tremendous amount', 'A tremendous amount', 'A tremendous amount of support', 'Extremely safe', 'Extremely respectful'
                                ,'A tremendous amount of respect', 'Extremely likely') 
                                  THEN 5
               WHEN response IN ('Agree', 'Quite well', 'Small problem', 'Quite good', 'Frequently', 'Monthly', 'Quite comfortable', 'Quite excited', 'Encourage me quite a bit'
                                ,'Quite a bit', 'Quite a bit of support', 'Quite safe''Quite  respectful', 'Quite a bit of respect', 'Quite likely') 
                                  THEN 4
               WHEN response IN ('Neutral', 'Somewhat well', 'Medium problem', 'Somewhat good', 'Sometimes', 'Every few months', 'Somewhat comfortable', 'Somewhat excited'
                                ,'Encourage me some', 'Some', 'Some support', 'Somewhat safe', 'Somewhat respectful', 'Some respect', 'Somewhat likely') 
                                  THEN 3
               WHEN response IN ('Disagree', 'Slightly well', 'Large problem', 'Slightly good', 'Once in a while', 'Once or twice', 'Slightly comfortable', 'Slightly excited'
                                ,'Encourage me a little', 'A little bit', 'A little bit of support', 'Slightly safe', 'Slightly respectful', 'A little bit of respect', 'Slightly likely')
                                  THEN 2
               WHEN response IN ('Strongly Disagree', 'Not well at all', 'Very large problem', 'Not good at all', 'Almost never', 'Once or twice per year', 'Not comfortable at all'
                                ,'Not at all excited', 'Does not encourage me at all', 'Not at all', 'No support at all', 'Not at all safe', 'Not at all respectful', 'Almost no respect'
                                ,'Not at all likely')
                                  THEN 1
              END AS likert_response_scale_5
       FROM gabby.surveys.hsr_survey
      ) sub
  WHERE likert_response_scale_5 IS NOT NULL
  GROUP BY school
          ,academic_year
          ,role
          ,survey_question
 )

SELECT school
      ,academic_year
      ,role
      ,survey_question
      ,n_responses
      ,n_responses_positive
      ,CASE
        WHEN school = 'KIPP Rise Academy' THEN 73252
        WHEN school = 'Rise Academy, a KIPP school' THEN 73252
        WHEN school = 'KIPP Newark Collegiate Academy' THEN 73253
        WHEN school = 'Newark Collegiate Academy, a KIPP school' THEN 73253
        WHEN school = 'KIPP SPARK Academy' THEN 73254
        WHEN school = 'SPARK Academy, a KIPP school' THEN 73254
        WHEN school = 'KIPP THRIVE Academy' THEN 73255
        WHEN school = 'THRIVE Academy, a KIPP school' THEN 73255
        WHEN school = 'KIPP Seek Academy' THEN 73256
        WHEN school = 'Seek Academy, a KIPP school' THEN 73256
        WHEN school = 'KIPP Life Academy' THEN 73257
        WHEN school = 'Life Academy at Bragaw, a KIPP school' THEN 73257
        WHEN school = 'KIPP BOLD Academy' THEN 73258
        WHEN school = 'KIPP Lanning Square Primary' THEN 179901
        WHEN school = 'Revolution Primary, a KIPP school' THEN 179901
        WHEN school = 'KIPP Lanning Square Middle School' THEN 179902
        WHEN school = 'KIPP Whittier Middle School' THEN 179903
        WHEN school = 'KIPP TEAM Academy' THEN 133570965
        WHEN school = 'TEAM Academy, a KIPP school' THEN 133570965
        WHEN school = 'KIPP Pathways' THEN 732574573
       END AS reporting_schoolid
      ,CASE
        WHEN school = 'KIPP Rise Academy' THEN 'TEAM'
        WHEN school = 'Rise Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP Newark Collegiate Academy' THEN 'TEAM'
        WHEN school = 'Newark Collegiate Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP SPARK Academy' THEN 'TEAM'
        WHEN school = 'SPARK Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP THRIVE Academy' THEN 'TEAM'
        WHEN school = 'THRIVE Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP Seek Academy' THEN 'TEAM'
        WHEN school = 'Seek Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP Life Academy' THEN 'TEAM'
        WHEN school = 'Life Academy at Bragaw, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP BOLD Academy' THEN 'TEAM'
        WHEN school = 'KIPP Lanning Square Primary' THEN 'KCNA'
        WHEN school = 'Revolution Primary, a KIPP school' THEN 'KCNA'
        WHEN school = 'KIPP Lanning Square Middle School' THEN 'KCNA'
        WHEN school = 'KIPP Whittier Middle School' THEN 'KCNA'
        WHEN school = 'KIPP TEAM Academy' THEN 'TEAM'
        WHEN school = 'TEAM Academy, a KIPP school' THEN 'TEAM'
        WHEN school = 'KIPP Pathways' THEN 'TEAM'
       END AS region
      ,CASE 
        WHEN school = 'KIPP Rise Academy' THEN 'MS'
        WHEN school = 'Rise Academy, a KIPP school' THEN 'MS'
        WHEN school = 'KIPP Newark Collegiate Academy' THEN 'HS'
        WHEN school = 'Newark Collegiate Academy, a KIPP school' THEN 'HS'
        WHEN school = 'KIPP SPARK Academy' THEN 'ES'
        WHEN school = 'SPARK Academy, a KIPP school' THEN 'ES'
        WHEN school = 'KIPP THRIVE Academy' THEN 'ES'
        WHEN school = 'THRIVE Academy, a KIPP school' THEN 'ES'
        WHEN school = 'KIPP Seek Academy' THEN 'ES'
        WHEN school = 'Seek Academy, a KIPP school' THEN 'ES'
        WHEN school = 'KIPP Life Academy' THEN 'ES'
        WHEN school = 'Life Academy at Bragaw, a KIPP school' THEN 'ES'
        WHEN school = 'KIPP BOLD Academy' THEN 'MS'
        WHEN school = 'KIPP Lanning Square Primary' THEN 'ES'
        WHEN school = 'Revolution Primary, a KIPP school' THEN 'ES'
        WHEN school = 'KIPP Lanning Square Middle School' THEN 'MS'
        WHEN school = 'KIPP Whittier Middle School' THEN 'MS'
        WHEN school = 'KIPP TEAM Academy' THEN 'MS'
        WHEN school = 'TEAM Academy, a KIPP school' THEN 'MS'
        WHEN school = 'KIPP Pathways' THEN 'ES'
       END AS school_level
FROM
    (
     SELECT school 
           ,academic_year
           ,role
           ,survey_question
           ,n_responses
           ,n_responses_positive
     FROM responses_rollup

     UNION ALL

     SELECT school 
           ,CAST(LEFT(school_year, 4) AS INT) AS academic_year
           ,role
           ,survey_question
           ,school_responded
           ,ROUND((likert_4_ * school_responded) + (likert_5_ * school_responded), 0) AS responded_positive
     FROM gabby.surveys.hsr_survey_archive
    ) sub