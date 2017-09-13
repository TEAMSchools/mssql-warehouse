USE gabby
GO

ALTER VIEW tableau.compliance_staff_attrition AS

WITH roster AS (
  SELECT associate_id        
        ,preferred_first
        ,preferred_last
        ,LEFT(position_id,3) AS entity
        ,location_custom
        ,position_start_date
        ,termination_date        
        ,benefits_eligibility_class_description
        ,gabby.utilities.DATE_TO_SY(position_start_date) AS start_academic_year
        ,gabby.utilities.DATE_TO_SY(termination_date) AS end_academic_year
  FROM gabby.adp.staff_roster
 )

,years AS (
  SELECT n AS academic_year
  FROM gabby.utilities.row_generator
  WHERE n BETWEEN 2000 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 )

,scaffold AS (
  SELECT associate_id        
        ,preferred_first
        ,preferred_last
        ,entity
        ,location_custom
        ,benefits_eligibility_class_description
        ,academic_year
        ,termination_date
        ,academic_year_entrydate
        ,academic_year_exitdate
  FROM
      (
       SELECT r.associate_id
             ,r.entity
             ,r.preferred_first
             ,r.preferred_last                          
             ,r.location_custom
             ,r.benefits_eligibility_class_description
             ,CASE WHEN r.end_academic_year =  y.academic_year THEN r.termination_date END AS termination_date
      
             ,y.academic_year

             ,CASE WHEN r.start_academic_year = y.academic_year THEN r.position_start_date ELSE DATEFROMPARTS(y.academic_year, 7, 1) END AS academic_year_entrydate
             ,CASE                 
               WHEN r.end_academic_year = y.academic_year THEN COALESCE(r.termination_date, DATEFROMPARTS((y.academic_year + 1), 6, 30))
               ELSE DATEFROMPARTS((y.academic_year + 1), 6, 30)
              END AS academic_year_exitdate
             ,ROW_NUMBER() OVER(
                PARTITION BY r.associate_id, y.academic_year
                  ORDER BY r.position_start_date DESC, COALESCE(r.termination_date,CONVERT(DATE,GETDATE())) DESC) AS rn_dupe_academic_year
       FROM roster r
       JOIN years y
         ON y.academic_year BETWEEN r.start_academic_year AND COALESCE(r.end_academic_year, gabby.utilities.GLOBAL_ACADEMIC_YEAR())
      ) sub
  WHERE rn_dupe_academic_year = 1
 )

SELECT d.associate_id      
      ,d.preferred_first
      ,d.preferred_last
      ,d.location_custom
      ,d.entity
      ,d.benefits_eligibility_class_description
      ,d.academic_year      
      ,d.academic_year_entrydate      
      ,d.academic_year_exitdate
      ,CASE 
        WHEN d.academic_year_entrydate <= DATEFROMPARTS((d.academic_year + 1), 4, 30) AND d.academic_year_exitdate >= DATEFROMPARTS(d.academic_year, 9, 1) THEN 1         
        ELSE 0 
       END AS is_denominator      

      ,n.academic_year_exitdate AS next_academic_year_exitdate
      ,d.termination_date     
      ,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) AS attrition_exitdate 
      ,CASE
        WHEN COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) < DATEFROMPARTS(d.academic_year + 1, 9, 1) THEN 1
        ELSE 0
       END AS is_attrition
FROM scaffold d
LEFT OUTER JOIN scaffold n
  ON d.associate_id = n.associate_id
 AND d.academic_year = (n.academic_year - 1)