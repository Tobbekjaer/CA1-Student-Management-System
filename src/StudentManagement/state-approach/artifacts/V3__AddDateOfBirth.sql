-- Idempotent deployment script for V2 to V3
-- state-approach/artifacts/V3__AddDateOfBirth.sql
IF COL_LENGTH('Student', 'DateOfBirth') IS NULL
BEGIN
ALTER TABLE Student ADD DateOfBirth datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';
END
