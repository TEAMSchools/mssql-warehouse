CREATE OR ALTER VIEW
  adsi.user_attributes AS
SELECT
  cn,
  company,
  createtimestamp,
  department,
  distinguishedname,
  employeeid,
  homephone,
  homepostaladdress,
  l,
  logoncount,
  manager,
  middlename,
  mobile,
  modifytimestamp,
  [name],
  objectcategory,
  telephonenumber,
  textencodedoraddress,
  useraccountcontrol,
  CAST(displayname AS VARCHAR(125)) AS displayname,
  CAST(employeenumber AS VARCHAR(125)) AS employeenumber,
  CAST(givenname AS VARCHAR(125)) AS givenname,
  CAST(idautopersonalternateid AS VARCHAR(125)) AS idautopersonalternateid,
  CAST(idautostatus AS VARCHAR(1)) AS idautostatus,
  CAST(mail AS VARCHAR(125)) AS mail,
  CAST(physicaldeliveryofficename AS VARCHAR(125)) AS physicaldeliveryofficename,
  CAST(samaccountname AS VARCHAR(125)) AS samaccountname,
  CAST(sn AS VARCHAR(125)) AS sn,
  CAST(title AS VARCHAR(125)) AS title,
  CAST(userprincipalname AS VARCHAR(125)) AS userprincipalname,
  DATEADD(
    MINUTE,
    /* number of 10 minute intervals (in microseconds)
    since last reset offset by time zone */
    (CAST(pwdlastset AS BIGINT) / 600000000) + DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), -- trunk-ignore(sqlfluff/L016)
    CAST('1601-01-01' AS DATETIME2) /* origin date for DATETIME2 */
  ) AS pwdlastset,
  CASE
    WHEN useraccountcontrol & 2 = 0 THEN 1
    ELSE 0
  END AS is_active,
  CASE
    WHEN distinguishedname LIKE '%OU=Student%' THEN 1
    ELSE 0
  END AS is_student
FROM
  OPENQUERY (
    ADSI,
    '
      SELECT
        cn,
        company,
        createTimeStamp,
        department,
        displayName,
        distinguishedname,
        employeeID,
        employeenumber,
        givenName,
        homePhone,
        homePostalAddress,
        idautoPersonALternateID,
        idautostatus,
        l,
        logonCount,
        mail,
        manager,
        middleName,
        mobile,
        modifyTimeStamp,
        name,
        objectCategory,
        physicalDeliveryOfficeName,
        pwdLastSet,
        sAMAccountName,
        sn,
        telephoneNumber,
        textEncodedORAddress,
        title,
        useraccountcontrol,
        userPrincipalName
      FROM
        ''LDAP://KNJDC01.teamschools.kipp.org/OU=Users,OU=TEAM,DC=teamschools,DC=kipp,DC=org''
      WHERE
        objectCategory = ''Person''
    '
  )
