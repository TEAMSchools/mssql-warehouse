USE gabby
GO

CREATE OR ALTER VIEW tableau.covid_vaccine_dashboard AS

SELECT sc.df_employee_number
      ,sc.userprincipalname
      ,sc.preferred_name
      ,sc.[status]
      ,sc.legal_entity_name
      ,sc.primary_site
      ,sc.primary_job
      ,sc.manager_name
      ,sc.original_hire_date

      ,vc.covid_19_vaccine_type
      ,vc.date_of_last_vaccine
      ,vc.covid_19_booster_1_type
      ,vc.covid_19_booster_1_date
      ,CAST(MAX(vc._modified) OVER() AS DATETIME2) AS refresh_timestamp
FROM gabby.people.staff_crosswalk_static sc
LEFT JOIN gabby.adp.vaccine_records vc
  ON sc.adp_associate_id = vc.associate_id
