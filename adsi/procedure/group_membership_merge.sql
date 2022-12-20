CREATE
OR ALTER
PROCEDURE adsi.group_membership_merge AS BEGIN
SET
ANSI_NULLS ON;

SET
QUOTED_IDENTIFIER ON;

/*
SET NOCOUNT ON added to prevent extra result sets 
from interfering with SELECT statements
 */
SET
NOCOUNT ON;

DECLARE @group_adspath NVARCHAR(256),
@group_cn NVARCHAR(256),
@sql NVARCHAR(MAX);

/* Drop and recreate the temp tables */
DROP TABLE IF EXISTS [#ad_group_membership];

CREATE TABLE
  [#ad_group_membership] (
    object_guid UNIQUEIDENTIFIER,
    employee_number NVARCHAR(256),
    associate_id NVARCHAR(256),
    user_principal_name NVARCHAR(256),
    mail NVARCHAR(256),
    group_cn NVARCHAR(256),
    group_adspath NVARCHAR(256)
  );

/* loop over all AD groups */
DECLARE group_cursor CURSOR FOR
SELECT
  REPLACE(
    ADsPath,
    'LDAP://',
    ''
  ) AS ADsPath,
  cn
FROM
  OPENQUERY (
    ADSI,
    '
      SELECT ADsPath, cn
      FROM ''LDAP://DC=teamschools,DC=kipp,DC=org''
      WHERE objectCategory = ''group''
    '
  );

OPEN group_cursor;

FETCH NEXT
FROM
  group_cursor INTO @group_adspath,
  @group_cn;

WHILE @@FETCH_STATUS = 0 BEGIN
FETCH NEXT
FROM
  group_cursor INTO @group_adspath,
  @group_cn;

/* get membership list and insert into temp table */
SET
  @sql = N'
            INSERT INTO [#ad_group_membership]
            SELECT 
              objectGUID AS object_guid,
              employeenumber AS employee_number,
              idautopersonalternateid AS associate_id,
              userPrincipalName AS user_principal_name,
              mail,
              ''' + @group_cn + ''' AS group_cn,
              ''' + @group_adspath + ''' AS group_adspath
            FROM OPENQUERY(ADSI, ''
              SELECT 
                userPrincipalName,
                employeenumber,
                idautopersonalternateid,
                mail,
                objectGUID
              FROM ''''LDAP://DC=teamschools,DC=kipp,DC=org''''
              WHERE memberOf = ''''' + @group_adspath + '''''
            '')
          ';

RAISERROR (@sql, 0, 1);

EXEC (@sql);

END;

CLOSE group_cursor;

DEALLOCATE group_cursor;

IF OBJECT_ID(
  N'gabby.adsi.group_membership'
) IS NULL BEGIN
SELECT
  * INTO gabby.adsi.group_membership
FROM
  [#ad_group_membership];

END;

ELSE BEGIN
/* merge temp table into destination table */
MERGE
  gabby.adsi.group_membership AS tgt USING [#ad_group_membership] AS src ON tgt.group_adspath = src.group_adspath
  AND tgt.object_guid = src.object_guid
WHEN MATCHED THEN
UPDATE SET
  tgt.employee_number = src.employee_number,
  tgt.associate_id = src.associate_id,
  tgt.user_principal_name = src.user_principal_name,
  tgt.mail = src.mail,
  tgt.group_cn = src.group_cn
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (
    group_adspath,
    object_guid,
    employee_number,
    associate_id,
    user_principal_name,
    mail,
    group_cn
  )
VALUES
  (
    src.group_adspath,
    src.object_guid,
    src.employee_number,
    src.associate_id,
    src.user_principal_name,
    src.mail,
    src.group_cn
  )
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

END;

END;
