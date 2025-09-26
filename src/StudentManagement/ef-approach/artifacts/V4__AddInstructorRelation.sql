BEGIN TRANSACTION;
ALTER TABLE [Course] ADD [InstructorId] int NULL;

CREATE TABLE [Instructor] (
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(100) NOT NULL,
    [LastName] nvarchar(100) NOT NULL,
    [Email] nvarchar(255) NOT NULL,
    [HireDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Instructor] PRIMARY KEY ([Id])
);

CREATE INDEX [IX_Course_InstructorId] ON [Course] ([InstructorId]);

CREATE UNIQUE INDEX [IX_Instructor_Email] ON [Instructor] ([Email]);

ALTER TABLE [Course] ADD CONSTRAINT [FK_Course_Instructor_InstructorId] FOREIGN KEY ([InstructorId]) REFERENCES [Instructor] ([Id]) ON DELETE NO ACTION;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250926170805_V4__AddInstructorRelation', N'9.0.9');

COMMIT;
GO

