SELECT 'PH3' AS ColA
      ,'10046698' AS ColB -- account code
      ,'KIPP NEWARK COLLEGIATE ACADEMY' AS ColC -- account name
      ,'P' AS ColD
      ,CONVERT(VARCHAR,REPLACE(CAST(CURRENT_TIMESTAMP AS DATE), '-', '')) AS ColE -- file transmission date
      ,CONCAT(MIN(cohort),'-',MAX(cohort)) AS ColF -- diploma period
      ,NULL AS ColG
      ,NULL AS ColH
      ,NULL AS ColI
      ,NULL AS ColJ
      ,NULL AS ColK
      ,NULL AS ColL
      ,NULL AS ColM
      ,NULL AS ColN
      ,NULL AS ColO
      ,NULL AS ColP
      ,NULL AS ColQ
      ,NULL AS ColR
      ,NULL AS ColS
      ,NULL AS ColT
      ,NULL AS ColU
      ,NULL AS ColV
      ,NULL AS ColW
      ,NULL AS ColX
      ,NULL AS ColY
      ,NULL AS ColZ
      ,NULL AS ColAA
      ,NULL AS ColAB
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.grade_level = 12
  AND co.exitcode = 'G1'

UNION ALL

SELECT 'PD3' AS ColA
      ,'NO SSN' AS ColB
      ,co.first_name ColC -- first name
      ,NULL AS ColD -- middle name
      ,co.last_name AS ColE -- last name
      ,NULL AS ColF -- name suffix
      ,NULL AS ColG -- prev last name
      ,NULL AS ColH -- prev first name
      ,CONVERT(VARCHAR,REPLACE(CAST(co.DOB AS DATE),'-','')) AS ColI -- date of birth
      ,co.student_number AS ColJ -- student ID
      ,'Regular Diploma' AS ColK -- diploma type
      ,CONVERT(VARCHAR,REPLACE(CAST(co.exitdate AS DATE),'-','')) AS ColL -- HS graduation date
      ,'N' AS ColM -- FERPA block
      ,'KIPP NEWARK COLLEGIATE ACADEMY' AS ColN -- high school name
      ,'310986' AS ColO -- ACT code
      ,NULL AS ColP -- gender
      ,NULL AS ColQ -- ethnicity
      ,NULL AS ColR -- econ disadvantaged
      ,NULL AS ColS -- 8th gr state assessment - math
      ,NULL AS ColT -- 8th gr state assessment - ela
      ,NULL AS ColU -- HS state assessment - math
      ,NULL AS ColV -- HS gr state assessment - ela
      ,NULL AS ColW -- ELL
      ,NULL AS ColX -- # semseters of math
      ,NULL AS ColY -- dual enrollment
      ,NULL AS ColZ -- disability code
      ,NULL AS ColAA -- program code
      ,'ED' AS ColAB
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.school_level = 'HS'
  AND co.exitcode = 'G1'

UNION ALL

SELECT 'PT3' AS ColA
      ,CONVERT(VARCHAR,COUNT(student_number) + 2) AS ColB
      ,NULL AS ColC
      ,NULL AS ColD
      ,NULL AS ColE
      ,NULL AS ColF
      ,NULL AS ColG
      ,NULL AS ColH
      ,NULL AS ColI
      ,NULL AS ColJ
      ,NULL AS ColK
      ,NULL AS ColL
      ,NULL AS ColM
      ,NULL AS ColN
      ,NULL AS ColO
      ,NULL AS ColP
      ,NULL AS ColQ
      ,NULL AS ColR
      ,NULL AS ColS
      ,NULL AS ColT
      ,NULL AS ColU
      ,NULL AS ColV
      ,NULL AS ColW
      ,NULL AS ColX
      ,NULL AS ColY
      ,NULL AS ColZ
      ,NULL AS ColAA
      ,NULL AS ColAB
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.school_level = 'HS'
  AND co.exitcode = 'G1'