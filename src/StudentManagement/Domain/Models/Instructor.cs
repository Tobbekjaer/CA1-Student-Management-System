namespace StudentManagement.Domain.Models;

public class Instructor
{
    public int Id { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public DateTime HireDate { get; set; }
    public ICollection<Course> Courses { get; set; }
    public Department? DepartmentHeadOf { get; set; }
}