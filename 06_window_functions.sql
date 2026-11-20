USE SQLMasterLabDB;
GO

-- 1. Ranking Functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE
SELECT
    RollNumber,
    FullName,
    DeptID,
    CGPA,
    ROW_NUMBER() OVER (ORDER BY CGPA DESC) AS OverallRowNum,
    RANK() OVER (ORDER BY CGPA DESC) AS CgpaRank,
    DENSE_RANK() OVER (ORDER BY CGPA DESC) AS CgpaDenseRank,
    NTILE(3) OVER (ORDER BY CGPA DESC) AS PerformanceTier
FROM dbo.Students;
GO

-- 2. PARTITION BY (Department-wise Top Rankers)
SELECT
    d.DeptCode,
    s.RollNumber,
    s.FullName,
    s.CGPA,
    DENSE_RANK() OVER (PARTITION BY s.DeptID ORDER BY s.CGPA DESC) AS DeptRank
FROM dbo.Students s
INNER JOIN dbo.Departments d ON s.DeptID = d.DeptID
ORDER BY d.DeptCode, DeptRank;
GO

-- 3. Value Functions: LAG, LEAD, FIRST_VALUE, LAST_VALUE
SELECT
    RollNumber,
    FullName,
    CGPA,
    LAG(CGPA, 1, NULL) OVER (ORDER BY CGPA DESC) AS HigherNeighborCGPA,
    LEAD(CGPA, 1, NULL) OVER (ORDER BY CGPA DESC) AS LowerNeighborCGPA,
    FIRST_VALUE(FullName) OVER (ORDER BY CGPA DESC) AS BatchTopper,
    LAST_VALUE(FullName) OVER (
        ORDER BY CGPA DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LowestScorer
FROM dbo.Students;
GO

-- 4. Aggregate Window Functions (Running Total & Moving Average)
SELECT
    StudentID,
    RollNumber,
    FullName,
    CGPA,
    CAST(AVG(CGPA) OVER () AS DECIMAL(4, 2)) AS BatchAvgCGPA,
    CAST(CGPA - AVG(CGPA) OVER () AS DECIMAL(4, 2)) AS DiffFromAvg,
    SUM(CGPA) OVER (
        ORDER BY StudentID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningCGPASum
FROM dbo.Students
ORDER BY StudentID;
GO
