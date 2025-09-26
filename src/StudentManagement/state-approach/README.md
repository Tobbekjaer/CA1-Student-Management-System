# State-based — V1 Initial Schema

## Overview
I defined the **Student Management** database schema using a **state-based migration** approach.  
This version (V1) introduces three core tables and their relationships using a full schema definition and an idempotent deployment script.

*"State-based"* implies that you first define the **desired end state** of the database for each version. (V1, V2, ...) as a complete schema.
You then ship a **deployment script** for that version which, when run on any database (empty or partially configured), converges it to that desired state.

---

## Entities & Constraints
- **Student**: `Id`, `FirstName`, `LastName`, `Email`, `EnrollmentDate`
- **Course**: `Id`, `Title`, `Credits`
- **Enrollment**: `Id`, `StudentId → Student.Id`, `CourseId → Course.Id`, `Grade`

**Constraints**
- Primary keys on all tables
- Foreign keys from `Enrollment.StudentId` → `Student.Id` and `Enrollment.CourseId` → `Course.Id`
- One `Student` can have many `Enrollments` (1 → 0..*)
- One `Course` can have many `Enrollments` (1 → 0..*)

**Cascade Delete**
- Deleting a `Student` automatically deletes related `Enrollment` rows
- Deleting a `Course` automatically deletes related `Enrollment` rows

---

## Artifacts Produced
- **Desired schema (snapshot)**  
  `state-approach/state/v1/schema.sql`
- **Deployment script (idempotent)**  
  `state-approach/artifacts/V1__InitialSchema.sql`

*“Idempotent”* = safe to run multiple times; if objects already exist correctly, it does nothing.

---

## How to Apply
1. Open `V1__InitialSchema.sql` in Azure Data Studio (or any SQL tool).
2. Execute the script against your database.
3. Run the script again to confirm **idempotency** — it will not cause errors or duplicates.

---

## Notes on Implementation

This script is written to be **idempotent** — meaning it can safely be run multiple times without causing errors or duplicating objects.

To achieve this, it uses the following techniques:

- **Guards for tables and columns**
    - `IF OBJECT_ID('dbo.Student', 'U') IS NULL` — checks if the `Student` table exists before creating it
    - `IF COL_LENGTH('dbo.Student', 'Email') IS NULL` — checks if a column exists before adding it

- **Guards for constraints and indexes**
    - Checks system views like `sys.foreign_keys`, `sys.indexes`, and `sys.key_constraints` to see if a constraint or index with the same name already exists

- **Deterministic naming**
    - All constraints, indexes, and keys are named explicitly (e.g., `PK_Student`, `FK_Enrollment_Course`) so they can be reliably checked and skipped if already applied

- **Transactional safety**
    - The entire script is wrapped in a `BEGIN TRAN ... COMMIT` block
    - `SET XACT_ABORT ON` ensures that if any error occurs, the whole transaction is rolled back automatically

---

# State-based — V2 Add MiddleName to Student

## Overview
Added a nullable `MiddleName` column to the `Student` table using the state-based approach.

## Schema Change
- `Student`: added `MiddleName NVARCHAR(100) NULL`

## Artifacts Produced
- `state-approach/state/v2/schema.sql` – full schema at V2
- `state-approach/artifacts/V2__AddMiddleName.sql` – idempotent deployment script

## Deployment Logic
```sql
IF COL_LENGTH('Student', 'MiddleName') IS NULL
BEGIN
    ALTER TABLE Student ADD MiddleName NVARCHAR(100) NULL;
END
```

## Reasoning: Non-Destructive
- Non-destructive: existing data remains valid
- Nullable: no backfill needed 
- Idempotent: safe to re-run

---

# State-based — V3 Add DateOfBirth to Student

## Overview
Added a not nullable `DateOfBirth` column to the `Student` table using the state-based approach.

## Schema Change
- `Student`: added `DateOfBirth DATETIME2 NOT NULL`

## Artifacts Produced
- `state-approach/state/v3/schema.sql` – full schema at V3
- `state-approach/artifacts/V3__AddDateOfBirth.sql` – idempotent deployment script

## Deployment Logic
```sql
IF COL_LENGTH('Student', 'DateOfBirth') IS NULL
BEGIN
ALTER TABLE Student ADD DateOfBirth datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';
END
```

## Reasoning: Non-Destructive (via default value)

- Adding a `NOT NULL` column is typically destructive as it would break existing rows.
- However, this state-based migration uses a **default value** (`0001-01-01`) to safely backfill existing rows.
- This adds the column with `NOT NULL` + `DEFAULT`, making the change **non-destructive** at runtime.
- No application downtime is needed, and all existing records remain valid.

---

# State-based — V4 Add Instructor Relation

## Overview
Introduced a new `Instructor` table and added a nullable `InstructorId` column to the `Course` table. 
This allows associating a course with an instructor without breaking existing data.

## Schema Changes
- New table: `Instructor (Id, FirstName, LastName, Email, HireDate)`
- `Course`: added `InstructorId INT NULL` + foreign key to `Instructor(Id)`

## Artifacts Produced
- `state-approach/state/v4/schema.sql`
- `state-approach/artifacts/V4__AddInstructorRelation.sql`

## Deployment Logic (Essential)
```sql
IF OBJECT_ID('dbo.Instructor', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Instructor (...);
END

IF COL_LENGTH('dbo.Course', 'InstructorId') IS NULL
BEGIN
    ALTER TABLE dbo.Course ADD InstructorId INT NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Course_Instructor')
BEGIN
    ALTER TABLE dbo.Course
        ADD CONSTRAINT FK_Course_Instructor
        FOREIGN KEY (InstructorId) REFERENCES dbo.Instructor(Id);
END
```

## Reasoning

- This migration is non-destructive. The `Instructor` table is new and has no impact on existing data.  
- The `InstructorId` column in `Course` is added as **nullable**, so no backfill is needed, and no existing rows are affected.  
- By guarding each change, the script is idempotent and safe to run multiple times.

---


