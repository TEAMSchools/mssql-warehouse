USE gabby
GO

CREATE OR ALTER VIEW people.race_ethnicity AS

SELECT sub.associate_id
      ,sub.employee_number
      ,status
      ,COALESCE(sub.preferred_gender, sub.gender) AS gender_reporting
      ,CASE
        WHEN sub.race_reporting = 'I decline to state my preferred racial/ethnic identity' THEN 'Decline to state'
        WHEN sub.race_reporting = 'My racial/ethnic identity is not listed' THEN 'Not Listed'
        WHEN sub.race_reporting IS NULL  AND sub.ethnicity_reporting = 'Hispanic or Latino' THEN 'Hispanic or Latino'
        WHEN sub.race_reporting = 'Latinx/Hispanic/Chicana(o)' THEN 'Hispanic or Latino'
        WHEN sub.race_reporting = 'Black or African American' THEN 'Black/African American'
        WHEN sub.race_reporting = 'Two or more races (Not Hispanic or Latino)' THEN 'Bi/Multiracial'
        ELSE sub.race_reporting + (CASE WHEN sub.ethnicity_reporting = 'Hispanic or Latino' THEN ' - ' + sub.ethnicity_reporting ELSE '' END)
       END AS race_ethnicity_reporting
      ,CASE WHEN sub.ethnicity_reporting = 'Hispanic or Latino' THEN 1 ELSE 0 END AS hispanic_latino
      ,CASE 
        WHEN sub.race_description = 'Black or African American' THEN 1
        WHEN CHARINDEX('Black/African American', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS black
      ,CASE 
        WHEN sub.race_description = 'Asian' THEN 1
        WHEN CHARINDEX('Asian', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS asian
      ,CASE 
        WHEN sub.race_description = 'Native Hawaiian or Other Pacific Islander' THEN 1
        WHEN CHARINDEX('Pacific Islander', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS hawaiian_pacific_islander
      ,CASE 
        WHEN CHARINDEX('Middle Eastern', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS middle_eastern
      ,CASE 
        WHEN sub.race_description = 'White' THEN 1
        WHEN CHARINDEX('White', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS white
      ,CASE
        WHEN sub.race_description = 'Two or more races (Not Hispanic or Latino)' THEN 1
        WHEN CHARINDEX('Bi/Multiracial',sub.preferred_race_ethnicity)>0 THEN 1
        WHEN CHARINDEX(';',sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS multi_racial
      ,CASE 
        WHEN CHARINDEX('My racial/ethnic identity is not listed', sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS other_not_listed
      ,CASE
        WHEN CHARINDEX('Decline to state',sub.preferred_race_ethnicity)>0 THEN 1
        ELSE 0
       END AS decline_to_state
FROM (
   SELECT associate_id
         ,file_number AS employee_number
         ,CASE 
           WHEN gender = 'Male' THEN 'Man'
           WHEN gender = 'Female' THEN 'Woman'
          END AS gender
         ,preferred_gender
         ,race_description
         ,ethnicity
         ,preferred_race_ethnicity
         ,CASE
           WHEN ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
           WHEN CHARINDEX('Latinx/Hispanic/Chicana(o)', preferred_race_ethnicity)>0 THEN 'Hispanic or Latino'
           WHEN ethnicity IS NULL AND preferred_race_ethnicity IS NULL THEN NULL
           ELSE 'Not Hispanic or Latino'
          END AS ethnicity_reporting
         ,CASE
           WHEN CHARINDEX(';',preferred_race_ethnicity)>0 THEN 'Bi/Multiracial'
           ELSE COALESCE(preferred_race_ethnicity,race_description)
          END AS race_reporting
   FROM adp.employees_all) sub
   LEFT JOIN people.staff_crosswalk_static c
     ON sub.associate_id = c.adp_associate_id