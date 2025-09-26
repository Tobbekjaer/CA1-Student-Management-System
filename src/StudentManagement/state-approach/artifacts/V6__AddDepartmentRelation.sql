-- Idempotent deployment script for V5 -> V6
-- state-approach/artifacts/V6__AddDepartmentRelation.sql
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Create Department table if missing
IF OBJECT_ID(N'dbo.Department', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Department (
                                Id INT NOT NULL IDENTITY(1,1),
                                Name NVARCHAR(200) NOT NULL,
                                Budget DECIMAL(18,2) NOT NULL,
                                StartDate DATETIME2 NOT NULL,
                                DepartmentHeadId INT NULL,
                                CONSTRAINT PK_Department PRIMARY KEY (Id)
);
END
ELSE
BEGIN
    -- Ensure columns exist (use temp defaults to satisfy NOT NULL, then drop)
    IF COL_LENGTH('dbo.Department', 'Name') IS NULL
BEGIN
ALTER TABLE dbo.Department ADD Name NVARCHAR(200) NOT NULL CONSTRAINT DF_Department_Name DEFAULT(N'');
ALTER TABLE dbo.Department DROP CONSTRAINT DF_Department_Name;
END;

    IF COL_LENGTH('dbo.Department', 'Budget') IS NULL
BEGIN
ALTER TABLE dbo.Department ADD Budget DECIMAL(18,2) NOT NULL CONSTRAINT DF_Department_Budget DEFAULT(0);
ALTER TABLE dbo.Department DROP CONSTRAINT DF_Department_Budget;
END;

    IF COL_LENGTH('dbo.Department', 'StartDate') IS NULL
BEGIN
ALTER TABLE dbo.Department ADD StartDate DATETIME2 NOT NULL CONSTRAINT DF_Department_StartDate DEFAULT(SYSDATETIME());
ALTER TABLE dbo.Department DROP CONSTRAINT DF_Department_StartDate;
END;

    IF COL_LENGTH('dbo.Department', 'DepartmentHeadId') IS NULL
BEGIN
ALTER TABLE dbo.Department ADD DepartmentHeadId INT NULL;
END;
END;

-- Ensure filtered unique index (only enforce when DepartmentHeadId IS NOT NULL)
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_Department_DepartmentHeadId_NotNull'
      AND object_id = OBJECT_ID(N'dbo.Department')
)
BEGIN
CREATE UNIQUE INDEX UX_Department_DepartmentHeadId_NotNull
    ON dbo.Department(DepartmentHeadId)
    WHERE DepartmentHeadId IS NOT NULL;
END;

-- Ensure FK DepartmentHeadId -> Instructor(Id) with ON DELETE SET NULL
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Department_Instructor_DepartmentHeadId'
      AND parent_object_id = OBJECT_ID(N'dbo.Department')
)
BEGIN
ALTER TABLE dbo.Department
    ADD CONSTRAINT FK_Department_Instructor_DepartmentHeadId
        FOREIGN KEY (DepartmentHeadId) REFERENCES dbo.Instructor(Id)
            ON DELETE SET NULL;
END;

COMMIT TRANSACTION;
