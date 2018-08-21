CREATE OR ALTER VIEW powerschool.gradebook_setup AS

SELECT sectionsdcid
      ,sectionsdcid AS psm_sectionid                
      ,ISNULL(gradeformulasetid, 0) AS finalgradesetupid
      ,gct_type AS finalgradesetuptype        
      ,gradecalculationtypeid AS fg_reportingtermid
      ,storecode AS reportingterm_name
      ,date_1 AS startdate
      ,date_2 AS enddate
      ,ISNULL(gradecalcformulaweightid, gradecalculationtypeid) AS gradingformulaid
      ,ISNULL(gcfw_type, gct_type) AS gradingformulaweightingtype
      ,weight AS weighting
                
      ,COALESCE(districtteachercategoryid, teachercategoryid, gradecalculationtypeid) AS assignmentcategoryid
      ,COALESCE(dtc_name, tc_name, gct_type) AS category_name
      ,COALESCE(dtc_name, tc_name, gct_type) AS category_abbreviation
      ,COALESCE(dtc_defaultscoretype, tc_defaultscoretype) AS defaultscoretype
      ,COALESCE(dtc_isinfinalgrades, tc_isinfinalgrades, 1) AS includeinfinalgrades
FROM
    (
     SELECT sec.dcid AS sectionsdcid        
           
           ,tb.storecode
           ,tb.date_1
           ,tb.date_2

           ,gfs.gradeformulasetid
           
           ,gct.gradecalculationtypeid
           ,gct.type AS gct_type

           ,gcfw.gradecalcformulaweightid
           ,gcfw.teachercategoryid
           ,gcfw.districtteachercategoryid
           ,gcfw.weight
           ,gcfw.type AS gcfw_type        
        
           ,tc.teachermodified
           ,tc.name AS tc_name
           ,tc.defaultscoretype AS tc_defaultscoretype
           ,tc.isinfinalgrades AS tc_isinfinalgrades

           ,dtc.name AS dtc_name
           ,dtc.defaultscoretype AS dtc_defaultscoretype
           ,dtc.isinfinalgrades AS dtc_isinfinalgrades                
     FROM powerschool.sections sec 
     JOIN powerschool.termbins tb 
       ON sec.schoolid = tb.schoolid
      AND sec.termid = tb.termid   
     JOIN powerschool.terms rt 
       ON tb.termid = rt.id
      AND sec.schoolid = rt.schoolid
     LEFT JOIN powerschool.gradeformulaset gfs 
       ON sec.dcid = gfs.sectionsdcid         
     LEFT JOIN powerschool.gradecalculationtype gct 
       ON gfs.gradeformulasetid = gct.gradeformulasetid    
      AND tb.storecode = gct.storecode 
     LEFT JOIN powerschool.gradecalcformulaweight gcfw 
       ON gct.gradecalculationtypeid = gcfw.gradecalculationtypeid
     LEFT JOIN powerschool.teachercategory tc 
       ON gcfw.teachercategoryid = tc.teachercategoryid 
     LEFT JOIN powerschool.districtteachercategory dtc 
       ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
     WHERE sec.gradebooktype = 2    
    ) sub
WHERE ISNULL(gradecalcformulaweightid, gradecalculationtypeid) IS NOT NULL