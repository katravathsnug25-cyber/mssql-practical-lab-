/*
================================================================================
File        : 01_database_and_tables.sql
Database    : SQLMasterLabDB
Description : Covers Database creation, Data Types, Table creation, all SQL 
              Constraints (PK, FK, UNIQUE, CHECK, DEFAULT, NOT NULL, IDENTITY),
              and DDL operations (ALTER, TRUNCATE, DROP).
================================================================================
*/

-- 1. Create & Select Database
IF DB_ID('SQLMasterLabDB') IS NULL
BEGIN
    CREATE DATABASE SQLMasterLabDB;
END;
GO

USE SQLMasterLabDB;
GO

-- 2. Clean Reset (Drop tables in reverse dependency order if re-running)
DROP TABLE IF EXISTS dbo.Enrollments;
DROP TABLE IF EXISTS dbo.Courses;
DROP TABLE IF EXISTS dbo.Students;
DROP TABLE IF EXISTS dbo.Departments;
GO

-- 3. Parent Table: Departments (PRIMARY KEY, UNIQUE, NOT NULL, DEFAULT)
CREATE TABLE dbo.Departments (
    DeptID          INT IDENTITY(1, 1)  NOT NULL,
    DeptCode        VARCHAR(10)         NOT NULL,
    DeptName        NVARCHAR(100)       NOT NULL,
    Building        NVARCHAR(50)        NOT NULL CONSTRAINT DF_Departments_Building DEFAULT N'Main Academic Block',
    CreatedAt       DATETIME2           NOT NULL CONSTRAINT DF_Departments_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Departments PRIMARY KEY CLUSTERED (DeptID),
    CONSTRAINT UQ_Departments_DeptCode UNIQUE (DeptCode),
    CONSTRAINT UQ_Departments_DeptName UNIQUE (DeptName)
);
GO

-- 4. Child Table: Students (FOREIGN KEY, CHECK, Computed Column)
CREATE TABLE dbo.Students (
    StudentID       INT IDENTITY(1001, 1)   NOT NULL,
    RollNumber      VARCHAR(20)             NOT NULL,
    FirstName       NVARCHAR(50)            NOT NULL,
    LastName        NVARCHAR(50)            NOT NULL,
    FullName        AS (CONCAT(FirstName, N' ', LastName)) PERSISTED,
    Email           VARCHAR(120)            NOT NULL,
    Gender          CHAR(1)                 NOT NULL,
    DateOfBirth     DATE                    NOT NULL,
    CGPA            DECIMAL(4, 2)           NOT NULL CONSTRAINT DF_Students_CGPA DEFAULT 0.00,
    DeptID          INT                     NOT NULL,
    IsActive        BIT                     NOT NULL CONSTRAINT DF_Students_IsActive DEFAULT 1,

    CONSTRAINT PK_Students PRIMARY KEY CLUSTERED (StudentID),
    CONSTRAINT UQ_Students_RollNumber UNIQUE (RollNumber),
    CONSTRAINT UQ_Students_Email UNIQUE (Email),
    CONSTRAINT CK_Students_Gender CHECK (Gender IN ('M', 'F', 'O')),
    CONSTRAINT CK_Students_CGPA CHECK (CGPA BETWEEN 0.00 AND 10.00),
    CONSTRAINT CK_Students_EmailFormat CHECK (Email LIKE '%_@__%.__%'),
    CONSTRAINT FK_Students_Departments FOREIGN KEY (DeptID)
        REFERENCES dbo.Departments (DeptID)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- 5. Table: Courses (CHECK on Credits & Fee)
CREATE TABLE dbo.Courses (
    CourseID        INT IDENTITY(101, 1)    NOT NULL,
    CourseCode      VARCHAR(15)             NOT NULL,
    CourseTitle     NVARCHAR(120)           NOT NULL,
    Credits         TINYINT                 NOT NULL,
    Semester        TINYINT                 NOT NULL,
    DeptID          INT                     NOT NULL,

    CONSTRAINT PK_Courses PRIMARY KEY CLUSTERED (CourseID),
    CONSTRAINT UQ_Courses_CourseCode UNIQUE (CourseCode),
    CONSTRAINT CK_Courses_Credits CHECK (Credits BETWEEN 1 AND 6),
    CONSTRAINT CK_Courses_Semester CHECK (Semester BETWEEN 1 AND 8),
    CONSTRAINT FK_Courses_Departments FOREIGN KEY (DeptID)
        REFERENCES dbo.Departments (DeptID)
);
GO

-- 6. Junction Table: Enrollments (Composite Unique Key + CASCADE Delete)
CREATE TABLE dbo.Enrollments (
    EnrollmentID    INT IDENTITY(1, 1)  NOT NULL,
    StudentID       INT                 NOT NULL,
    CourseID        INT                 NOT NULL,
    EnrollmentDate  DATE                NOT NULL CONSTRAINT DF_Enrollments_Date DEFAULT CAST(GETDATE() AS DATE),
    Grade           VARCHAR(2)          NULL,

    CONSTRAINT PK_Enrollments PRIMARY KEY CLUSTERED (EnrollmentID),
    CONSTRAINT UQ_Enrollments_StudentCourse UNIQUE (StudentID, CourseID),
    CONSTRAINT CK_Enrollments_Grade CHECK (Grade IN ('AA', 'AB', 'BB', 'BC', 'CC', 'CD', 'DD', 'F') OR Grade IS NULL),
    CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentID)
        REFERENCES dbo.Students (StudentID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Enrollments_Courses FOREIGN KEY (CourseID)
        REFERENCES dbo.Courses (CourseID)
        ON DELETE CASCADE
);
GO

-- 7. DDL Operations: ALTER TABLE (Add, Modify, Drop Column & Constraint)
ALTER TABLE dbo.Students
    ADD PhoneNumber VARCHAR(15) NULL;
GO

ALTER TABLE dbo.Students
    ALTER COLUMN PhoneNumber VARCHAR(20) NULL;
GO

ALTER TABLE dbo.Students
    ADD CONSTRAINT CK_Students_PhoneLength CHECK (PhoneNumber IS NULL OR LEN(PhoneNumber) >= 10);
GO

-- 8. Verify Schema Metadata
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
ORDER BY t.name, c.column_id;
GO
