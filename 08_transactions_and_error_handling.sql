USE SQLMasterLabDB;
GO

-- 1. Explicit Transaction with COMMIT
BEGIN TRANSACTION;

UPDATE dbo.Students
SET CGPA = 9.25
WHERE RollNumber = '25EE102';

SELECT StudentID, RollNumber, FullName, CGPA
FROM dbo.Students
WHERE RollNumber = '25EE102';

COMMIT TRANSACTION;
GO

-- 2. Explicit Transaction with ROLLBACK (Undo uncommitted change)
BEGIN TRANSACTION;

UPDATE dbo.Students
SET CGPA = 5.00
WHERE RollNumber = '25EE102';

-- Check before rollback
SELECT RollNumber, FullName, CGPA AS UncommittedCGPA
FROM dbo.Students
WHERE RollNumber = '25EE102';

ROLLBACK TRANSACTION;

-- Verify rolled back value
SELECT RollNumber, FullName, CGPA AS RestoredCGPA
FROM dbo.Students
WHERE RollNumber = '25EE102';
GO

-- 3. SAVE TRANSACTION (Partial Rollback using SAVE TRAN)
BEGIN TRANSACTION;

UPDATE dbo.Students
SET CGPA = 9.35
WHERE RollNumber = '25EE101';

SAVE TRANSACTION BeforeSecondUpdate;

-- Intentional invalid insert (duplicate RollNumber -> fails unique constraint)
BEGIN TRY
    INSERT INTO dbo.Students (RollNumber, FirstName, LastName, Email, Gender, DateOfBirth, CGPA, DeptID, IsActive)
    VALUES ('25EE101', N'Duplicate', N'User', 'dup.ee25@nits.ac.in', 'M', '2006-01-01', 8.00, 1, 1);
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
    ROLLBACK TRANSACTION BeforeSecondUpdate;
END CATCH;

COMMIT TRANSACTION;
GO

-- 4. TRY...CATCH with XACT_ABORT & THROW (Production Error Pattern)
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_SafeEnrollStudent
    @StudentID INT,
    @CourseID INT,
    @Grade VARCHAR(5) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Enrollments (StudentID, CourseID, EnrollmentDate, Grade)
        VALUES (@StudentID, @CourseID, CAST(GETDATE() AS DATE), @Grade);

        COMMIT TRANSACTION;
        SELECT 'Enrollment succeeded' AS StatusMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- Valid enrollment test
EXEC dbo.usp_SafeEnrollStudent @StudentID = 1002, @CourseID = 102, @Grade = 'AB';
GO

-- Invalid FK test (CourseID 999 does not exist)
BEGIN TRY
    EXEC dbo.usp_SafeEnrollStudent @StudentID = 1002, @CourseID = 999, @Grade = 'AA';
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO
