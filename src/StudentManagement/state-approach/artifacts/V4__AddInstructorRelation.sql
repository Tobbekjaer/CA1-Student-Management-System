-- Idempotent deployment script for V3 to V4
-- state-approach/artifacts/V4__AddInstructorRelation.sql
SET XACT_ABORT ON;
BEGIN TRAN;

-- Ensure schema exists (usually dbo exists; safe-guard anyway)
IF SCHEMA_ID(N'dbo') IS NULL EXEC('CREATE SCHEMA dbo;');

-- INSTRUCTOR TABLE
IF OBJECT_ID(N'dbo.Instructor', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Instructor(
                               Id INT NOT NULL IDENTITY(1,1),
                               FirstName NVARCHAR(100) NOT NULL,
                               LastName NVARCHAR(100) NOT NULL,
                               Email NVARCHAR(255) NOT NULL,
                               HireDate DATETIME2 NOT NULL,
                               CONSTRAINT PK_Instructor PRIMARY KEY (Id)
);
END
ELSE
BEGIN
    IF COL_LENGTH('dbo.Instructor','Id') IS NULL
ALTER TABLE dbo.Instructor ADD Id INT NOT NULL IDENTITY(1,1);
IF COL_LENGTH('dbo.Instructor','FirstName') IS NULL
ALTER TABLE dbo.Instructor ADD FirstName NVARCHAR(100) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Instructor','LastName') IS NULL
ALTER TABLE dbo.Instructor ADD LastName NVARCHAR(100) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Instructor','Email') IS NULL
ALTER TABLE dbo.Instructor ADD Email NVARCHAR(255) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Instructor','HireDate') IS NULL
ALTER TABLE dbo.Instructor ADD HireDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_Instructor')
ALTER TABLE dbo.Instructor ADD CONSTRAINT PK_Instructor PRIMARY KEY (Id);
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'UX_Instructor_Email')
CREATE UNIQUE INDEX UX_Instructor_Email ON dbo.Instructor(Email);

-- COURSE TABLE MODIFICATION
IF OBJECT_ID(N'dbo.Course', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Course(
                           Id INT NOT NULL IDENTITY(1,1),
                           Title NVARCHAR(200) NOT NULL,
                           Credits INT NOT NULL,
                           InstructorId INT NULL,
                           CONSTRAINT PK_Course PRIMARY KEY (Id)
);
END
ELSE
BEGIN
    IF COL_LENGTH('dbo.Course','Id') IS NULL
ALTER TABLE dbo.Course ADD Id INT NOT NULL IDENTITY(1,1);
IF COL_LENGTH('dbo.Course','Title') IS NULL
ALTER TABLE dbo.Course ADD Title NVARCHAR(200) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Course','Credits') IS NULL
ALTER TABLE dbo.Course ADD Credits INT NOT NULL DEFAULT(0);
IF COL_LENGTH('dbo.Course','InstructorId') IS NULL
ALTER TABLE dbo.Course ADD InstructorId INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_Course')
ALTER TABLE dbo.Course ADD CONSTRAINT PK_Course PRIMARY KEY (Id);
END

-- FOREIGN KEY
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_Course_Instructor')
ALTER TABLE dbo.Course
    ADD CONSTRAINT FK_Course_Instructor
        FOREIGN KEY (InstructorId) REFERENCES dbo.Instructor(Id);

COMMIT;
