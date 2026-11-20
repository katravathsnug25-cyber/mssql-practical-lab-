# SQL Server Practice Lab (`SQLMasterLabDB`)

Hands-on Microsoft SQL Server practice lab built and executed in VS Code using the MSSQL extension.

## Lab Modules

| # | File | Topics Covered |
|---|------|----------------|
| 01 | `01_database_and_tables.sql` | Database creation, data types, constraints (`PK`, `FK`, `UNIQUE`, `CHECK`, `DEFAULT`, `NOT NULL`, `IDENTITY`), and DDL (`ALTER`, `TRUNCATE`, `DROP`) |
| 02 | `02_crud_and_filtering.sql` | `INSERT` with `OUTPUT`, `SELECT`, `WHERE`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`, `DISTINCT`, `TOP`, `OFFSET-FETCH`, `UPDATE`, and `DELETE` |
| 03 | `03_aggregations_and_grouping.sql` | `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`, `GROUP BY`, `HAVING`, `ROLLUP`, and conditional aggregation |
| 04 | `04_joins_and_set_ops.sql` | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `SELF JOIN`, `CROSS JOIN`, `UNION`, `INTERSECT`, and `EXCEPT` |
| 05 | `05_subqueries_and_ctes.sql` | Scalar, multi-row, and correlated subqueries, `EXISTS`, CTEs, and recursive CTEs |
| 06 | `06_window_functions.sql` | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `PARTITION BY`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, and running totals |
| 07 | `07_views_procs_functions_triggers.sql` | Views, scalar functions, stored procedures, audit tables, and DML triggers |
| 08 | `08_transactions_and_error_handling.sql` | Explicit transactions, `COMMIT`, `ROLLBACK`, `SAVE TRANSACTION`, `TRY...CATCH`, `XACT_ABORT`, and `THROW` |
| 09 | `09_indexes_and_performance.sql` | Non-clustered covering indexes, filtered indexes, index usage/fragmentation DMVs, `REORGANIZE`, `REBUILD`, and updating statistics |

## How to Run
1. Connect to your SQL Server instance (`localhost`) in VS Code via the MSSQL extension.
2. Execute `01_database_and_tables.sql` first to create and initialize `SQLMasterLabDB`.
3. Run scripts `02` through `09` in sequence.
