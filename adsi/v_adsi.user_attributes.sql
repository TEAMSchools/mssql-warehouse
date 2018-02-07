USE gabby
GO

CREATE OR ALTER VIEW adsi.user_attributes AS

SELECT cn
      ,company
      ,createtimestamp
      ,department
      ,CONVERT(VARCHAR(125),displayname) AS displayname
      ,distinguishedname
      ,employeeid
      ,CONVERT(VARCHAR(125),employeenumber) AS employeenumber
      ,CONVERT(VARCHAR(125),givenname) AS givenname
      ,homephone
      ,homepostaladdress
      ,CONVERT(VARCHAR(125),idautopersonalternateid) AS idautopersonalternateid
      ,CONVERT(VARCHAR(1),idautostatus) AS idautostatus
      ,l
      ,logoncount
      ,CONVERT(VARCHAR(125),mail) AS mail
      ,manager
      ,middlename
      ,mobile
      ,modifytimestamp
      ,name
      ,objectcategory
      ,CONVERT(VARCHAR(125),physicaldeliveryofficename) AS physicaldeliveryofficename
      ,CONVERT(VARCHAR(125),samaccountname) AS samaccountname
      ,CONVERT(VARCHAR(125),sn) AS sn
      ,telephonenumber
      ,textencodedoraddress
      ,CONVERT(VARCHAR(125),title) AS title
      ,useraccountcontrol
      ,CONVERT(VARCHAR(125),userprincipalname) AS userprincipalname
      ,DATEADD(MINUTE
              /* number of 10 minute intervals (in microseconds) since last reset, offset by time zone...holy shit */
              ,(CONVERT(BIGINT,pwdlastset) / 600000000) + DATEDIFF(MINUTE,GETUTCDATE(),GETDATE())
              /* origin date for DATETIME2 */
              ,CAST('1/1/1601' AS DATETIME2)) AS pwdlastset
      ,CASE WHEN useraccountcontrol & 2 = 0 THEN 1 ELSE 0 END AS is_active
      ,CASE WHEN distinguishedname LIKE '%OU=Student%' THEN 1 ELSE 0 END AS is_student
FROM OPENQUERY(ADSI,'
  SELECT cn
        ,company        
        ,createTimeStamp                
        ,department                
        ,displayName        
        ,distinguishedname
        ,employeeID        
        ,employeenumber
        ,givenName        
        ,homePhone
        ,homePostalAddress 
        ,idautoPersonALternateID 
        ,idautostatus       
        ,l        
        ,logonCount
        ,mail        
        ,manager        
        ,middleName
        ,mobile
        ,modifyTimeStamp        
        ,name
        ,objectCategory          
        ,physicalDeliveryOfficeName  
        ,pwdLastSet       
        ,sAMAccountName        
        ,sn        
        ,telephoneNumber
        ,textEncodedORAddress        
        ,title        
        ,useraccountcontrol
        ,userPrincipalName     
  FROM ''LDAP://KNJDC01.teamschools.kipp.org/OU=Users,OU=TEAM,DC=teamschools,DC=kipp,DC=org''    
  WHERE objectCategory = ''Person''
')