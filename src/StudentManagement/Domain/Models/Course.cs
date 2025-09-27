namespace StudentManagement.Domain.Models;

public class Course
{
    public int Id { get; set; }
    public string Title { get; set; }
    public decimal Credits { get; set; }
    public int? InstructorId { get; set; }
    public Instructor? Instructor { get; set; }
    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
}