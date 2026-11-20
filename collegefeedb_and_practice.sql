USE master;
GO

-- 1. CollegeFeeDB backup (.bak) tiyadam
BACKUP DATABASE CollegeFeeDB
TO DISK = N'/var/opt/mssql/data/CollegeFeeDB_backup.bak'
WITH FORMAT, INIT, NAME = N'CollegeFeeDB Full Backup';
GO

-- 2. Lock timeout & Isolation level demo
USE CollegeFeeDB;
GO

SET LOCK_TIMEOUT 3000; -- Lock unte 3 seconds (3000ms) matrame wait chesthundi
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT
    @@LOCK_TIMEOUT AS LockTimeoutMs,
    DB_NAME() AS CurrentDatabase,
    @@VERSION AS SqlServerVersion;
GO
