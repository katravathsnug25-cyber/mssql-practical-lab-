USE SQLMasterLabDB;
GO

-- 1. Scalar Subquery (Students scoring above overall average CGPA)
SELECT
    RollNumber,
    FullName,
    CGPA,
    (SELECT CAST(AVG(CGPA) AS DECIMAL(4, 2)) FROM dbo.Students) AS OverallAvgCGPA
FROM dbo.Students
WHERE CGPA > (SELECT AVG(CGPA) FROM dbo.Students)
ORDER BY CGPA DESC;
GO

-- 2. Multi-Row Subquery with IN & ALL / ANY
SELECT RollNumber, FullName, CGPA
FROM dbo.Students
WHERE DeptID IN (
    SELECT DeptID
    FROM dbo.Departments
    WHERE DeptCode IN ('EE', 'CSE')
);
GO

-- Students with CGPA greater than ALL Mechanical students
SELECT RollNumber, FullName, CGPA
FROM dbo.Students
WHERE CGPA > ALL (
    SELECT CGPA
    FROM dbo.Students
    WHERE DeptID = 3
);
GO

-- 3. Correlated Subquery (Students scoring above their OWN Department's average)
SELECT
    s1.RollNumber,
    s1.FullName,
    s1.DeptID,
    s1.CGPA
FROM dbo.Students s1
WHERE s1.CGPA >= (
    SELECT AVG(s2.CGPA)
    FROM dbo.Students s2
    WHERE s2.DeptID = s1.DeptID
);
GO

-- 4. EXISTS & NOT EXISTS (Departments that have at least one active student)
SELECT d.DeptID, d.DeptCode, d.DeptName
FROM dbo.Departments d
WHERE EXISTS (
    SELECT 1
    FROM dbo.Students s
    WHERE s.DeptID = d.DeptID
      AND s.IsActive = 1
);
GO

-- 5. Common Table Expression (CTE) — Department Summary & Top Performers
WITH DeptStats AS (
    SELECT
        DeptID,
        COUNT(*) AS TotalStudents,
        CAST(AVG(CGPA) AS DECIMAL(4, 2)) AS AvgCGPA
    FROM dbo.Students
    GROUP BY DeptID
)
SELECT
    d.DeptCode,
    d.DeptName,
    ds.TotalStudents,
    ds.AvgCGPA
FROM DeptStats ds
INNER JOIN dbo.Departments d ON ds.DeptID = d.DeptID
ORDER BY ds.AvgCGPA DESC;
GO

-- 6. Recursive CTE (Generate Semester & Week Calendar 1 to 8)
WITH WeekSeries AS (
    SELECT 1 AS WeekNum, CAST('2026-08-03' AS DATE) AS WeekStartDate
    UNION ALL
    SELECT WeekNum + 1, DATEADD(WEEK, 1, WeekStartDate)
    FROM WeekSeries
    WHERE WeekNum < 8
)
SELECT
    WeekNum,
    WeekStartDate,
    DATENAME(MONTH, WeekStartDate) AS MonthName
FROM WeekSeries;
GO
