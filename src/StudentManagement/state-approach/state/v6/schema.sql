-- The desired state definition of V6 
-- state-approach/state/v6/schema.sql
CREATE TABLE dbo.Student (
                             Id INT NOT NULL IDENTITY(1,1),
                             FirstName NVARCHAR(100) NOT NULL,
                             MiddleName NVARCHAR(100),
                             LastName NVARCHAR(100) NOT NULL,
                             Email NVARCHAR(255) NOT NULL,
                             DateOfBirth DATETIME2 NOT NULL,
                             EnrollmentDate DATETIME2 NOT NULL,
                             CONSTRAINT PK_Student PRIMARY KEY (Id)
);

CREATE TABLE dbo.Course (
                            Id INT NOT NULL IDENTITY(1,1),
                            Title NVARCHAR(200) NOT NULL,
                            Credits INT NOT NULL,
                            InstructorId INT NULL,
                            CONSTRAINT PK_Course PRIMARY KEY (Id)
);

CREATE TABLE dbo.Enrollment (
                                Id INT NOT NULL IDENTITY(1,1),
                                StudentId INT NOT NULL,
                                CourseId INT NOT NULL,
                                FinalGrade NVARCHAR(10),
                                CONSTRAINT PK_Enrollment PRIMARY KEY (Id)
);

CREATE TABLE dbo.Instructor (
                                Id INT NOT NULL IDENTITY(1,1),
                                FirstName NVARCHAR(100) NOT NULL,
                                LastName NVARCHAR(100) NOT NULL,
                                Email NVARCHAR(255) NOT NULL,
                                HireDate DATETIME2 NOT NULL,
                                CONSTRAINT PK_Instructor PRIMARY KEY (Id)
);

-- New table
CREATE TABLE dbo.Department (
                                Id INT NOT NULL IDENTITY(1,1),
                                Name NVARCHAR(200) NOT NULL,
                                Budget DECIMAL(18,2) NOT NULL,
                                StartDate DATETIME2 NOT NULL,
                                DepartmentHeadId INT NULL,
                                CONSTRAINT PK_Department PRIMARY KEY (Id)
);


CREATE UNIQUE INDEX UX_Student_Email
    ON dbo.Student(Email);

CREATE UNIQUE INDEX UX_Enrollment_Student_Course
    ON dbo.Enrollment(StudentId, CourseId);

CREATE UNIQUE INDEX UX_Instructor_Email
    ON dbo.Instructor(Email);

CREATE UNIQUE INDEX UX_Department_DepartmentHeadId_NotNull -- An instructor can head at most one department
    ON dbo.Department(DepartmentHeadId)
    WHERE DepartmentHeadId IS NOT NULL;

ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (StudentId) REFERENCES dbo.Student(Id)
            ON DELETE CASCADE;

ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (CourseId) REFERENCES dbo.Course(Id)
            ON DELETE CASCADE;

ALTER TABLE dbo.Course
    ADD CONSTRAINT FK_Course_Instructor
        FOREIGN KEY (InstructorId) REFERENCES dbo.Instructor(Id)
            ON DELETE RESTRICT;

-- Department head must be an Instructor; on delete, set null
ALTER TABLE dbo.Department
    ADD CONSTRAINT FK_Department_Instructor_DepartmentHeadId
        FOREIGN KEY (DepartmentHeadId) REFERENCES dbo.Instructor(Id)
            ON DELETE SET NULL;