USE SQLMasterLabDB;
GO

-- 1. Local Temporary Table (#Temp) & Table Variable (@Tbl)
IF OBJECT_ID('tempdb..#HighPerformers') IS NOT NULL
    DROP TABLE #HighPerformers;
GO

CREATE TABLE #HighPerformers (
    StudentID INT PRIMARY KEY,
    RollNumber VARCHAR(20),
    FullName NVARCHAR(120),
    CGPA DECIMAL(4, 2)
);

INSERT INTO #HighPerformers (StudentID, RollNumber, FullName, CGPA)
SELECT StudentID, RollNumber, FullName, CGPA
FROM dbo.Students
WHERE CGPA >= 8.50;

DECLARE @SummaryLog TABLE (
    Category VARCHAR(40),
    RowCountVal INT
);

INSERT INTO @SummaryLog (Category, RowCountVal)
SELECT 'HighPerformersCount', COUNT(*) FROM #HighPerformers;

SELECT * FROM #HighPerformers ORDER BY CGPA DESC;
SELECT * FROM @SummaryLog;
GO

-- 2. MERGE Statement (Upsert Pattern: Update matched, Insert new, optionally Delete unmatched)
IF OBJECT_ID('tempdb..#CgpaUpdates') IS NOT NULL
    DROP TABLE #CgpaUpdates;
GO

CREATE TABLE #CgpaUpdates (
    RollNumber VARCHAR(20) PRIMARY KEY,
    FirstName NVARCHAR(60),
    LastName NVARCHAR(60),
    Email VARCHAR(120),
    Gender CHAR(1),
    DateOfBirth DATE,
    CGPA DECIMAL(4, 2),
    DeptID INT,
    IsActive BIT
);

INSERT INTO #CgpaUpdates
VALUES
    ('25EE101', N'Aarav', N'Sharma', 'aarav.ee25@nits.ac.in', 'M', '2006-04-12', 9.20, 1, 1),
    ('25EE199', N'Meera', N'Nair', 'meera.ee25@nits.ac.in', 'F', '2006-07-19', 8.95, 1, 1);

MERGE dbo.Students AS target
USING #CgpaUpdates AS source
    ON target.RollNumber = source.RollNumber
WHEN MATCHED AND ISNULL(target.CGPA, -1) <> ISNULL(source.CGPA, -1) THEN
    UPDATE SET
        target.CGPA = source.CGPA,
        target.IsActive = source.IsActive
WHEN NOT MATCHED BY TARGET THEN
    INSERT (RollNumber, FirstName, LastName, Email, Gender, DateOfBirth, CGPA, DeptID, IsActive)
    VALUES (
        source.RollNumber, source.FirstName, source.LastName, source.Email,
        source.Gender, source.DateOfBirth, source.CGPA, source.DeptID, source.IsActive
    )
OUTPUT
    $action AS MergeAction,
    inserted.RollNumber,
    inserted.FullName,
    inserted.CGPA AS NewCGPA;
GO

-- Clean up test row 25EE199 so lab data stays clean
DELETE FROM dbo.Students WHERE RollNumber = '25EE199';
GO

-- 3. Safe Parameterized Dynamic SQL (sp_executesql — SQL Injection Safe)
CREATE OR ALTER PROCEDURE dbo.usp_SearchStudentsDynamic
    @MinCGPA DECIMAL(4, 2) = NULL,
    @DeptID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'
        SELECT StudentID, RollNumber, FullName, DeptID, CGPA
        FROM dbo.Students
        WHERE 1 = 1';

    IF @MinCGPA IS NOT NULL
        SET @sql += N' AND CGPA >= @pMinCGPA';

    IF @DeptID IS NOT NULL
        SET @sql += N' AND DeptID = @pDeptID';

    SET @sql += N' ORDER BY CGPA DESC, StudentID ASC;';

    EXEC sp_executesql
        @stmt = @sql,
        @params = N'@pMinCGPA DECIMAL(4, 2), @pDeptID INT',
        @pMinCGPA = @MinCGPA,
        @pDeptID = @DeptID;
END;
GO

EXEC dbo.usp_SearchStudentsDynamic @MinCGPA = 8.50, @DeptID = 1;
GO
