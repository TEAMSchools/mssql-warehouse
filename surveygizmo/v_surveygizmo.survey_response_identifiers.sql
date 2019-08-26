USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_identifiers AS

WITH response_pivot AS (
  SELECT p.survey_response_id
        ,p.survey_id
        ,CONVERT(VARCHAR(25), p.adp_associate_id) AS adp_associate_id
        ,CONVERT(VARCHAR(125),LOWER(p.userprincipalname)) AS userprincipalname
        ,CONVERT(INT, CASE
                       WHEN CHARINDEX('[', p.subject_df_employee_number) = 0 THEN NULL
                       ELSE SUBSTRING(p.subject_df_employee_number
                                     ,CHARINDEX('[', p.subject_df_employee_number) + 1
                                     ,CHARINDEX(']', p.subject_df_employee_number) - CHARINDEX('[', p.subject_df_employee_number) - 1)
                      END) AS subject_df_employee_number
        ,CONVERT(INT, CASE
                       WHEN ISNUMERIC(p.df_employee_number) = 1 THEN p.df_employee_number
                       WHEN CHARINDEX('[', p.df_employee_number) = 0 THEN NULL
                       ELSE SUBSTRING(p.df_employee_number
                                     ,CHARINDEX('[', p.df_employee_number) + 1
                                     ,CHARINDEX(']', p.df_employee_number) - CHARINDEX('[', p.df_employee_number) - 1)
                      END) AS df_employee_number
  FROM
      (
       SELECT srd.survey_response_id
             ,srd.survey_id
             ,srd.answer
             ,cw.field_mapping
       FROM gabby.surveygizmo.survey_response_data_static srd
       JOIN gabby.people.surveygizmo_crosswalk cw
         ON srd.survey_id = cw.survey_id
        AND srd.question_id = cw.question_id
        AND cw._fivetran_deleted = 0
       WHERE srd.answer IS NOT NULL
      ) sub
  PIVOT(
    MAX(answer)
    FOR field_mapping IN (df_employee_number
                         ,subject_df_employee_number
                         ,adp_associate_id
                         ,userprincipalname)
   ) p
 )

SELECT rp.survey_response_id
      ,rp.survey_id
      ,rp.adp_associate_id
      ,rp.userprincipalname
      ,rp.subject_df_employee_number
      ,COALESCE(rp.df_employee_number
               ,upn.df_employee_number
               ,adp.df_employee_number
               ,mail.df_employee_number
               ,ab.df_employee_number) AS df_employee_number
FROM response_pivot rp
LEFT JOIN gabby.people.staff_crosswalk_static upn
  ON rp.userprincipalname = upn.userprincipalname
LEFT JOIN gabby.people.staff_crosswalk_static adp
  ON rp.adp_associate_id = adp.adp_associate_id
LEFT JOIN gabby.people.staff_crosswalk_static mail
  ON rp.userprincipalname = mail.mail
LEFT JOIN gabby.surveys.surveygizmo_abnormal_respondents ab
  ON rp.survey_id = ab.survey_id
 AND rp.survey_response_id = ab.survey_response_id
 AND ab._fivetran_deleted = 0