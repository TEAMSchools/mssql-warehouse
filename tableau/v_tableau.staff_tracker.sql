USE gabby
GO

CREATE OR ALTER VIEW tableau.staff_tracker AS

WITH prof_calendar AS (
  SELECT cal.schoolid
        ,cal.schoolid AS reporting_schoolid             
        ,cal.date_value
        ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year
             
        ,CONVERT(VARCHAR,dt.alt_name) AS term
  FROM gabby.powerschool.calendar_day cal
  JOIN gabby.reporting.reporting_terms dt
    ON cal.schoolid = dt.schoolid
   AND cal.date_value BETWEEN dt.start_date AND dt.end_date
   AND dt.identifier = 'RT'   
  WHERE cal.date_value BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND GETDATE()
    AND (cal.insession = 1 OR cal.type = 'PD')  
 )

,staff_roster AS (
  SELECT associate_id        
        ,location
        ,job_title
        ,manager
        ,email_address
        ,position_start_date
        ,position_status
        ,preferred_lastfirst
        ,CASE          
          WHEN reporting_location = 'TEAM Academy' THEN 133570965
          WHEN reporting_location = 'Rise Academy' THEN 73252
          WHEN reporting_location = 'Newark Collegiate Academy' THEN 73253
          WHEN reporting_location = 'SPARK Academy' THEN 73254
          WHEN reporting_location IN ('THRIVE Academy','18th Ave Campus','Pathways at 18th Ave') THEN 73255          
          WHEN reporting_location = 'Seek Academy' THEN 73256
          WHEN reporting_location IN ('Life Academy','Pathways at Bragaw') THEN 73257
          WHEN reporting_location = 'Bold Academy' THEN 73258                    
          WHEN reporting_location = 'Lanning Square Primary' THEN 179901
          WHEN reporting_location = 'Lanning Square Middle' THEN 179902
          WHEN reporting_location = 'Whittier Middle' THEN 179903
          WHEN reporting_location = 'Whittier Elementary' THEN 1799015075          
         END AS schoolid
  FROM
      (
       SELECT df.adp_associate_id AS associate_id
             ,df.preferred_first_name 
             ,df.preferred_last_name     
             ,df.preferred_name AS preferred_lastfirst  
             ,df.primary_site AS location
             ,df.primary_on_site_department AS department
             ,df.primary_job AS job_title
             ,df.manager_name AS manager
             ,df.position_effective_from_date AS position_start_date
             ,df.primary_site AS reporting_location             
             ,df.status AS position_status
             
             ,dir.mail AS email_address             
       FROM gabby.dayforce.staff_roster df
       LEFT JOIN gabby.adsi.user_attributes_static dir
         ON df.adp_associate_id = dir.idautopersonalternateid
       WHERE df.status != 'TERMINATED'
      ) sub
 )

,tracking_long AS (
  SELECT associate_id
        ,date
        ,notes
        ,field
        ,CASE WHEN value = '' THEN NULL ELSE value END AS value
  FROM
      (
       SELECT SUBSTRING(staff_name
                       ,(CHARINDEX('[', staff_name) + 1)
                       ,(LEN(staff_name) - CHARINDEX('[', staff_name) - 1)) AS associate_id
             ,CONVERT(DATE,date) AS date
             ,CONVERT(VARCHAR(250),notes_optional_) AS notes

             ,ISNULL(CONVERT(VARCHAR,present),'') AS present
             ,ISNULL(CONVERT(VARCHAR,on_time),'') AS on_time
             ,ISNULL(CONVERT(VARCHAR,attire_optional_),'') AS attire
             ,ISNULL(CONVERT(VARCHAR,lp_optional_),'') AS lp
             ,ISNULL(CONVERT(VARCHAR,gr_lp_optional_),'') AS gr_lp             
       FROM gabby.pm.teacher_tracker
       WHERE ISDATE(date) = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (present, on_time, attire, lp, gr_lp)
   ) u
 )

,tracker_fields AS (
  SELECT DISTINCT
         field
  FROM tracking_long
 )

 SELECT r.associate_id
       ,r.preferred_lastfirst             
       ,r.email_address
       ,r.schoolid
       ,r.location AS school_name
       ,r.job_title       
       ,r.manager
       ,r.position_status

       ,cal.academic_year
       ,cal.term
       ,cal.date_value            
       
       ,f.field
       
       ,pt.notes      
       ,pt.value
FROM staff_roster r
JOIN prof_calendar cal
  ON r.schoolid = cal.schoolid
 AND r.position_start_date <= cal.date_value
CROSS JOIN tracker_fields f
LEFT JOIN tracking_long pt
  ON r.associate_id = pt.associate_id 
 AND cal.date_value = pt.date
 AND f.field = pt.field