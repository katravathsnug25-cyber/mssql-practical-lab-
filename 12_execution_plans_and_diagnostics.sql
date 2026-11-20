USE SQLMasterLabDB;
GO

-- 1. IO & Execution Time Statistics (Check Logical Reads & CPU/Elapsed Time)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    s.RollNumber,
    s.FullName,
    d.DeptCode,
    s.CGPA
FROM dbo.Students s
INNER JOIN dbo.Departments d ON s.DeptID = d.DeptID
WHERE s.IsActive = 1
ORDER BY s.CGPA DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 2. Missing Index Recommendations DMV (Current Instance / Database)
SELECT TOP 10
    ROUND(migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans), 2) AS ImprovementMeasure,
    OBJECT_NAME(mid.object_id, mid.database_id) AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats migs
INNER JOIN sys.dm_db_missing_index_groups mig
    ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid
    ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID('SQLMasterLabDB')
ORDER BY ImprovementMeasure DESC;
GO

-- 3. Active Sessions, Running Requests & Wait Diagnostics
SELECT
    s.session_id,
    s.login_name,
    DB_NAME(r.database_id) AS DatabaseName,
    r.status AS RequestStatus,
    r.command,
    r.wait_type,
    r.wait_time,
    r.blocking_session_id,
    st.text AS QueryText
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r
    ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE s.is_user_process = 1
  AND s.session_id <> @@SPID
ORDER BY s.session_id;
GO

-- 4. Cached Query Plans & Execution Counts for SQLMasterLabDB
SELECT TOP 10
    qs.execution_count,
    ROUND(qs.total_logical_reads / NULLIF(qs.execution_count, 0), 2) AS AvgLogicalReads,
    ROUND(qs.total_elapsed_time / 1000.0 / NULLIF(qs.execution_count, 0), 2) AS AvgElapsedMs,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1
    ) AS StatementText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid = DB_ID('SQLMasterLabDB')
ORDER BY qs.total_logical_reads DESC;
GO
