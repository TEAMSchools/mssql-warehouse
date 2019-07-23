USE kippnewark;
GO

CREATE OR ALTER VIEW mcs.view_student_data AS

SELECT CONVERT(INT, s.StudentNumber) AS student_number
      ,s.IsDC AS is_dc
      ,CONVERT(VARCHAR(25), s.Application_Approval_Result_Description) COLLATE Latin1_General_BIN AS application_approval_result_description
      ,CONVERT(VARCHAR(125), s.EligibilityDescription) COLLATE Latin1_General_BIN AS eligibility_description
      ,CONVERT(VARCHAR(25), s.MealBenefitsStatusDescription) COLLATE Latin1_General_BIN AS meal_benefits_status_description
      ,CONVERT(VARCHAR(125), CASE
                              WHEN s.IsDC = 1 THEN s.EligibilityDescription
                              WHEN s.EligibilityDescription LIKE 'Prior%' THEN 'No Application'
                              ELSE COALESCE(s.Application_Approval_Result_Description, s.EligibilityDescription)
                             END) COLLATE Latin1_General_BIN AS lunch_app_status
      ,LEFT(CASE
             WHEN s.EligibilityDescription LIKE 'Prior%' THEN 'Paying'
             ELSE s.MealBenefitsStatusDescription
            END, 1) COLLATE Latin1_General_BIN AS lunch_status

      ,c.ReimbursableOnlyBalance AS reimbursable_only_balance
      ,c.UnallocatedBalance AS unallocated_balance
      ,c.ReimbursableOnlyBalance + c.UnallocatedBalance AS total_balance
FROM [WINSQL06\HAN].Franklin.dbo.VIEW_STUDENT_DATA s
LEFT JOIN [WINSQL06\HAN].Newton.dbo.STUDENT_GUID_LINK g
  ON s.StudentGuid = g.StudentGUID
LEFT JOIN [WINSQL06\HAN].Newton.dbo.CUSTOMER c
  ON g.CustomerID = c.CUSTOMER_RECID;

GO

USE kippcamden;
GO

CREATE OR ALTER VIEW mcs.view_student_data AS

SELECT CONVERT(INT, s.StudentNumber) AS student_number
      ,s.IsDC AS is_dc
      ,CONVERT(VARCHAR(25), s.Application_Approval_Result_Description) COLLATE Latin1_General_BIN AS application_approval_result_description
      ,CONVERT(VARCHAR(125), s.EligibilityDescription) COLLATE Latin1_General_BIN AS eligibility_description
      ,CONVERT(VARCHAR(25), s.MealBenefitsStatusDescription) COLLATE Latin1_General_BIN AS meal_benefits_status_description
      ,CONVERT(VARCHAR(125), CASE
                              WHEN s.IsDC = 1 THEN s.EligibilityDescription
                              WHEN s.EligibilityDescription LIKE 'Prior%' THEN 'No Application'
                              ELSE COALESCE(s.Application_Approval_Result_Description, s.EligibilityDescription)
                             END) COLLATE Latin1_General_BIN AS lunch_app_status
      ,LEFT(CASE
             WHEN s.EligibilityDescription LIKE 'Prior%' THEN 'Paying'
             ELSE s.MealBenefitsStatusDescription
            END, 1) COLLATE Latin1_General_BIN AS lunch_status

      ,c.ReimbursableOnlyBalance AS reimbursable_only_balance
      ,c.UnallocatedBalance AS unallocated_balance
      ,c.ReimbursableOnlyBalance + c.UnallocatedBalance AS total_balance
FROM [WINSQL06\YODA].Franklin.dbo.VIEW_STUDENT_DATA s
LEFT JOIN [WINSQL06\YODA].Newton.dbo.STUDENT_GUID_LINK g
  ON s.StudentGuid = g.StudentGUID
LEFT JOIN [WINSQL06\YODA].Newton.dbo.CUSTOMER c
  ON g.CustomerID = c.CUSTOMER_RECID;