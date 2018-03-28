USE gabby
GO

CREATE OR ALTER VIEW extracts.blissbook_employee_list AS

SELECT df.df_employee_number AS [Employee ID]
      ,ad.mail AS [Email Address]
      ,CONCAT(df.preferred_first_name, ' ', df.preferred_last_name) AS [Name]
      ,COALESCE(df.rehire_date, df.original_hire_date) AS [Latest Hire Date]
      ,df.legal_entity_name AS [Groups]
FROM gabby.dayforce.staff_roster df
JOIN gabby.adsi.user_attributes_static ad
  ON df.adp_associate_id = ad.idautopersonalternateid