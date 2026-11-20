USE SQLMasterLabDB;
GO

-- 1. Inspect Existing Indexes on Students & Enrollments
SELECT
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.schema_id = SCHEMA_ID('dbo')
  AND i.name IS NOT NULL
ORDER BY t.name, i.index_id;
GO

-- 2. Create Non-Clustered Index with INCLUDE Columns (Covering Index)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Students_DeptID_CGPA' AND object_id = OBJECT_ID('dbo.Students'))
    DROP INDEX IX_Students_DeptID_CGPA ON dbo.Students;
GO

CREATE NONCLUSTERED INDEX IX_Students_DeptID_CGPA
ON dbo.Students (DeptID, CGPA DESC)
INCLUDE (RollNumber, FullName, IsActive);
GO

-- 3. Filtered Index (Only Active Students with CGPA >= 8.0)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Students_ActiveTopCGPA' AND object_id = OBJECT_ID('dbo.Students'))
    DROP INDEX IX_Students_ActiveTopCGPA ON dbo.Students;
GO

CREATE NONCLUSTERED INDEX IX_Students_ActiveTopCGPA
ON dbo.Students (CGPA DESC)
INCLUDE (RollNumber, FullName, DeptID)
WHERE IsActive = 1 AND CGPA >= 8.00;
GO

-- 4. Test Query Using Non-Clustered / Filtered Index
SELECT RollNumber, FullName, DeptID, CGPA
FROM dbo.Students
WHERE IsActive = 1 AND CGPA >= 8.00
ORDER BY CGPA DESC;
GO

-- 5. Index Usage Stats & Fragmentation Check
SELECT
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i
    ON s.object_id = i.object_id
   AND s.index_id = i.index_id
WHERE s.database_id = DB_ID('SQLMasterLabDB')
  AND OBJECT_NAME(s.object_id) = 'Students';
GO

SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ROUND(ips.avg_fragmentation_in_percent, 2) AS AvgFragmentationPct,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID('SQLMasterLabDB'), OBJECT_ID('dbo.Students'), NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i
    ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id;
GO

-- 6. Rebuild & Reorganize Example + Update Statistics
ALTER INDEX IX_Students_DeptID_CGPA ON dbo.Students REORGANIZE;
ALTER INDEX IX_Students_ActiveTopCGPA ON dbo.Students REBUILD;
UPDATE STATISTICS dbo.Students;
GO
