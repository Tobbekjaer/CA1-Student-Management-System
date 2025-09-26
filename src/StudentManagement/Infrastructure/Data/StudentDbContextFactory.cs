using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace StudentManagement.Infrastructure.Data;

public class StudentDbContextFactory : IDesignTimeDbContextFactory<StudentDbContext>
{
    public StudentDbContext CreateDbContext(string[] args)
    {
        // Load from .env at design time
        Env.Load();

        var cs = Environment.GetEnvironmentVariable("DB_CONNECTION")
                 ?? throw new InvalidOperationException("DB_CONNECTION not found in .env");

        var options = new DbContextOptionsBuilder<StudentDbContext>()
            .UseSqlServer(cs)
            .Options;

        return new StudentDbContext(options);
    }
}