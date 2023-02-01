DECLARE @sql NVARCHAR(MAX),
@username NVARCHAR(32) = N'',
@password NVARCHAR(128) = N'';

SET
  @sql = N'
CREATE LOGIN [' + @username + '] 
    WITH 
        PASSWORD = ''' + @password + ''', 
        DEFAULT_DATABASE = [gabby], 
        CHECK_POLICY = OFF
        CHECK_EXPIRATION = OFF, 
GO

USE [gabby]
GO
CREATE USER [' + @username + '] FOR LOGIN [' + @username + ']
GO
ALTER ROLE [db_executor] ADD MEMBER [' + @username + ']
GO
ALTER ROLE [db_datareader] ADD MEMBER [' + @username + ']
GO

USE [kippcamden]
GO
CREATE USER [' + @username + '] FOR LOGIN [' + @username + ']
GO
ALTER ROLE [db_datareader] ADD MEMBER [' + @username + ']
GO

USE [kippmiami]
GO
CREATE USER [' + @username + '] FOR LOGIN [' + @username + ']
GO
ALTER ROLE [db_datareader] ADD MEMBER [' + @username + ']
GO

USE [kippnewark]
GO
CREATE USER [' + @username + '] FOR LOGIN [' + @username + ']
GO
ALTER ROLE [db_datareader] ADD MEMBER [' + @username + ']
GO

USE [kipptaf]
GO
CREATE USER [' + @username + '] FOR LOGIN [' + @username + ']
GO
ALTER ROLE [db_datareader] ADD MEMBER [' + @username + ']
GO
';

-- noqa: L016
RAISERROR (@sql, 0, 0);
