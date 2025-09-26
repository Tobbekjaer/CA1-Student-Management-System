-- The desired state definition of V1
-- state-approach/state/v1/schema.sql
CREATE TABLE dbo.Student (
                             Id INT NOT NULL IDENTITY(1,1),
                             FirstName NVARCHAR(100) NOT NULL,
                             LastName NVARCHAR(100) NOT NULL,
                             Email NVARCHAR(255) NOT NULL,
                             EnrollmentDate DATETIME2 NOT NULL,
                             CONSTRAINT PK_Student PRIMARY KEY (Id)
);
CREATE UNIQUE INDEX UX_Student_Email ON dbo.Student(Email);

CREATE TABLE dbo.Course (
                            Id INT NOT NULL IDENTITY(1,1),
                            Title NVARCHAR(200) NOT NULL,
                            Credits INT NOT NULL,
                            CONSTRAINT PK_Course PRIMARY KEY (Id)
);

CREATE TABLE dbo.Enrollment (
                                Id INT NOT NULL IDENTITY(1,1),
                                StudentId INT NOT NULL,
                                CourseId INT NOT NULL,
                                Grade NVARCHAR(10) NULL,
                                CONSTRAINT PK_Enrollment PRIMARY KEY (Id)
);
CREATE UNIQUE INDEX UX_Enrollment_Student_Course
    ON dbo.Enrollment(StudentId, CourseId);

ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (StudentId) REFERENCES dbo.Student(Id) ON DELETE CASCADE;

ALTER TABLE dbo.Enrollment
    ADD CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (CourseId) REFERENCES dbo.Course(Id) ON DELETE CASCADE;
