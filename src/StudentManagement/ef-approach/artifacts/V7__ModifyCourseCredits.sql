BEGIN TRANSACTION;
DECLARE @var sysname;
SELECT @var = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Course]') AND [c].[name] = N'Credits');
IF @var IS NOT NULL EXEC(N'ALTER TABLE [Course] DROP CONSTRAINT [' + @var + '];');
ALTER TABLE [Course] ALTER COLUMN [Credits] decimal(5,2) NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250927134257_V7__ModifyCourseCredits', N'9.0.9');

COMMIT;
GO

