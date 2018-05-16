USE gabby
GO

CREATE OR ALTER VIEW extracts.mailroute_new_users AS

SELECT REPLACE(mail,'kippnj','teamschools') AS email_addr
FROM gabby.adsi.user_attributes
WHERE createtimestamp >= CONVERT(DATE,DATEADD(HOUR,-144,SYSDATETIME()))
  AND mail IS NOT NULL
  AND company != 'KIPP Miami'