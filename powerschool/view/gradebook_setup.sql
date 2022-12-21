CREATE OR ALTER VIEW
  powerschool.gradebook_setup AS
WITH
  gfs AS (
    SELECT
      CAST(sec.dcid AS INT) AS sectionsdcid,
      CAST(sec.schoolid AS INT) AS schoolid,
      CAST(sec.termid AS INT) AS termid,
      gsec.gradeformulasetid AS section_gradeformulasetid,
      gsfa.gradeformulasetid AS school_gradeformulasetid,
      CAST(
        COALESCE(
          gsec.gradeformulasetid,
          gsfa.gradeformulasetid,
          0
        ) AS INT
      ) AS gradeformulasetid
    FROM
      powerschool.sections AS sec
      INNER JOIN powerschool.schools AS sch ON (sec.schoolid = sch.school_number)
      LEFT JOIN powerschool.gradesectionconfig AS gsec ON (
        sec.dcid = gsec.sectionsdcid
        AND gsec.[type] = 'Admin'
      )
      LEFT JOIN powerschool.gradeschoolconfig AS gsch ON (
        sch.dcid = gsch.schoolsdcid
        AND LEFT(sec.termid, 2) = gsch.yearid
      )
      LEFT JOIN powerschool.gradeschoolformulaassoc AS gsfa ON (
        gsch.gradeschoolconfigid = gsfa.gradeschoolconfigid
        AND gsfa.isdefaultformulaset = 1
      )
    WHERE
      /* PTP */
      sec.gradebooktype = 2
  ),
  cat AS (
    SELECT
      gfs.sectionsdcid,
      gfs.gradeformulasetid,
      CAST(gfs.[name] AS VARCHAR(125)) AS grade_formula_set_name,
      CAST(t.abbreviation AS VARCHAR(5)) AS term_abbreviation,
      CAST(tb.storecode AS VARCHAR(5)) AS storecode,
      tb.date_1 AS term_start_date,
      tb.date_2 AS term_end_date,
      CAST(
        gct.gradecalculationtypeid AS INT
      ) AS gradecalculationtypeid,
      CAST(gct.[type] AS VARCHAR(25)) AS grade_calculation_type,
      CAST(
        gcfw.gradecalcformulaweightid AS INT
      ) AS gradecalcformulaweightid,
      CAST(gcfw.[type] AS VARCHAR(25)) AS grade_calc_formula_weight_type,
      CAST(gcfw.teachercategoryid AS INT) AS teachercategoryid,
      CAST(
        gcfw.districtteachercategoryid AS INT
      ) AS districtteachercategoryid,
      gcfw.[weight],
      CAST(tc.[name] AS VARCHAR(125)) AS tc_name,
      CAST(tc.defaultscoretype AS INT) AS tc_defaultscoretype,
      CAST(tc.isinfinalgrades AS INT) AS tc_isinfinalgrades,
      CAST(dtc.[name] AS VARCHAR(125)) AS dtc_name,
      CAST(dtc.defaultscoretype AS INT) AS dtc_defaultscoretype,
      CAST(dtc.isinfinalgrades AS INT) AS dtc_isinfinalgrades
    FROM
      gfs
      LEFT JOIN powerschool.gradeformulaset AS gfs ON (
        gfs.gradeformulasetid = gfs.gradeformulasetid
      )
      LEFT JOIN powerschool.terms AS t ON (
        gfs.termid = t.id
        AND gfs.schoolid = t.schoolid
      )
      INNER JOIN powerschool.termbins AS tb ON (
        t.schoolid = tb.schoolid
        AND t.id = tb.termid
      )
      LEFT JOIN powerschool.gradecalculationtype AS gct ON (
        gfs.gradeformulasetid = gct.gradeformulasetid
        AND t.abbreviation = gct.abbreviation
        AND tb.storecode = gct.storecode
      )
      LEFT JOIN powerschool.gradecalcformulaweight AS gcfw ON (
        gct.gradecalculationtypeid = gcfw.gradecalculationtypeid
      )
      LEFT JOIN powerschool.teachercategory AS tc ON (
        gcfw.teachercategoryid = tc.teachercategoryid
      )
      LEFT JOIN powerschool.districtteachercategory AS dtc ON (
        gcfw.districtteachercategoryid = dtc.districtteachercategoryid
      )
  )
SELECT
  sectionsdcid,
  sectionsdcid AS psm_sectionid,
  term_abbreviation,
  term_start_date,
  term_end_date,
  storecode,
  gradeformulasetid,
  grade_formula_set_name,
  gradecalculationtypeid,
  grade_calculation_type,
  gradecalcformulaweightid,
  grade_calc_formula_weight_type,
  [weight],
  gradeformulasetid AS finalgradesetupid,
  grade_calculation_type AS finalgradesetuptype,
  gradecalculationtypeid AS fg_reportingtermid,
  COALESCE(
    gradecalculationtypeid,
    gradecalcformulaweightid,
    -1
  ) AS gradingformulaid,
  COALESCE(
    grade_calculation_type,
    grade_calc_formula_weight_type
  ) AS gradingformulaweightingtype,
  COALESCE(
    teachercategoryid,
    districtteachercategoryid,
    gradecalculationtypeid,
    -1
  ) AS assignmentcategoryid,
  COALESCE(
    tc_name,
    dtc_name,
    grade_calculation_type
  ) AS category_name,
  COALESCE(
    tc_name,
    dtc_name,
    grade_calculation_type
  ) AS category_abbreviation,
  COALESCE(
    tc_defaultscoretype,
    dtc_defaultscoretype
  ) AS defaultscoretype,
  COALESCE(
    tc_isinfinalgrades,
    dtc_isinfinalgrades,
    0
  ) AS includeinfinalgrades
FROM
  cat
