using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using StudentManagement.Infrastructure.Data;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureServices((ctx, services) =>
    {
        // Load variables from .env
        Env.Load();

        // Get connection string from env variable
        var cs = Environment.GetEnvironmentVariable("DB_CONNECTION");

        services.AddDbContext<StudentDbContext>(opt =>
            opt.UseSqlServer(cs));

        services.AddTransient<App>();
    })
    .Build();

await host.Services.GetRequiredService<App>().RunAsync();

public class App
{
    private readonly StudentDbContext _db;
    public App(StudentDbContext db) => _db = db;

    public async Task RunAsync()
    {
        await _db.Database.EnsureCreatedAsync();
        Console.WriteLine("DB ready ✅");
    }
}