-- Idempotent deployment script for V6 -> V7
-- state-approach/artifacts/V7__ModifyCourseRelation.sql

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Ensure dbo.Course table exists (idempotent)
IF NOT EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'dbo.Course')
      AND type = N'U'
)
BEGIN
CREATE TABLE dbo.Course (
                            Id INT NOT NULL IDENTITY(1,1),
                            Title NVARCHAR(200) NOT NULL,
                            Credits DECIMAL(5,2) NOT NULL,  -- V7 desired type
                            InstructorId INT NULL,
                            CONSTRAINT PK_Course PRIMARY KEY (Id)
);
END;

-- Ensure Credits column exists (idempotent)
IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE [object_id] = OBJECT_ID(N'dbo.Course')
      AND [name] = N'Credits'
)
BEGIN
ALTER TABLE dbo.Course
    ADD Credits DECIMAL(5,2) NOT NULL
    CONSTRAINT DF_Course_Credits DEFAULT (0.00);
END;

-- If Credits exists but is not DECIMAL(5,2) NOT NULL, convert it
;WITH ColInfo AS (
    SELECT
        t.name        AS TypeName,
        c.is_nullable AS IsNullable,
        c.max_length  AS MaxLength,
        c.precision   AS [Precision],
     c.scale       AS [Scale]
 FROM sys.columns c
     JOIN sys.types   t ON c.user_type_id = t.user_type_id
 WHERE c.[object_id] = OBJECT_ID(N'dbo.Course')
   AND c.[name] = N'Credits'
     )
SELECT * INTO #ColInfo FROM ColInfo;

-- Already at desired type?
IF NOT EXISTS (
    SELECT 1
    FROM #ColInfo
    WHERE TypeName = 'decimal'
      AND [Precision] = 5
      AND [Scale] = 2
      AND IsNullable = 0
)
BEGIN
    -- Drop a default constraint if one exists on Credits
    DECLARE @dfname SYSNAME;
SELECT @dfname = dc.name
FROM sys.default_constraints dc
         INNER JOIN sys.columns c
                    ON c.[object_id] = dc.parent_object_id
                        AND c.column_id   = dc.parent_column_id
WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Course')
  AND c.[name] = N'Credits';

IF @dfname IS NOT NULL
BEGIN
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'ALTER TABLE dbo.Course DROP CONSTRAINT ' + QUOTENAME(@dfname) + N';';
EXEC sys.sp_executesql @sql;
END;

    -- Handle NULLs defensively before enforcing NOT NULL
    IF EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE [object_id] = OBJECT_ID(N'dbo.Course')
          AND [name] = N'Credits'
          AND is_nullable = 1
    )
BEGIN
UPDATE dbo.Course
SET Credits = 0.00
WHERE Credits IS NULL;
END;

    -- ALTER COLUMN to DECIMAL(5,2) NOT NULL
ALTER TABLE dbo.Course
ALTER COLUMN Credits DECIMAL(5,2) NOT NULL;
END;

-- More compatible drop for older SQL Server versions
IF OBJECT_ID('tempdb..#ColInfo') IS NOT NULL
DROP TABLE #ColInfo;

COMMIT TRANSACTION;
GO
