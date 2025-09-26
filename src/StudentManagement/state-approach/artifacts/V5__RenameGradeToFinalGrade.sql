-- Idempotent deployment script for V4 to V5
-- state-approach/artifacts/V5__RenameGradeToFinalGrade.sql

SET XACT_ABORT ON;
BEGIN TRAN;

-- Ensure FinalGrade doesn't exist but Grade does -> rename
IF COL_LENGTH('dbo.Enrollment', 'FinalGrade') IS NULL
   AND COL_LENGTH('dbo.Enrollment', 'Grade') IS NOT NULL
BEGIN
EXEC sp_rename N'dbo.Enrollment.Grade', N'FinalGrade', 'COLUMN';
END

-- If neither column exists (unexpected), create FinalGrade to reach target
IF COL_LENGTH('dbo.Enrollment', 'FinalGrade') IS NULL
   AND COL_LENGTH('dbo.Enrollment', 'Grade') IS NULL
BEGIN
EXEC sp_executesql
        N'ALTER TABLE dbo.[Enrollment] ADD [FinalGrade] NVARCHAR(10) NULL;';
END

-- If both columns exist, coalesce data then drop old Grade column
IF COL_LENGTH('dbo.Enrollment', 'FinalGrade') IS NOT NULL
   AND COL_LENGTH('dbo.Enrollment', 'Grade') IS NOT NULL
BEGIN
    DECLARE @sql nvarchar(max);

    -- Move data over if FinalGrade is NULL and Grade has a value
    SET @sql = N'UPDATE E SET [FinalGrade] = COALESCE([FinalGrade], [Grade]) FROM dbo.[Enrollment] AS E;';
EXEC sp_executesql @sql;

    -- Drop the old column
    SET @sql = N'ALTER TABLE dbo.[Enrollment] DROP COLUMN [Grade];';
EXEC sp_executesql @sql;
END

-- 4) Ensure target type/nullable: NVARCHAR(10) NULL
--    Use dynamic SQL to avoid compile-time binding on missing column.
IF COL_LENGTH('dbo.Enrollment', 'FinalGrade') IS NOT NULL
BEGIN
EXEC sp_executesql
        N'ALTER TABLE dbo.[Enrollment] ALTER COLUMN [FinalGrade] NVARCHAR(10) NULL;';
END

COMMIT;
GO