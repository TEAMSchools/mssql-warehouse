USE gabby
GO

CREATE OR ALTER VIEW tableau.bus_tool AS 

SELECT student_number
      ,schoolid
      ,grade_level
      ,hr_section_number
      ,lastfirst
      ,bus_info_am
      ,bus_info_pm
      ,bus_info_wednesdays
      ,log_studentid
      ,subtype
      ,home_phone
      ,mother
      ,mother_cell
      ,father
      ,father_cell
      ,release_1_name
      ,release_1_phone
      ,release_2_name
      ,release_2_phone
      ,release_3_name
      ,release_3_phone
      ,release_4_name
      ,release_4_phone
      ,release_5_name
      ,release_5_phone
      ,att_code
      ,sub.db_name
      ,SYSDATETIME() AS systimestamp      
FROM 
    (
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
           ,suf.bus_info_fridays AS bus_info_wednesdays
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

           ,cc.section_number AS hr_section_number
        
           ,log.studentid AS log_studentid
           ,log.subtype
        
           ,code.att_code
     FROM gabby.powerschool.students s
     LEFT JOIN gabby.powerschool.u_studentsuserfields suf
       ON s.dcid = suf.studentsdcid
      AND s.db_name = suf.db_name
     LEFT JOIN gabby.powerschool.cc
       ON s.id = cc.studentid
      AND s.db_name = cc.db_name
      AND cc.course_number = 'HR'
      AND CONVERT(DATE,GETDATE()) BETWEEN cc.dateenrolled AND cc.dateleft
     LEFT JOIN gabby.powerschool.log
       ON s.id = log.studentid
      AND s.db_name = log.db_name
      AND log.logtypeid = 3964
      AND log.discipline_incidentdate = CONVERT(DATE,GETDATE())
     LEFT JOIN gabby.powerschool.attendance att
       ON s.id = att.studentid
      AND s.db_name = att.db_name
      AND att.att_mode_code = 'ATT_ModeDaily'
      AND CONVERT(DATE,att.att_date) = CONVERT(DATE,GETDATE())
     LEFT JOIN gabby.powerschool.attendance_code code
       ON att.attendance_codeid = code.id
      AND att.db_name = code.db_name
      AND (code.att_code LIKE 'A%' OR code.att_code = 'OSS')
     WHERE s.enroll_status = 0
    ) sub;