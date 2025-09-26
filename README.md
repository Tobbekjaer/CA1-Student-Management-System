# CA1: Student Management System

This project implements a simple **Student Management** system while demonstrating two different database migration strategies:

- **Change-Based Migrations** using Entity Framework Core
- **State-Based Migrations** using manual idempotent SQL scripts

The assignment focuses on:
- Evolving the schema across multiple versions
- Demonstrating **feature branching**
- Tracking all migrations in **version-controlled artifacts**
- Arguing for **destructive vs. non-destructive** schema changes

---

## Migration Approach READMEs

Each approach is fully documented with:
- Version-by-version schema changes
- CLI commands used
- Artifacts produced
- Design decisions and trade-offs

| Approach        | README |
|----------------|--------|
| **Change-Based (EF Core)** | [ef-approach/README.md](https://github.com/Tobbekjaer/CA1-Student-Management-System/blob/main/src/StudentManagement/ef-approach/README.md) |
| **State-Based (Idempotent SQL)** | [state-approach/README.md](https://github.com/Tobbekjaer/CA1-Student-Management-System/blob/main/src/StudentManagement/state-approach/README.md) |
