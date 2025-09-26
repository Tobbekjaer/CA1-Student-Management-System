# EF (Change-based) — V1 Initial Schema

## Overview
I initialized the **Student Management** database schema using **Entity Framework Core** change-based migrations.  
This step creates the baseline (V1) with three tables and their relationships + an SQL artifact.

---

## Entities & Constraints
- **Student**: `Id`, `FirstName`, `LastName`, `Email`, `EnrollmentDate`
- **Course**: `Id`, `Title`, `Credits`
- **Enrollment**: `Id`, `StudentId → Student.Id`, `CourseId → Course.Id`, `Grade`

**Constraints**
- Primary keys on all tables
- Foreign keys from `Enrollment.StudentId` → `Student.Id` and `Enrollment.CourseId` → `Course.Id`
- One `Student` can have many `Enrollments`(1 → 0..*)
- One `Course` can have many `Enrollments`(1 → 0..*)

**Cascade Delete**
- If a `Student` row is deleted, all `Enrollment` rows referencing that student are automatically deleted by the database.
- If a `Course` row is deleted, all `Enrollment` rows referencing that course are automatically deleted.

---

## Artifacts Produced
- **EF migration (C#)**  
  `src/StudentManagement/Migrations/<timestamp>_V1__InitialSchema.cs`
- **Generated SQL script (idempotent)**  
  `ef-approach/artifacts/V1__InitialSchema.sql`

*“Idempotent”* = safe to run multiple times; if objects already exist correctly, it does nothing.

---

## Commands Run
```bash
# 1) Create the migration (from your console project)
dotnet ef migrations add V1__InitialSchema

# 2) Generate an idempotent SQL script (0 -> V1)
dotnet ef migrations script 0 V1__InitialSchema --idempotent -o ef-approach/artifacts/V1__InitialSchema.sql
```

---

# EF (Change-based) — V2 Add MiddleName to Student

## Overview
This migration introduces a new column `MiddleName` to the `Student` table.  
The column is **nullable** to preserve data integrity and avoid enforcing a value.

---

## Schema Change
- **Student**
  - Added column: `MiddleName` (`nvarchar(100)`, nullable)

---

## Artifacts Produced
- **EF migration (C#)**  
  `src/StudentManagement/Migrations/<timestamp>_V2__AddMiddleName.cs`
- **Generated SQL script (V1 → V2)**  
  `ef-approach/artifacts/V2__AddMiddleName.sql`

---

## Commands Run
```bash
# 1) Create migration after updating model & Fluent API
dotnet ef migrations add V2__AddMiddleName

# 2) Generate SQL script for V1 -> V2 only
dotnet ef migrations script V1__InitialSchema V2__AddMiddleName -o ef-approach/artifacts/V2__AddMiddleName.sql
```

## Reasoning: Non-Destructive

- The column is added as **nullable**, so existing records can be added with no required backfill.
- This approach ensures a safe schema evolution without affecting application behavior or requiring downtime.

---

# EF (Change-based) — V3 Add DateOfBirth to Student

## Overview
This migration introduces a new column `DateOfBirth` to the `Student` table.  
The column is **not nullable** which requires a backfill to preserve data integrity.

---

## Schema Change
- **Student**
    - Added column: `DateOfBirth` (`datetime2`, not null)

---

## Artifacts Produced
- **EF migration (C#)**  
  `src/StudentManagement/Migrations/<timestamp>_V3__AddDateOfBirth.cs`
- **Generated SQL script (V2 → V3)**  
  `ef-approach/artifacts/V3__AddDateOfBirth.sql`

---

## Commands Run
```bash
# 1) Create migration after updating model & Fluent API
dotnet ef migrations add V3__AddDateOfBirth 

# 2) Generate SQL script for V2 -> V3 only
dotnet ef migrations script V2__AddMiddleName V3__AddDateOfBirth -o ef-approach/artifacts/V3__AddDateOfBirth.sql
 ```

## Reasoning: Non-Destructive (via default value)

- Adding a `NOT NULL` column is typically destructive as it would break existing rows.
- However, this migration uses a **default value** (`0001-01-01`) to safely backfill existing rows.
- EF applies the column with `NOT NULL` + `DEFAULT`, making the change **non-destructive** at runtime.
- No application downtime is needed, and all existing records remain valid.

---

# EF (Change-based) — V4 Add Instructor Relation

## Overview
This migration introduces a new `Instructor` entity and connects it to the existing `Course` entity via a foreign key (`InstructorId`).  
The relationship is defined as optional (nullable FK) and uses **`DeleteBehavior.Restrict`** to prevent accidental data loss.

---

## Schema Changes

- **Course**
    - Added column: `InstructorId` (`int`, **nullable**)
    - Created foreign key: `InstructorId → Instructor.Id`
        - On delete: `Restrict` (cannot delete an instructor if referenced)

- **Instructor**
    - `Id` (PK, int, identity)
    - `FirstName` (`nvarchar(100)`, required)
    - `LastName` (`nvarchar(100)`, required)
    - `Email` (`nvarchar(255)`, required, **unique**)
    - `HireDate` (`datetime2`, required)

---

## Artifacts Produced
- **EF migration (C#)**  
  `src/StudentManagement/Migrations/<timestamp>_V4__AddInstructorRelation.cs`
- **Generated SQL script (V3 → V4)**  
  `ef-approach/artifacts/V4__AddInstructorRelation.sql`

---

## Commands Run
```bash
# 1) Create migration after adding Instructor model and updating Fluent API
dotnet ef migrations add V4__AddInstructorRelation

# 2) Generate SQL script for V3 -> V4 only
dotnet ef migrations script V3__AddDateOfBirth V4__AddInstructorRelation -o ef-approach/artifacts/V4__AddInstructorRelation.sql
```
## Reasoning: Non-Destructive

- `Instructor` is a **new table** — no existing data is impacted.
- `InstructorId` is added as a **nullable column** in `Course`, so existing course records remain valid.
- Foreign key uses **`ON DELETE RESTRICT`** to protect against accidental cascade deletion of courses.
- All constraints and indexes are added **incrementally** in a safe, migration-friendly way.

---

## Verification

Ran the generated SQL against a local database and confirmed:

- `Instructor` table created with all fields and unique `Email`
- `InstructorId` column added to `Course`
- Foreign key constraint `FK_Course_Instructor_InstructorId` exists and enforces referential integrity

You can now:
- Insert instructors
- Assign instructors to courses via `InstructorId`
- Query course-instructor relations via navigation properties

---

