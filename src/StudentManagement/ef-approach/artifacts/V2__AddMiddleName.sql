BEGIN TRANSACTION;
ALTER TABLE [Student] ADD [MiddleName] nvarchar(100) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250926150609_V2__AddMiddleName', N'9.0.9');

COMMIT;
GO

