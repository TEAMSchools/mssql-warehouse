USE gabby
GO

CREATE OR ALTER VIEW tableau.bus_tool AS 

SELECT s.student_number
      ,s.schoolid
      ,s.grade_level
      ,s.lastfirst
      ,s.home_phone
      ,s.mother
      ,s.father
      ,s.db_name

      ,suf.bus_info_am      
      ,suf.bus_info_pm
      ,suf.bus_info_fridays AS bus_info_pm_early
      ,suf.mother_cell
      ,suf.father_cell
      ,suf.release_1_name
      ,suf.release_1_phone
      ,suf.release_2_name
      ,suf.release_2_phone
      ,suf.release_3_name
      ,suf.release_3_phone
      ,suf.release_4_name
      ,suf.release_4_phone
      ,suf.release_5_name
      ,suf.release_5_phone  
      ,suf._modified
      ,CASE 
        WHEN suf.bus_info_am NOT LIKE '%-%-%' THEN suf.bus_info_am
        ELSE SUBSTRING(suf.bus_info_am
                      ,(CHARINDEX('-', suf.bus_info_am) + 2)
                      ,(CHARINDEX('-', suf.bus_info_am, (CHARINDEX('-', suf.bus_info_am) + 1)) - (CHARINDEX('-', suf.bus_info_am) + 2)) - 1)
       END AS bus_name_am
      ,SUBSTRING(suf.bus_info_am
                ,CHARINDEX('-', suf.bus_info_am, (CHARINDEX('-', suf.bus_info_am) + 1)) + 2
                ,LEN(suf.bus_info_am)) AS bus_stop_am
      ,CASE 
        WHEN suf.bus_info_pm NOT LIKE '%-%-%' THEN suf.bus_info_pm
        ELSE SUBSTRING(suf.bus_info_pm
                      ,(CHARINDEX('-', suf.bus_info_pm) + 2)
                      ,(CHARINDEX('-', suf.bus_info_pm, (CHARINDEX('-', suf.bus_info_pm) + 1)) - (CHARINDEX('-', suf.bus_info_pm) + 2)) - 1)
       END AS bus_name_pm
      ,SUBSTRING(suf.bus_info_pm
                ,CHARINDEX('-', suf.bus_info_pm, (CHARINDEX('-', suf.bus_info_pm) + 1)) + 2
                ,LEN(suf.bus_info_pm)) AS bus_stop_pm
      ,CASE 
        WHEN suf.bus_info_fridays NOT LIKE '%-%-%' THEN suf.bus_info_fridays
        ELSE SUBSTRING(suf.bus_info_fridays
                      ,(CHARINDEX('-', suf.bus_info_fridays) + 2)
                      ,(CHARINDEX('-', suf.bus_info_fridays, (CHARINDEX('-', suf.bus_info_fridays) + 1)) - (CHARINDEX('-', suf.bus_info_fridays) + 2)) - 1)
       END AS bus_name_pm_early
      ,SUBSTRING(suf.bus_info_fridays
                ,CHARINDEX('-', suf.bus_info_fridays, (CHARINDEX('-', suf.bus_info_fridays) + 1)) + 2
                ,LEN(suf.bus_info_fridays)) AS bus_stop_pm_early    

      ,cc.section_number AS hr_section_number
        
      ,log.studentid AS log_studentid
      ,log.subtype
        
      ,code.att_code

      ,SYSDATETIME() AS systimestamp      
FROM gabby.powerschool.students s WITH(NOLOCK)
LEFT JOIN gabby.powerschool.u_studentsuserfields suf WITH(NOLOCK)
  ON s.dcid = suf.studentsdcid
 AND s.db_name = suf.db_name
LEFT JOIN gabby.powerschool.cc WITH(NOLOCK)
  ON s.id = cc.studentid
 AND s.db_name = cc.db_name
 AND cc.course_number = 'HR'
 AND CASE WHEN cc.dateenrolled > CONVERT(DATE,GETDATE()) THEN cc.dateenrolled ELSE CONVERT(DATE,GETDATE()) END BETWEEN cc.dateenrolled AND cc.dateleft
LEFT JOIN gabby.powerschool.log WITH(NOLOCK)
  ON s.id = log.studentid
 AND s.db_name = log.db_name
 AND log.logtypeid = 3964
 AND log.discipline_incidentdate = CONVERT(DATE,GETDATE())
LEFT JOIN gabby.powerschool.attendance att WITH(NOLOCK)
  ON s.id = att.studentid
 AND s.db_name = att.db_name
 AND att.att_mode_code = 'ATT_ModeDaily'
 AND CONVERT(DATE,att.att_date) = CONVERT(DATE,GETDATE())
LEFT JOIN gabby.powerschool.attendance_code code WITH(NOLOCK)
  ON att.attendance_codeid = code.id
 AND att.db_name = code.db_name
 AND (code.att_code LIKE 'A%' OR code.att_code = 'OSS')
WHERE s.enroll_status = 0