USE SQLMasterLabDB;
GO

-- 1. INNER JOIN (Students with their Department details)
SELECT
    s.StudentID,
    s.RollNumber,
    s.FullName,
    d.DeptCode,
    d.DeptName,
    s.CGPA
FROM dbo.Students s
INNER JOIN dbo.Departments d ON s.DeptID = d.DeptID
ORDER BY s.StudentID;
GO

-- 2. Multi-Table INNER JOIN (Students -> Enrollments -> Courses -> Departments)
SELECT
    s.RollNumber,
    s.FullName,
    c.CourseCode,
    c.CourseTitle,
    d.DeptCode AS CourseDept,
    ISNULL(e.Grade, 'Pending') AS Grade
FROM dbo.Students s
INNER JOIN dbo.Enrollments e ON s.StudentID = e.StudentID
INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
INNER JOIN dbo.Departments d ON c.DeptID = d.DeptID
ORDER BY s.RollNumber, c.CourseCode;
GO

-- 3. LEFT JOIN (Find Students with NO Enrollments)
SELECT
    s.StudentID,
    s.RollNumber,
    s.FullName,
    e.EnrollmentID
FROM dbo.Students s
LEFT JOIN dbo.Enrollments e ON s.StudentID = e.StudentID
WHERE e.EnrollmentID IS NULL;
GO

-- 4. RIGHT JOIN & FULL OUTER JOIN
SELECT
    s.FullName,
    c.CourseCode,
    e.Grade
FROM dbo.Enrollments e
RIGHT JOIN dbo.Courses c ON e.CourseID = c.CourseID
LEFT JOIN dbo.Students s ON e.StudentID = s.StudentID;
GO

-- 5. SELF JOIN (Students in the SAME Department)
SELECT
    s1.FullName AS Student1,
    s2.FullName AS Student2,
    d.DeptCode
FROM dbo.Students s1
INNER JOIN dbo.Students s2
    ON s1.DeptID = s2.DeptID
   AND s1.StudentID < s2.StudentID
INNER JOIN dbo.Departments d ON s1.DeptID = d.DeptID;
GO

-- 6. CROSS JOIN (All Student-Department Combinations Matrix)
SELECT
    s.RollNumber,
    d.DeptCode
FROM dbo.Students s
CROSS JOIN dbo.Departments d
WHERE s.StudentID <= 1002;
GO

-- 7. SET OPERATORS (UNION, UNION ALL, INTERSECT, EXCEPT)
-- UNION (Distinct list of EE & CSE students)
SELECT RollNumber, FullName FROM dbo.Students WHERE DeptID = 1
UNION
SELECT RollNumber, FullName FROM dbo.Students WHERE DeptID = 2;
GO

-- INTERSECT (Students who are BOTH Active AND have CGPA >= 9.0)
SELECT StudentID, FullName FROM dbo.Students WHERE IsActive = 1
INTERSECT
SELECT StudentID, FullName FROM dbo.Students WHERE CGPA >= 9.00;
GO

-- EXCEPT (Active Students who do NOT have CGPA >= 9.0)
SELECT StudentID, FullName FROM dbo.Students WHERE IsActive = 1
EXCEPT
SELECT StudentID, FullName FROM dbo.Students WHERE CGPA >= 9.00;
GO
