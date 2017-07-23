USE gabby
GO

ALTER VIEW utilities.fivetran_audit AS

SELECT * FROM alumni.fivetran_audit UNION
SELECT * FROM illuminate_groups.fivetran_audit UNION
SELECT * FROM illuminate_standards.fivetran_audit UNION
SELECT * FROM illuminate_dna_assessments.fivetran_audit UNION
SELECT * FROM illuminate_public.fivetran_audit UNION
SELECT * FROM illuminate_codes.fivetran_audit UNION
SELECT * FROM illuminate_dna_repositories.fivetran_audit UNION
SELECT * FROM recruiting.fivetran_audit UNION
SELECT * FROM newarkenrolls.fivetran_audit UNION
SELECT * FROM nwea.fivetran_audit UNION
SELECT * FROM asana.fivetran_audit UNION
SELECT * FROM zendesk.fivetran_audit UNION
SELECT * FROM deanslist.fivetran_audit UNION
SELECT * FROM naviance.fivetran_audit UNION
SELECT * FROM steptool.fivetran_audit UNION
SELECT * FROM powerschool.fivetran_audit UNION
SELECT * FROM reporting.fivetran_audit UNION
SELECT * FROM stmath.fivetran_audit UNION
SELECT * FROM caredox.fivetran_audit UNION
SELECT * FROM easyiep.fivetran_audit UNION
SELECT * FROM renaissance.fivetran_audit UNION
SELECT * FROM finance.fivetran_audit UNION
SELECT * FROM lit.fivetran_audit UNION
SELECT * FROM enrollment.fivetran_audit UNION
SELECT * FROM adp.fivetran_audit UNION
SELECT * FROM lexia.fivetran_audit