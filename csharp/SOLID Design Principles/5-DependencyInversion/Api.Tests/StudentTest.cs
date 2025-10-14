using Xunit;
using DependencyInversion.Controllers;
using Moq;
using DependencyInversion;
using Api.Interface;
using Api.Service;

namespace Api.Tests;


public class StudentTest 
{
    [Fact]
    public void Add()
    {
        var LogbookMock = new Mock<ILogbook>();

        var stundentRepositoryMock = new Mock<IStudentRepository>();
        stundentRepositoryMock.Setup(p => p.Add(It.IsAny<Student>()))
                                        .Returns((Student student) => student);

        var studentService = new StudentService(stundentRepositoryMock.Object, LogbookMock.Object);

        var studentsController = new StudentsController(studentService);

        var newStudent = new Student(4, "Isidro Cano", new List<double>() { 4, 4 });
        var resultAddStudent = studentsController.Add(newStudent);

        Assert.NotNull(resultAddStudent);
        Assert.IsType<Microsoft.AspNetCore.Mvc.OkResult>(resultAddStudent);
    }

    [Fact]
    public void GetAll_NotFound()
    {
        var LogbookMock = new Mock<ILogbook>();

        var stundentRepositoryMock = new Mock<IStudentRepository>();
        stundentRepositoryMock.Setup(p => p.GetAll())
                                        .Returns(new List<Student>());

        var studentService = new StudentService(stundentRepositoryMock.Object, LogbookMock.Object);

        var studentsController = new StudentsController(studentService);

        var resultGetStudents = studentsController.Get();

        Assert.NotNull(resultGetStudents);
        Assert.IsType<Microsoft.AspNetCore.Mvc.NotFoundResult>(resultGetStudents);
    }

    [Fact]
    public void GetAll()
    {
        var LogbookMock = new Mock<ILogbook>();

        var stundentRepositoryMock = new Mock<IStudentRepository>();
        stundentRepositoryMock.Setup(p => p.GetAll())
                                        .Returns(new List<Student>()
                                        {
                                            new Student(1, "Pepito Pérez", new List<double>() { 3, 4.5 }),
                                             new Student(2, "Mariana Lopera", new List<double>() { 4, 5 }),
                                             new Student(3, "José Molina", new List<double>() { 2, 3 })
                                        });

        var studentService = new StudentService(stundentRepositoryMock.Object, LogbookMock.Object);

        var resultGetStudents = studentService.GetAll();

        Assert.NotNull(resultGetStudents);
        Assert.Equal(3, resultGetStudents.Count());
    }
}