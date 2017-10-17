USE gabby
GO

CREATE OR ALTER VIEW illuminate_standards.standards_domain AS

SELECT s2.standard_id AS domain_standard_id
      ,s2.custom_code AS domain_custom_code
      ,s2.description AS domain_description
      ,s2.label AS domain_label
      ,s1.standard_id
      ,s1.custom_code
FROM gabby.illuminate_standards.standards s2
JOIN gabby.illuminate_standards.standards s1  
  ON CHARINDEX('.' + s2.custom_code + '.', '.' + s1.custom_code) > 0
 AND s1.level > 1
WHERE s2.level = 1 