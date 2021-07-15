BEGIN TRANSACTION
 SET QUOTED_IDENTIFIER ON
 SET ARITHABORT ON
 SET NUMERIC_ROUNDABORT OFF
 SET CONCAT_NULL_YIELDS_NULL ON
 SET ANSI_NULLS ON
 SET ANSI_PADDING ON
 SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION
GO
  CREATE TABLE people.employee_numbers
      (
       associate_id nvarchar(256) NULL,
       associate_id_legacy nvarchar(256) NULL,
       employee_number int NOT NULL IDENTITY (1, 1)
      )  ON [PRIMARY]
  GO

  ALTER TABLE people.employee_numbers ADD CONSTRAINT
      PK_people_employee_numbers PRIMARY KEY CLUSTERED (employee_number) 
      WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  GO

  ALTER TABLE people.employee_numbers SET (LOCK_ESCALATION = TABLE)
  GO
COMMIT

SET IDENTITY_INSERT people.employee_numbers ON;

INSERT INTO people.employee_numbers
    (associate_id, associate_id_legacy, employee_number)
SELECT associate_id, associate_id_legacy, employee_number
FROM
    (
     SELECT adp.associate_id
           ,df.adp_associate_id AS associate_id_legacy
           ,adp.file_number AS employee_number
     FROM gabby.adp.employees_all adp
     LEFT JOIN gabby.dayforce.employees df
       ON adp.file_number = df.df_employee_number

     UNION

     SELECT adp.associate_id
           ,df.adp_associate_id AS associate_id_legacy
           ,df.df_employee_number
     FROM gabby.dayforce.employees df
     LEFT JOIN gabby.adp.employees adp
       ON df.df_employee_number = adp.file_number
    ) sub
WHERE sub.employee_number IS NOT NULL;

SET IDENTITY_INSERT people.employee_numbers OFF;

DECLARE @maxid INT;
SELECT @maxid = MAX(employee_number) FROM people.employee_numbers;
DBCC CHECKIDENT('people.employee_numbers', RESEED, @maxid);
