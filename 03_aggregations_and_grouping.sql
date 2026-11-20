USE SQLMasterLabDB;
GO

-- 1. Basic Aggregate Functions (COUNT, COUNT(*), MIN, MAX, AVG, SUM)
SELECT
    COUNT(*) AS TotalStudents,
    COUNT(PhoneNumber) AS StudentsWithPhone,
    MIN(CGPA) AS LowestCGPA,
    MAX(CGPA) AS HighestCGPA,
    CAST(AVG(CGPA) AS DECIMAL(4, 2)) AS AvgCGPA,
    SUM(CAST(CGPA AS DECIMAL(6, 2))) AS SumCGPA
FROM dbo.Students;
GO

-- 2. GROUP BY & HAVING (Department-wise Student Stats)
SELECT
    DeptID,
    COUNT(*) AS StudentCount,
    CAST(AVG(CGPA) AS DECIMAL(4, 2)) AS DeptAvgCGPA,
    MAX(CGPA) AS TopCGPA
FROM dbo.Students
GROUP BY DeptID
HAVING COUNT(*) >= 1
   AND AVG(CGPA) >= 7.50
ORDER BY DeptAvgCGPA DESC;
GO

-- 3. GROUP BY with Multiple Columns (Department + Gender)
SELECT
    DeptID,
    Gender,
    COUNT(*) AS Headcount,
    CAST(AVG(CGPA) AS DECIMAL(4, 2)) AS AvgCGPA
FROM dbo.Students
GROUP BY DeptID, Gender
ORDER BY DeptID, Gender;
GO

-- 4. ROLLUP (Subtotals & Grand Total)
SELECT
    GROUPING_ID(DeptID, Gender) AS GroupingLevel,
    DeptID,
    Gender,
    COUNT(*) AS StudentCount,
    CAST(AVG(CGPA) AS DECIMAL(4, 2)) AS AvgCGPA
FROM dbo.Students
GROUP BY ROLLUP (DeptID, Gender)
ORDER BY DeptID, Gender;
GO

-- 5. Conditional Aggregation (CASE inside SUM)
SELECT
    c.DeptID,
    COUNT(*) AS TotalEnrollments,
    SUM(CASE WHEN e.Grade = 'AA' THEN 1 ELSE 0 END) AS AA_Count,
    SUM(CASE WHEN e.Grade IS NULL THEN 1 ELSE 0 END) AS PendingGrades
FROM dbo.Enrollments e
INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
GROUP BY c.DeptID
ORDER BY c.DeptID;
GO
