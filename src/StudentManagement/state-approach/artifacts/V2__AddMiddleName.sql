-- Idempotent deployment script for V1 to V2
-- state-approach/artifacts/V2__AddMiddleName.sql
IF COL_LENGTH('Student', 'MiddleName') IS NULL
BEGIN
ALTER TABLE Student ADD MiddleName NVARCHAR(100) NULL;
END
