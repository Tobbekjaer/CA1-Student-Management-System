BEGIN TRANSACTION;
EXEC sp_rename N'[Enrollment].[Grade]', N'FinalGrade', 'COLUMN';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250926195627_V5__RenameGradeToFinalGrade', N'9.0.9');

COMMIT;
GO

