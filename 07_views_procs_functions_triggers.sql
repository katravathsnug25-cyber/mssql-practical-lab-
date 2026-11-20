USE SQLMasterLabDB;
GO

-- 1. VIEW (Student Academic Summary)
CREATE OR ALTER VIEW dbo.vw_StudentAcademicSummary
AS
SELECT
    s.StudentID,
    s.RollNumber,
    s.FullName,
    d.DeptCode,
    d.DeptName,
    s.CGPA,
    s.IsActive
FROM dbo.Students s
INNER JOIN dbo.Departments d ON s.DeptID = d.DeptID;
GO

SELECT * FROM dbo.vw_StudentAcademicSummary ORDER BY CGPA DESC;
GO

-- 2. SCALAR FUNCTION (CGPA Grade Band)
CREATE OR ALTER FUNCTION dbo.fn_GetCgpaBand (@CGPA DECIMAL(4, 2))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Band NVARCHAR(20);
    SET @Band = CASE
        WHEN @CGPA >= 9.00 THEN N'First Class Distinction'
        WHEN @CGPA >= 7.50 THEN N'First Class'
        WHEN @CGPA >= 6.00 THEN N'Second Class'
        ELSE N'Needs Improvement'
    END;
    RETURN @Band;
END;
GO

SELECT
    RollNumber,
    FullName,
    CGPA,
    dbo.fn_GetCgpaBand(CGPA) AS GradeBand
FROM dbo.Students;
GO

-- 3. STORED PROCEDURE (Get Top Students by Department)
CREATE OR ALTER PROCEDURE dbo.usp_GetTopStudentsByDept
    @DeptCode VARCHAR(10),
    @TopN INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        s.RollNumber,
        s.FullName,
        d.DeptCode,
        s.CGPA
    FROM dbo.Students s
    INNER JOIN dbo.Departments d ON s.DeptID = d.DeptID
    WHERE d.DeptCode = @DeptCode
    ORDER BY s.CGPA DESC;
END;
GO

EXEC dbo.usp_GetTopStudentsByDept @DeptCode = 'EE', @TopN = 2;
GO

-- 4. AUDIT TABLE & DML TRIGGER (Track CGPA Updates)
IF OBJECT_ID('dbo.StudentCgpaAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StudentCgpaAudit (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        StudentID INT NOT NULL,
        OldCGPA DECIMAL(4, 2) NULL,
        NewCGPA DECIMAL(4, 2) NULL,
        ChangedAt DATETIME2 DEFAULT SYSDATETIME()
    );
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_Students_CgpaUpdate
ON dbo.Students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(CGPA)
    BEGIN
        INSERT INTO dbo.StudentCgpaAudit (StudentID, OldCGPA, NewCGPA)
        SELECT
            i.StudentID,
            d.CGPA,
            i.CGPA
        FROM inserted i
        INNER JOIN deleted d ON i.StudentID = d.StudentID
        WHERE ISNULL(d.CGPA, -1) <> ISNULL(i.CGPA, -1);
    END
END;
GO

-- Test trigger
UPDATE dbo.Students
SET CGPA = 9.10
WHERE RollNumber = '25EE101';

SELECT * FROM dbo.StudentCgpaAudit;
GO
