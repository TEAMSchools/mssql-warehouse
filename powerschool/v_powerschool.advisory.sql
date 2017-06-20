USE gabby
GO

ALTER VIEW powerschool.advisory AS

SELECT studentid
      ,yearid
      ,advisory_name
      ,teachernumber
      ,teacher_name AS advisor_name
      ,N'' AS advisor_phone
      ,N'' AS advisor_email

      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, yearid
           ORDER BY dateleft DESC) AS rn_year
FROM
    (
     SELECT enr.studentid           
           ,enr.yearid
           ,enr.schoolid
           ,enr.dateleft           
           ,enr.teachernumber
           ,enr.teacher_name
           ,utilities.STRIP_CHARACTERS(enr.section_number,'0-9') AS advisory_name
     FROM powerschool.course_enrollments enr
     WHERE enr.course_number = 'HR'
       AND enr.schoolid NOT IN (133570965, 73253)
       AND enr.sectionid > 0

     UNION ALL

     SELECT enr.studentid           
           ,enr.yearid
           ,enr.schoolid
           ,enr.dateleft           
           ,enr.teachernumber
           ,enr.teacher_name
           ,utilities.STRIP_CHARACTERS(enr.section_number,'0-9') AS advisory_name
     FROM powerschool.course_enrollments enr
     WHERE enr.course_number = 'ADV'
       AND enr.schoolid IN (133570965, 73253)
       AND enr.sectionid > 0
    ) sub
/* future use when ADP & AD is setup */
--LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PEOPLE_teachernumber_associateid_link link WITH(NOLOCK)
--  ON advisory.teachernumber = LTRIM(RTRIM(STR(link.teachernumber)))
-- AND link.is_master = 1
--LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
--  ON COALESCE(link.associate_id, advisory.teachernumber) = adp.associate_id
-- AND adp.rn_curr = 1
--LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users dir WITH(NOLOCK)
--  ON adp.position_id = dir.employeenumber
-- AND dir.is_active = 1