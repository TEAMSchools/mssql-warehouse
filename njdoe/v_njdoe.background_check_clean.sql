USE gabby
GO

CREATE OR ALTER VIEW njdoe.background_check_clean AS

SELECT bc.df_employee_number
      ,bc.approval_history
      
      ,JSON_VALUE(bc.applicant, '$.document_id') AS document_id
      ,JSON_VALUE(bc.applicant, '$.number_of_approvals') AS number_of_approvals
      
      ,ROW_NUMBER() OVER(
         PARTITION BY bc.df_employee_number
           ORDER BY bc._modified DESC) AS rn_employee_current
FROM gabby.njdoe.background_check bc