using Microsoft.EntityFrameworkCore;
using StudentManagement.Domain.Models;

namespace StudentManagement.Infrastructure.Data;

public class StudentDbContext : DbContext
{
    public StudentDbContext(DbContextOptions<StudentDbContext> options) :  base(options) {}
    
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Enrollment> Enrollments => Set<Enrollment>();
    public DbSet<Course> Courses => Set<Course>();
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // STUDENT
        modelBuilder.Entity<Student>(e =>
        {
            e.ToTable("Student");
            e.HasKey(s => s.Id);
            e.Property(s => s.FirstName)
                .IsRequired()
                .HasMaxLength(100);
            e.Property(s => s.MiddleName)
                .HasMaxLength(100);
            e.Property(s => s.LastName)
                .IsRequired()
                .HasMaxLength(100);
            e.Property(s => s.Email)
                .IsRequired()
                .HasMaxLength(255);
            e.HasIndex(s => s.Email).IsUnique();
            e.Property(s => s.DateOfBirth)
                .IsRequired();
            e.Property(s => s.EnrollmentDate)
                .IsRequired();
        });
        
        // INSTRUCTOR
        modelBuilder.Entity<Instructor>(e =>
        {
            e.ToTable("Instructor");
            e.HasKey(i => i.Id);
            e.Property(c => c.FirstName)
                .IsRequired()
                .HasMaxLength(100);
            e.Property(i => i.LastName)
                .IsRequired()
                .HasMaxLength(100);
            e.Property(i => i.Email)
                .IsRequired()
                .HasMaxLength(255);
            e.HasIndex(i => i.Email).IsUnique();
            e.Property(i => i.HireDate)
                .IsRequired();
        });

        // COURSE
        modelBuilder.Entity<Course>(e =>
        {
            e.ToTable("Course");
            e.HasKey(c => c.Id);
            e.Property(c => c.Title)
                .IsRequired()
                .HasMaxLength(200);
            e.Property(c => c.Credits)
                .IsRequired();
            
            // FK: Course -> Instructor
            e.HasOne(c => c.Instructor)            
                .WithMany(i => i.Courses)
                .HasForeignKey(c => c.InstructorId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ENROLLMENT
        modelBuilder.Entity<Enrollment>(e =>
        {
            e.ToTable("Enrollment");
            e.HasKey(x => x.Id);
            e.Property(x => x.FinalGrade).HasMaxLength(10);

            // FK: Enrollment -> Student
            e.HasOne(e => e.Student)
                .WithMany(s => s.Enrollments)
                .HasForeignKey(e => e.StudentId)
                .OnDelete(DeleteBehavior.Cascade);

            // FK: Enrollment -> Course
            e.HasOne(e => e.Course)
                .WithMany(c => c.Enrollments)
                .HasForeignKey(e => e.CourseId)
                .OnDelete(DeleteBehavior.Cascade);
            
            // Prevent duplicate enrollments for same student+course
            e.HasIndex(x => new { x.StudentId, x.CourseId }).IsUnique();
        });
    }
}
