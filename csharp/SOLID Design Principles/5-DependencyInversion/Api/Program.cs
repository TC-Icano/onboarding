using Api.Interface;
using Api.Service;
using DependencyInversion;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
//Register services for Dependency Injection
//REGISTER SERVICE
builder.Services.AddSingleton<IStudentService, StudentService>();
//REGISTER REPOSITORY
builder.Services.AddSingleton<IStudentRepository, StudentRepository>();
//REGISTER LOGBOOK
builder.Services.AddSingleton<ILogbook, Logbook>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

