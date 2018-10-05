USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_studemo AS

SELECT student_number AS [01 Import Student ID]
      ,state_studentnumber AS [02 State Student ID]
      ,last_name AS [03 Last Name]
      ,first_name AS [04 First Name]
      ,middle_name AS [05 Middle Name]
      ,dob AS [06 Birth Date]
      ,NULL AS [07 Gender]
      ,NULL AS [08 Primary Ethnicity]
      ,NULL AS [09 Secondary Ethnicity]
      ,NULL AS [10 Tertiary Ethnicity]
      ,NULL AS [11 Is Hispanic]
      ,NULL AS [12 Primary Language]
      ,NULL AS [13 Correspondence Language]
      ,NULL AS [14 English Proficiency]
      ,NULL AS [15 Redesignation Date]
      ,CASE
		      WHEN specialed_classification IN ('PSD','CMO','CMI') THEN '210'
	       WHEN specialed_classification IN ('CI','ESLS') THEN '240'
		      WHEN specialed_classification = 'VI' THEN '250'
		      WHEN specialed_classification = 'ED' THEN '260'
		      WHEN specialed_classification = 'OI' THEN '270'
		      WHEN specialed_classification = 'OHI' THEN '280'
		      WHEN specialed_classification = 'SLD' THEN '290'
		      WHEN specialed_classification = 'MD' THEN '310'
		      WHEN specialed_classification IN ('AI','AUT') THEN '320'
		      WHEN specialed_classification = 'TBI' THEN '330'
		      ELSE NULL 
       END AS [16 Primary Disability]
      ,NULL AS [17 Migrant Ed Student ID]
      ,NULL AS [18 Lep Date]
      ,NULL AS [19 Us Entry Date]
      ,NULL AS [20 School Enter Date]
      ,NULL AS [21 District Enter Date]
      ,NULL AS [22 Parent Education Level]
      ,NULL AS [23 Residential Status]
      ,NULL AS [24 Special Needs Status]
      ,NULL AS [25 Sst Date]
      ,NULL AS [26 Plan 504 Accommodations]
      ,NULL AS [27 Plan 504 Annual Review Date]
      ,NULL AS [28 Exit Date]
      ,NULL AS [29 Birth City]
      ,NULL AS [30 Birth State]
      ,NULL AS [31 Birth Country]
      ,NULL AS [32 Lunch ID]
      ,CONCAT(academic_year, '-', (academic_year + 1)) AS [33 Academic Year]
      ,NULL AS [34 Name Suffix]
      ,NULL AS [35 Aka Last Name]
      ,NULL AS [36 Aka First Name]
      ,NULL AS [37 Aka Middle Name]
      ,NULL AS [38 Aka Name Suffix]
      ,NULL AS [39 Lunch Balance]
      ,NULL AS [40 Resident District Site ID]
      ,NULL AS [41 Operating District Site ID]
      ,NULL AS [42 Resident School Site ID]
      ,NULL AS [43 Birthdate Verification]
      ,NULL AS [44 Homeless Dwelling Type]
      ,NULL AS [45 Photo Release]
      ,NULL AS [46 Military Recruitment]
      ,NULL AS [47 Internet Release]
      ,NULL AS [48 Graduation Date]
      ,NULL AS [49 Graduation Status]
      ,NULL AS [50 Service Learning Hours]
      ,NULL AS [51 Us Abroad]
      ,NULL AS [52 Military Family]
      ,NULL AS [53 Home Address Verification Date]
      ,NULL AS [54 Entry Date]
      ,NULL AS [55 Secondary Disability]
      ,NULL AS [56 State School Entry Date]
      ,NULL AS [57 Us School Entry Date]
      ,NULL AS [58 Local Student ID]
      ,NULL AS [59 School Student ID]
      ,NULL AS [60 Other Student ID]
      ,NULL AS [61 Graduation Requirement Year]
      ,NULL AS [62 Next School Site ID]
      ,NULL AS [63 Prior District]
      ,NULL AS [64 Prior School]
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND rn_year = 1
  AND schoolid != 999999