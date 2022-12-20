USE kippnewark;

GO
CREATE OR ALTER VIEW
  mcs.view_student_data AS
SELECT
  CAST(
    s.StudentNumber AS INT
  ) AS student_number,
  s.IsDC AS is_dc,
  (
    CAST(
      s.Application_Approval_Result_Description AS VARCHAR(25)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS application_approval_result_description,
  (
    CAST(
      s.EligibilityDescription AS VARCHAR(125)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS eligibility_description,
  (
    CAST(
      s.MealBenefitsStatusDescription AS VARCHAR(25)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS meal_benefits_status_description,
  (
    CONVERT(
      VARCHAR(125),
      CASE
        WHEN s.IsDC = 1 THEN 'Direct Certification'
        WHEN COALESCE(
          s.Application_Approval_Result_Description,
          s.EligibilityDescription
        ) LIKE 'Prior%' THEN 'No Application'
        ELSE COALESCE(
          s.Application_Approval_Result_Description,
          s.EligibilityDescription
        )
      END
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS lunch_app_status,
  (
    CASE
      WHEN s.IsDC = 1 THEN 'F'
      WHEN s.Application_Approval_Result_Description LIKE ('Denied%') THEN 'P'
      WHEN s.Application_Approval_Result_Description IN ('Zero Income') THEN 'F'
      WHEN s.Application_Approval_Result_Description IS NULL
      AND s.EligibilityDescription LIKE 'Prior%' THEN 'P'
      ELSE LEFT(
        COALESCE(
          s.Application_Approval_Result_Description,
          s.MealBenefitsStatusDescription
        ),
        1
      )
    END
    COLLATE LATIN1_GENERAL_BIN
  ) AS lunch_status,
  c.ReimbursableOnlyBalance AS reimbursable_only_balance,
  c.UnallocatedBalance AS unallocated_balance,
  c.ReimbursableOnlyBalance + c.UnallocatedBalance AS total_balance
FROM
  [WINSQL06\HAN].Franklin.dbo.VIEW_STUDENT_DATA s
  LEFT JOIN [WINSQL06\HAN].Newton.dbo.STUDENT_GUID_LINK g ON s.StudentGuid = g.StudentGUID
  LEFT JOIN [WINSQL06\HAN].Newton.dbo.CUSTOMER c ON g.CustomerID = c.CUSTOMER_RECID
WHERE
  ISNUMERIC(s.StudentNumber) = 1;

GO USE kippcamden;

GO
CREATE OR ALTER VIEW
  mcs.view_student_data AS
SELECT
  CAST(
    s.StudentNumber AS INT
  ) AS student_number,
  s.IsDC AS is_dc,
  (
    CAST(
      s.Application_Approval_Result_Description AS VARCHAR(25)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS application_approval_result_description,
  (
    CAST(
      s.EligibilityDescription AS VARCHAR(125)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS eligibility_description,
  (
    CAST(
      s.MealBenefitsStatusDescription AS VARCHAR(25)
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS meal_benefits_status_description,
  (
    CONVERT(
      VARCHAR(125),
      CASE
        WHEN s.IsDC = 1 THEN 'Direct Certification'
        WHEN COALESCE(
          s.Application_Approval_Result_Description,
          s.EligibilityDescription
        ) LIKE 'Prior%' THEN 'No Application'
        ELSE COALESCE(
          s.Application_Approval_Result_Description,
          s.EligibilityDescription
        )
      END
    )
    COLLATE LATIN1_GENERAL_BIN
  ) AS lunch_app_status,
  (
    CASE
      WHEN s.IsDC = 1 THEN 'F'
      WHEN s.Application_Approval_Result_Description LIKE ('Denied%') THEN 'P'
      WHEN s.Application_Approval_Result_Description IN ('Zero Income') THEN 'F'
      WHEN s.Application_Approval_Result_Description IS NULL
      AND s.EligibilityDescription LIKE 'Prior%' THEN 'P'
      ELSE LEFT(
        COALESCE(
          s.Application_Approval_Result_Description,
          s.MealBenefitsStatusDescription
        ),
        1
      )
    END
    COLLATE LATIN1_GENERAL_BIN
  ) AS lunch_status,
  c.ReimbursableOnlyBalance AS reimbursable_only_balance,
  c.UnallocatedBalance AS unallocated_balance,
  c.ReimbursableOnlyBalance + c.UnallocatedBalance AS total_balance
FROM
  [WINSQL06\YODA].Franklin.dbo.VIEW_STUDENT_DATA s
  LEFT JOIN [WINSQL06\YODA].Newton.dbo.STUDENT_GUID_LINK g ON s.StudentGuid = g.StudentGUID
  LEFT JOIN [WINSQL06\YODA].Newton.dbo.CUSTOMER c ON g.CustomerID = c.CUSTOMER_RECID
WHERE
  ISNUMERIC(s.StudentNumber) = 1;
