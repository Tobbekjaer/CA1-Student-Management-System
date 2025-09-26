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
- **Generated SQL script**  
  `ef-approach/artifacts/V1__InitialSchema.sql`

---

## Commands Run
```bash
# 1) Create the migration (from your console project)
dotnet ef migrations add V1__InitialSchema

# 2) Generate an idempotent SQL script (0 -> V1)
dotnet ef migrations script 0 V1__InitialSchema --idempotent -o ef-approach/artifacts/V1__InitialSchema.sql

