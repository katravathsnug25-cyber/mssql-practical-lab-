USE SQLMasterLabDB;
GO

DELETE FROM dbo.Enrollments;
DELETE FROM dbo.Courses;
DELETE FROM dbo.Students;
DELETE FROM dbo.Departments;
GO

DBCC CHECKIDENT ('dbo.Departments', RESEED, 0);
DBCC CHECKIDENT ('dbo.Students', RESEED, 1000);
DBCC CHECKIDENT ('dbo.Courses', RESEED, 100);
DBCC CHECKIDENT ('dbo.Enrollments', RESEED, 0);
GO

INSERT INTO dbo.Departments (DeptCode, DeptName, Building)
OUTPUT inserted.DeptID, inserted.DeptCode, inserted.DeptName
VALUES
    ('EE', N'Electrical Engineering', N'N-Block'),
    ('CSE', N'Computer Science and Engineering', N'New Academic Complex'),
    ('ME', N'Mechanical Engineering', N'Workshop Block'),
    ('CE', N'Civil Engineering', DEFAULT);
GO

INSERT INTO dbo.Students (RollNumber, FirstName, LastName, Email, Gender, DateOfBirth, CGPA, DeptID, IsActive, PhoneNumber)
VALUES
    ('25EE101', N'Santosh', N'Naik', 'santosh.ee25@nits.ac.in', 'M', '2006-07-14', 8.85, 1, 1, '9876543210'),
    ('25EE102', N'Ananya', N'Sharma', 'ananya.ee25@nits.ac.in', 'F', '2006-03-22', 9.20, 1, 1, '9876543211'),
    ('25CS101', N'Rohan', N'Verma', 'rohan.cs25@nits.ac.in', 'M', '2005-11-05', 9.45, 2, 1, '9876543212'),
    ('25CS102', N'Priya', N'Nair', 'priya.cs25@nits.ac.in', 'F', '2006-01-19', 8.40, 2, 1, NULL),
    ('25ME101', N'Karthik', N'Reddy', 'karthik.me25@nits.ac.in', 'M', '2005-09-30', 7.60, 3, 1, '9876543214'),
    ('25CE101', N'Meera', N'Iyer', 'meera.ce25@nits.ac.in', 'F', '2006-05-12', 6.95, 4, 0, '9876543215');
GO

INSERT INTO dbo.Courses (CourseCode, CourseTitle, Credits, Semester, DeptID)
VALUES
    ('EE201', N'Analog and Digital Electronics', 4, 3, 1),
    ('EE202', N'Power Systems Fundamentals', 4, 3, 1),
    ('CS201', N'Data Structures and Algorithms', 4, 3, 2),
    ('CS202', N'Database Management Systems', 3, 4, 2),
    ('ME201', N'Thermodynamics', 4, 3, 3),
    ('CE201', N'Structural Analysis', 3, 3, 4);
GO

INSERT INTO dbo.Enrollments (StudentID, CourseID, EnrollmentDate, Grade)
VALUES
    (1001, 101, '2026-08-01', 'AA'),
    (1001, 102, '2026-08-01', 'AB'),
    (1002, 101, '2026-08-02', 'AA'),
    (1003, 103, '2026-08-03', 'AA'),
    (1003, 104, '2026-08-03', NULL),
    (1004, 103, '2026-08-04', 'BB'),
    (1005, 105, '2026-08-05', NULL),
    (1006, 106, '2026-08-06', 'CC');
GO

SELECT StudentID, RollNumber, FullName, CGPA, IsActive
FROM dbo.Students
WHERE CGPA >= 8.00 AND IsActive = 1
ORDER BY CGPA DESC;
GO

SELECT RollNumber, FullName, DeptID FROM dbo.Students WHERE DeptID IN (1, 2);
GO

SELECT CourseCode, CourseTitle, Credits FROM dbo.Courses WHERE Credits BETWEEN 3 AND 4;
GO

SELECT StudentID, FullName, Email FROM dbo.Students WHERE Email LIKE '%.ee25@%';
GO

SELECT EnrollmentID, StudentID, CourseID, Grade FROM dbo.Enrollments WHERE Grade IS NULL;
GO

SELECT DISTINCT DeptID FROM dbo.Students;
GO

SELECT TOP (3) RollNumber, FullName, CGPA FROM dbo.Students ORDER BY CGPA DESC;
GO

SELECT StudentID, RollNumber, FullName, CGPA
FROM dbo.Students
ORDER BY StudentID
OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;
GO

UPDATE dbo.Students
SET CGPA = 9.00, PhoneNumber = '9876543213'
OUTPUT inserted.StudentID, inserted.FullName, deleted.CGPA AS OldCGPA, inserted.CGPA AS NewCGPA
WHERE RollNumber = '25CS102';
GO

DELETE FROM dbo.Enrollments
OUTPUT deleted.EnrollmentID, deleted.StudentID, deleted.CourseID
WHERE Grade IS NULL AND EnrollmentID = 7;
GO
