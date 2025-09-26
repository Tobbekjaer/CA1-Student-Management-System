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
  `src/StudentManagement.Console/Migrations/<timestamp>_V1__InitialSchema.cs`
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
The change reflects a realistic data requirement, as not all students have a middle name.  
The column is **nullable** to preserve data integrity and avoid enforcing a value.

---

## Schema Change
- **Student**
  - Added column: `MiddleName` (`nvarchar(100)`, nullable)

---

## Artifacts Produced
- **EF migration (C#)**  
  `src/StudentManagement.Console/Migrations/<timestamp>_V2__AddMiddleName.cs`
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