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