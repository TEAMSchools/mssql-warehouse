USE gabby
GO

CREATE OR ALTER VIEW tableau.section_teacher_audit AS

SELECT sch.name
      ,sec.course_number
      ,c.course_name
	  ,sec.section_number
	  ,sec.external_expression AS period
	  ,sec.room
	  ,sec.no_of_students
	  ,sec.termid
	  ,sec.id AS sectionid
	  ,t.lastfirst AS teacher_name
	  ,CASE
	     WHEN st.roleid IN (41,25) THEN 'Lead teacher'
		 WHEN st.roleid IN (42,26) THEN 'Co-teacher'
		 WHEN st.roleid = 841 THEN 'Gradebook access'
		 ELSE NULL END AS teaching_role
	  ,st.start_date
	  ,st.end_date

FROM gabby.powerschool.sections sec
LEFT JOIN gabby.powerschool.sectionteacher st
  ON sec.db_name = st.db_name
 AND sec.id = st.sectionid
LEFT JOIN gabby.powerschool.courses c 
  ON sec.course_number = c.course_number
 AND sec.db_name = c.db_name
LEFT JOIN gabby.powerschool.teachers_static t
  ON t.id = st.teacherid
 AND t.db_name = sec.db_name
LEFT JOIN gabby.powerschool.schools sch
  ON sec.schoolid = sch.school_number
 AND sec.db_name = sch.db_name