USE SQLMasterLabDB;
GO

-- 1. Create Custom Database Role & Assign Permissions
IF DATABASE_PRINCIPAL_ID('LabReadOnlyRole') IS NULL
BEGIN
    CREATE ROLE LabReadOnlyRole;
END;
GO

GRANT SELECT ON SCHEMA::dbo TO LabReadOnlyRole;
DENY SELECT ON dbo.StudentCgpaAudit TO LabReadOnlyRole;
GO

-- 2. Dynamic Data Masking (Protect sensitive fields like Email & PhoneNumber)
-- Note: Add or alter mask safely
IF NOT EXISTS (
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID('dbo.Students')
      AND name = 'Email'
)
BEGIN
    ALTER TABLE dbo.Students
    ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID('dbo.Students')
      AND name = 'PhoneNumber'
)
BEGIN
    ALTER TABLE dbo.Students
    ALTER COLUMN PhoneNumber ADD MASKED WITH (FUNCTION = 'partial(2, "XXXXXX", 2)');
END;
GO

-- 3. Create Contained / Database User & Test Impersonation (EXECUTE AS)
IF DATABASE_PRINCIPAL_ID('LabAuditorUser') IS NULL
BEGIN
    CREATE USER LabAuditorUser WITHOUT LOGIN;
END;
GO

ALTER ROLE LabReadOnlyRole ADD MEMBER LabAuditorUser;
GO

-- Test how LabAuditorUser sees masked columns
EXECUTE AS USER = 'LabAuditorUser';
SELECT TOP 5 StudentID, RollNumber, FullName, Email, PhoneNumber, CGPA
FROM dbo.Students;
REVERT;
GO

-- 4. Inspect Active Permissions & Masked Columns
SELECT
    OBJECT_NAME(mc.object_id) AS TableName,
    c.name AS ColumnName,
    mc.masking_function
FROM sys.masked_columns mc
INNER JOIN sys.columns c
    ON mc.object_id = c.object_id
   AND mc.column_id = c.column_id;
GO
