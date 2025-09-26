BEGIN TRANSACTION;
ALTER TABLE [Student] ADD [DateOfBirth] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250926160628_V3__AddDateOfBirth', N'9.0.9');

COMMIT;
GO