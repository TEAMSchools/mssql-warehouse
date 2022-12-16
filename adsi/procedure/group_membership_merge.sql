SET
ANSI_NULLS ON GO
SET
QUOTED_IDENTIFIER ON GO CREATE
OR ALTER
PROCEDURE adsi.group_membership_merge AS BEGIN
/* SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements */
SET
NOCOUNT ON;

DECLARE @group_adspath NVARCHAR(256),
@group_cn NVARCHAR(256),
@sql NVARCHAR(MAX);

/* Drop and recreate the temp tables */
IF OBJECT_ID(N'tempdb..#ad_group_membership') IS NOT NULL
DROP TABLE [#ad_group_membership]
CREATE TABLE
  [#ad_group_membership] (
    object_guid UNIQUEIDENTIFIER,
    employee_number NVARCHAR(256),
    associate_id NVARCHAR(256),
    user_principal_name NVARCHAR(256),
    mail NVARCHAR(256),
    group_cn NVARCHAR(256),
    group_adspath NVARCHAR(256)
  )
  /* loop over all AD groups */
  DECLARE group_cursor CURSOR FOR
SELECT
  REPLACE(ADsPath, 'LDAP://', '') AS ADsPath,
  cn
FROM
  OPENQUERY (
    ADSI,
    '
      SELECT ADsPath, cn
      FROM ''LDAP://DC=teamschools,DC=kipp,DC=org''
      WHERE objectCategory = ''group''
    '
  ) OPEN group_cursor;

WHILE 1 = 1 BEGIN
FETCH NEXT
FROM
  group_cursor INTO @group_adspath,
  @group_cn;

IF @@FETCH_STATUS != 0 BEGIN BREAK;

END
/* get membership list and insert into temp table */
SET
  @sql = N'
            INSERT INTO [#ad_group_membership]
            SELECT objectGUID AS object_guid
                  ,employeenumber AS employee_number
                  ,idautopersonalternateid AS associate_id
                  ,userPrincipalName AS user_principal_name
                  ,mail
                  ,''' + @group_cn + ''' AS group_cn
                  ,''' + @group_adspath + ''' AS group_adspath
            FROM OPENQUERY(ADSI, ''
              SELECT userPrincipalName, employeenumber, idautopersonalternateid, mail, objectGUID
              FROM ''''LDAP://DC=teamschools,DC=kipp,DC=org''''
              WHERE memberOf = ''''' + @group_adspath + '''''
            '')
          ' RAISERROR (@sql, 0, 1) EXEC (@sql) END CLOSE group_cursor;

DEALLOCATE group_cursor;

IF OBJECT_ID(N'gabby.adsi.group_membership') IS NULL BEGIN
SELECT
  * INTO gabby.adsi.group_membership
FROM
  [#ad_group_membership] END ELSE BEGIN
  /* merge temp table into destination table */
MERGE
  gabby.adsi.group_membership AS TARGET USING [#ad_group_membership] AS SOURCE ON TARGET.group_adspath = SOURCE.group_adspath
  AND TARGET.object_guid = SOURCE.object_guid
WHEN MATCHED THEN
UPDATE SET
  TARGET.employee_number = SOURCE.employee_number,
  TARGET.associate_id = SOURCE.associate_id,
  TARGET.user_principal_name = SOURCE.user_principal_name,
  TARGET.mail = SOURCE.mail,
  TARGET.group_cn = SOURCE.group_cn
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
    SOURCE.group_adspath,
    SOURCE.object_guid,
    SOURCE.employee_number,
    SOURCE.associate_id,
    SOURCE.user_principal_name,
    SOURCE.mail,
    SOURCE.group_cn
  )
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

END END GO
