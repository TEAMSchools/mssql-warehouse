CREATE OR ALTER VIEW powerschool.gradebook_setup AS

SELECT sub.sectionsdcid
      ,sub.sectionsdcid AS psm_sectionid
      ,sub.term_abbreviation
      ,sub.term_start_date
      ,sub.term_end_date
      ,sub.storecode
      ,sub.gradeformulasetid
      ,sub.grade_formula_set_name
      ,sub.gradecalculationtypeid
      ,sub.grade_calculation_type
      ,sub.gradecalcformulaweightid
      ,sub.grade_calc_formula_weight_type
      ,sub.[weight]

      ,sub.gradeformulasetid AS finalgradesetupid
      ,sub.grade_calculation_type AS finalgradesetuptype
      ,sub.gradecalculationtypeid AS fg_reportingtermid
      
      ,COALESCE(sub.gradecalculationtypeid, sub.gradecalcformulaweightid, -1) AS gradingformulaid
      ,COALESCE(sub.grade_calculation_type, sub.grade_calc_formula_weight_type) AS gradingformulaweightingtype
      ,COALESCE(sub.teachercategoryid, sub.districtteachercategoryid, sub.gradecalculationtypeid, -1) AS assignmentcategoryid
      ,COALESCE(sub.tc_name, sub.dtc_name, sub.grade_calculation_type) AS category_name
      ,COALESCE(sub.tc_name, sub.dtc_name, sub.grade_calculation_type) AS category_abbreviation
      ,COALESCE(sub.tc_defaultscoretype, sub.dtc_defaultscoretype) AS defaultscoretype
      ,COALESCE(sub.tc_isinfinalgrades, sub.dtc_isinfinalgrades, 0) AS includeinfinalgrades
FROM
    (
     SELECT sub.sectionsdcid
           ,sub.gradeformulasetid

           ,CONVERT(VARCHAR(125), gfs.[name]) AS grade_formula_set_name

           ,CAST(t.abbreviation AS VARCHAR(5)) AS term_abbreviation

           ,CAST(tb.storecode AS VARCHAR(5)) AS storecode
           ,tb.date_1 AS term_start_date
           ,tb.date_2 AS term_end_date

           ,CAST(gct.gradecalculationtypeid AS INT) AS gradecalculationtypeid
           ,CONVERT(VARCHAR(25), gct.[type]) AS grade_calculation_type

           ,CAST(gcfw.gradecalcformulaweightid AS INT) AS gradecalcformulaweightid
           ,CONVERT(VARCHAR(25), gcfw.[type]) AS grade_calc_formula_weight_type
           ,CAST(gcfw.teachercategoryid AS INT) AS teachercategoryid
           ,CAST(gcfw.districtteachercategoryid AS INT) AS districtteachercategoryid
           ,gcfw.[weight]

           ,CONVERT(VARCHAR(125), tc.[name]) AS tc_name
           ,CAST(tc.defaultscoretype AS INT) AS tc_defaultscoretype
           ,CAST(tc.isinfinalgrades AS INT) AS tc_isinfinalgrades

           ,CONVERT(VARCHAR(125), dtc.[name]) AS dtc_name
           ,CAST(dtc.defaultscoretype AS INT) AS dtc_defaultscoretype
           ,CAST(dtc.isinfinalgrades AS INT) AS dtc_isinfinalgrades
     FROM 
         (
          SELECT CAST(sec.dcid AS INT) AS sectionsdcid
                ,CAST(sec.schoolid AS INT) AS schoolid
                ,CAST(sec.termid AS INT) AS termid

                ,gsec.gradeformulasetid AS section_gradeformulasetid

                ,gsfa.gradeformulasetid AS school_gradeformulasetid

                ,CONVERT(INT, COALESCE(gsec.gradeformulasetid, gsfa.gradeformulasetid, 0)) AS gradeformulasetid
          FROM powerschool.sections sec
          INNER JOIN powerschool.schools sch
             ON sec.schoolid = sch.school_number
          LEFT JOIN powerschool.gradesectionconfig gsec
            ON sec.dcid = gsec.sectionsdcid
           AND gsec.[type] = 'Admin'
          LEFT JOIN powerschool.gradeschoolconfig gsch
            ON sch.dcid = gsch.schoolsdcid
           AND LEFT(sec.termid, 2) = gsch.yearid
          LEFT JOIN powerschool.gradeschoolformulaassoc gsfa
            ON gsch.gradeschoolconfigid = gsfa.gradeschoolconfigid
           AND gsfa.isdefaultformulaset = 1
          WHERE sec.gradebooktype = 2 /* PTP */
         ) sub
     LEFT JOIN powerschool.gradeformulaset gfs 
       ON sub.gradeformulasetid = gfs.gradeformulasetid
     LEFT JOIN powerschool.terms t
       ON sub.termid = t.id
      AND sub.schoolid = t.schoolid
     JOIN powerschool.termbins tb
       ON t.schoolid = tb.schoolid
      AND t.id = tb.termid
     LEFT JOIN powerschool.gradecalculationtype gct 
       ON gfs.gradeformulasetid = gct.gradeformulasetid
      AND t.abbreviation = gct.abbreviation
      AND tb.storecode = gct.storecode
     LEFT JOIN powerschool.gradecalcformulaweight gcfw 
       ON gct.gradecalculationtypeid = gcfw.gradecalculationtypeid
     LEFT JOIN powerschool.teachercategory tc 
       ON gcfw.teachercategoryid = tc.teachercategoryid 
     LEFT JOIN powerschool.districtteachercategory dtc 
       ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
    ) sub
