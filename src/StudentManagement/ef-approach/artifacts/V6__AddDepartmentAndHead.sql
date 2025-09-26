BEGIN TRANSACTION;
CREATE TABLE [Department] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(200) NOT NULL,
    [Budget] decimal(18,2) NOT NULL,
    [StartDate] datetime2 NOT NULL,
    [DepartmentHeadId] int NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Department_Instructor_DepartmentHeadId] FOREIGN KEY ([DepartmentHeadId]) REFERENCES [Instructor] ([Id]) ON DELETE SET NULL
);

CREATE UNIQUE INDEX [IX_Department_DepartmentHeadId] ON [Department] ([DepartmentHeadId]) WHERE [DepartmentHeadId] IS NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250926205425_V6__AddDepartmentAndHead', N'9.0.9');

COMMIT;
GO

