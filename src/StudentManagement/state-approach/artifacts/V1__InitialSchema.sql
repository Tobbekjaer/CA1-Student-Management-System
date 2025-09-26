-- Idempotent deployment script for V1
-- state-approach/artifacts/V1__InitialSchema.sql
SET XACT_ABORT ON;
BEGIN TRAN;

-- Ensure schema exists (usually dbo exists; safe-guard anyway)
IF SCHEMA_ID(N'dbo') IS NULL EXEC('CREATE SCHEMA dbo;');

-- STUDENT
IF OBJECT_ID(N'dbo.Student', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Student(
                            Id INT NOT NULL IDENTITY(1,1),
                            FirstName NVARCHAR(100) NOT NULL,
                            LastName NVARCHAR(100) NOT NULL,
                            Email NVARCHAR(255) NOT NULL,
                            EnrollmentDate DATETIME2 NOT NULL,
                            CONSTRAINT PK_Student PRIMARY KEY (Id)
);
END
ELSE
BEGIN
  IF COL_LENGTH('dbo.Student','Id') IS NULL
ALTER TABLE dbo.Student ADD Id INT NOT NULL IDENTITY(1,1);
IF COL_LENGTH('dbo.Student','FirstName') IS NULL
ALTER TABLE dbo.Student ADD FirstName NVARCHAR(100) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Student','LastName') IS NULL
ALTER TABLE dbo.Student ADD LastName NVARCHAR(100) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Student','Email') IS NULL
ALTER TABLE dbo.Student ADD Email NVARCHAR(255) NOT NULL DEFAULT N'';
IF COL_LENGTH('dbo.Student','EnrollmentDate') IS NULL
ALTER TABLE dbo.Student ADD EnrollmentDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_Student')
ALTER TABLE dbo.Student ADD CONSTRAINT PK_Student PRIMARY KEY (Id);
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'UX_Student_Email')
CREATE UNIQUE INDEX UX_Student_Email ON dbo.Student(Email);

-- COURSE
IF OBJECT_ID(N'dbo.Course', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Course(
                           Id INT NOT NULL IDENTITY(1,1),
                           Title NVARCHAR(200) NOT NULL,
                           Credits INT NOT NULL,
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

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_Course')
ALTER TABLE dbo.Course ADD CONSTRAINT PK_Course PRIMARY KEY (Id);
END

-- ENROLLMENT
IF OBJECT_ID(N'dbo.Enrollment', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Enrollment(
                               Id INT NOT NULL IDENTITY(1,1),
                               StudentId INT NOT NULL,
                               CourseId INT NOT NULL,
                               Grade NVARCHAR(10) NULL,
                               CONSTRAINT PK_Enrollment PRIMARY KEY (Id)
);
END
ELSE
BEGIN
  IF COL_LENGTH('dbo.Enrollment','Id') IS NULL
ALTER TABLE dbo.Enrollment ADD Id INT NOT NULL IDENTITY(1,1);
IF COL_LENGTH('dbo.Enrollment','StudentId') IS NULL
ALTER TABLE dbo.Enrollment ADD StudentId INT NOT NULL DEFAULT(0);
IF COL_LENGTH('dbo.Enrollment','CourseId') IS NULL
ALTER TABLE dbo.Enrollment ADD CourseId INT NOT NULL DEFAULT(0);
IF COL_LENGTH('dbo.Enrollment','Grade') IS NULL
ALTER TABLE dbo.Enrollment ADD Grade NVARCHAR(10) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_Enrollment')
ALTER TABLE dbo.Enrollment ADD CONSTRAINT PK_Enrollment PRIMARY KEY (Id);
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'UX_Enrollment_Student_Course')
CREATE UNIQUE INDEX UX_Enrollment_Student_Course ON dbo.Enrollment(StudentId, CourseId);

-- FKs (add if missing)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_Enrollment_Student')
ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (StudentId) REFERENCES dbo.Student(Id) ON DELETE CASCADE;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_Enrollment_Course')
ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (CourseId) REFERENCES dbo.Course(Id) ON DELETE CASCADE;

-- Optional: track that V1 was applied (handy in state-based flows)
IF OBJECT_ID(N'dbo.SchemaVersions', N'U') IS NULL
CREATE TABLE dbo.SchemaVersions(
                                   VersionLabel NVARCHAR(50) NOT NULL PRIMARY KEY,
                                   AppliedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

IF NOT EXISTS (SELECT 1 FROM dbo.SchemaVersions WHERE VersionLabel = 'V1')
  INSERT INTO dbo.SchemaVersions(VersionLabel) VALUES ('V1');

COMMIT TRAN;
