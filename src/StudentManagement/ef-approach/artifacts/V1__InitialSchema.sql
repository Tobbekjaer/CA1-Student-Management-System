IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE TABLE [Course] (
        [Id] int NOT NULL IDENTITY,
        [Title] nvarchar(200) NOT NULL,
        [Credits] int NOT NULL,
        CONSTRAINT [PK_Course] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE TABLE [Student] (
        [Id] int NOT NULL IDENTITY,
        [FirstName] nvarchar(100) NOT NULL,
        [LastName] nvarchar(100) NOT NULL,
        [Email] nvarchar(255) NOT NULL,
        [EnrollmentDate] datetime2 NOT NULL,
        CONSTRAINT [PK_Student] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE TABLE [Enrollment] (
        [Id] int NOT NULL IDENTITY,
        [CourseId] int NOT NULL,
        [StudentId] int NOT NULL,
        [Grade] nvarchar(10) NULL,
        CONSTRAINT [PK_Enrollment] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Enrollment_Course_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [Course] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_Enrollment_Student_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Student] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE INDEX [IX_Enrollment_CourseId] ON [Enrollment] ([CourseId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Enrollment_StudentId_CourseId] ON [Enrollment] ([StudentId], [CourseId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Student_Email] ON [Student] ([Email]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20250926110602_V1__InitialSchema'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20250926110602_V1__InitialSchema', N'9.0.9');
END;

COMMIT;
GO

