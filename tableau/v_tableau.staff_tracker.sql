USE gabby
GO

ALTER VIEW tableau.staff_tracker AS

WITH prof_calendar AS (
  SELECT cal.schoolid
        ,cal.schoolid AS reporting_schoolid             
        ,cal.date_value
        ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year
             
        ,CONVERT(NVARCHAR,dt.alt_name) AS term
  FROM gabby.powerschool.calendar_day cal
  JOIN gabby.reporting.reporting_terms dt
    ON cal.schoolid = dt.schoolid
   AND cal.date_value BETWEEN CONVERT(DATE,dt.start_date) AND CONVERT(DATE,dt.end_date)
   AND dt.identifier = 'RT'   
  WHERE cal.date_value >= CONVERT(DATE,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR(),'-07-01'))
    AND cal.date_value <= CONVERT(DATE,GETDATE())       
    AND (cal.insession = 1 OR cal.type = 'PD')  
 )

,staff_roster AS (
  SELECT associate_id
        ,CONCAT(preferred_last_name, ', ', preferred_first_name) AS preferred_lastfirst
        ,location
        ,job_title
        ,manager
        ,email_address
        ,position_start_date
        ,CASE
          WHEN reporting_location IN ('KIPP NJ','TEAM Schools') THEN 7325
          WHEN reporting_location = 'TEAM Academy' THEN 133570965
          WHEN reporting_location = 'Rise Academy' THEN 73252
          WHEN reporting_location = 'Newark Collegiate Academy' THEN 73253
          WHEN reporting_location = 'SPARK Academy' THEN 73254
          WHEN reporting_location IN ('THRIVE Academy','18th Avenue Campus') THEN 73255          
          WHEN reporting_location = 'Seek Academy' THEN 73256
          WHEN reporting_location IN ('Life Academy','Pathways') THEN 73257
          WHEN reporting_location = 'Bold Academy' THEN 73258
          
          WHEN reporting_location = 'Lanning Square Campus' THEN 1799          
          WHEN reporting_location = 'Lanning Square Primary' THEN 179901
          WHEN reporting_location = 'Lanning Square MS' THEN 179902
          WHEN reporting_location = 'Whittier Middle' THEN 179903
          WHEN reporting_location = 'Whittier Elementary' THEN 1799015075          
         END AS schoolid
  FROM
      (
       SELECT adp.associate_id 
             ,adp.preferred_first AS preferred_first_name 
             ,adp.preferred_last AS preferred_last_name       
             ,adp.location_description AS location
             ,adp.subject_dept_custom AS department
             ,adp.job_title_custom AS job_title
             ,adp.manager_custom_assoc_id AS manager
             ,adp.position_start_date
             ,adp.location_description AS reporting_location             
             
             ,dir.mail AS email_address             
       FROM gabby.adp.staff_roster adp
       LEFT OUTER JOIN gabby.adsi.user_attributes dir
         ON adp.position_id = dir.employeenumber        
       WHERE rn_curr = 1
         AND adp.position_status != 'Terminated'
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
             ,CONVERT(NVARCHAR(MAX),notes_optional_) AS notes

             ,ISNULL(CONVERT(NVARCHAR,present),'') AS present
             ,ISNULL(CONVERT(NVARCHAR,on_time),'') AS on_time
             ,ISNULL(CONVERT(NVARCHAR,attire_optional_),'') AS attire
             ,ISNULL(CONVERT(NVARCHAR,lp_optional_),'') AS lp
             ,ISNULL(CONVERT(NVARCHAR,gr_lp_optional_),'') AS gr_lp             
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
LEFT OUTER JOIN tracking_long pt
  ON r.associate_id = pt.associate_id 
 AND cal.date_value = pt.date
 AND f.field = pt.field