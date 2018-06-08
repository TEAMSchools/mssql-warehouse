USE gabby
GO

--CREATE OR ALTER VIEW tableau.compliance_staff_attrition AS

WITH staff_scaffold AS (
  SELECT df_employee_number
        ,adp_associate_id
        ,preferred_first_name
        ,preferred_last_name
        ,academic_year
        ,status_effective_start_date
        ,status_effective_end_date
        ,status
        ,status_reason_description
        ,department_name
        ,flsa_status_name
        ,job_family_name
        ,job_name
        ,legal_entity_name
        ,pay_class_name
        ,pay_type_name
        ,physical_location_name
        ,work_assignment_effective_start_date
        ,work_assignment_effective_end_date                
        ,ROW_NUMBER() OVER(
           PARTITION BY df_employee_number, academic_year
             ORDER BY status_effective_start_date DESC, work_assignment_effective_start_date DESC) AS rn_recent_year
  FROM
      (
       SELECT DISTINCT
              sr.df_employee_number
             ,sr.adp_associate_id
             ,sr.preferred_first_name
             ,sr.preferred_last_name

             ,rd.academic_year             

             ,CONVERT(DATE,es.effective_start) AS status_effective_start_date
             ,COALESCE(CONVERT(DATE,es.effective_end)
                      ,CONVERT(DATE,DATEFROMPARTS(gabby.utilities.DATE_TO_SY(GETDATE()) + 1, 9, 1))) AS status_effective_end_date
             ,es.status
             ,es.status_reason_description

             ,ewa.department_name
             ,ewa.flsa_status_name
             ,ewa.job_family_name
             ,ewa.job_name
             ,ewa.legal_entity_name
             ,ewa.pay_class_name
             ,ewa.pay_type_name
             ,ewa.physical_location_name
             ,CONVERT(DATE,ewa.work_assignment_effective_start) AS work_assignment_effective_start_date
             ,CONVERT(DATE,COALESCE(ewa.work_assignment_effective_end
                                   ,DATEFROMPARTS(gabby.utilities.DATE_TO_SY(GETDATE()) + 1, 9, 1))) AS work_assignment_effective_end_date
       FROM gabby.dayforce.staff_roster sr
       JOIN gabby.utilities.reporting_days rd
         ON rd.date BETWEEN sr.original_hire_date AND COALESCE(sr.termination_date
                                                              ,DATEFROMPARTS(gabby.utilities.DATE_TO_SY(GETDATE()) + 1, 9, 1))
        AND rd.date BETWEEN DATEFROMPARTS(rd.academic_year, 9, 1) AND DATEFROMPARTS(rd.academic_year + 1, 4, 30)
       JOIN gabby.dayforce.employee_status es
         ON sr.df_employee_number = es.number
        AND rd.date BETWEEN CONVERT(DATE,es.effective_start) AND COALESCE(CONVERT(DATE,es.effective_end)
                                                                         ,DATEFROMPARTS(gabby.utilities.DATE_TO_SY(GETDATE()) + 1, 9, 1))
        AND es.status NOT IN ('Terminated', 'Pre-Start')
       JOIN gabby.dayforce.employee_work_assignment ewa
         ON sr.df_employee_number = ewa.employee_reference_code
        AND rd.date BETWEEN CONVERT(DATE,ewa.work_assignment_effective_start) AND COALESCE(CONVERT(DATE,ewa.work_assignment_effective_end)
                                                                                          ,DATEFROMPARTS(gabby.utilities.DATE_TO_SY(GETDATE()) + 1, 9, 1))
        AND ewa.primary_work_assignment = 1       
      ) sub
  )

SELECT ss1.df_employee_number
      ,ss1.adp_associate_id
      ,ss1.preferred_first_name
      ,ss1.preferred_last_name
      ,ss1.academic_year
      ,ss1.status_effective_start_date
      ,ss1.status_effective_end_date
      ,ss1.status
      ,ss1.status_reason_description
      ,ss1.department_name
      ,ss1.flsa_status_name
      ,ss1.job_family_name
      ,ss1.job_name
      ,ss1.legal_entity_name
      ,ss1.pay_class_name
      ,ss1.pay_type_name
      ,ss1.physical_location_name
      ,ss1.work_assignment_effective_start_date
      ,ss1.work_assignment_effective_end_date

      ,ss2.status_effective_start_date AS future_status_effective_start_date
      ,ss2.status_effective_end_date AS future_status_effective_end_date
      ,ss2.status AS future_status
      ,ss2.status_reason_description AS future_status_reason_description
      ,ss2.department_name AS future_department_name
      ,ss2.flsa_status_name AS future_flsa_status_name
      ,ss2.job_family_name AS future_job_family_name
      ,ss2.job_name AS future_job_name
      ,ss2.legal_entity_name AS future_legal_entity_name
      ,ss2.pay_class_name AS future_pay_class_name
      ,ss2.pay_type_name AS future_pay_type_name
      ,ss2.physical_location_name AS future_physical_location_name
      ,ss2.work_assignment_effective_start_date AS future_work_assignment_effective_start_date
      ,ss2.work_assignment_effective_end_date AS future_work_assignment_effective_end_date      
      ,CASE WHEN ss2.df_employee_number IS NULL THEN 1 ELSE 0 END AS is_attrition
FROM staff_scaffold ss1
LEFT JOIN staff_scaffold ss2
  ON ss1.df_employee_number = ss2.df_employee_number
 AND ss1.academic_year = ss2.academic_year - 1
 AND ss2.rn_recent_year = 1
WHERE ss1.academic_year <= gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND ss1.rn_recent_year = 1