using Api.Interface;
using Microsoft.AspNetCore.Mvc;

namespace DependencyInversion.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StudentsController : ControllerBase
{

    private readonly IStudentService _studentService;

    public StudentsController(
        IStudentService studentService
    )
    {
        _studentService = studentService;
    }

    /// <summary>
    /// Retrieves a list of all students.
    /// </summary>
    /// <remarks>This method uses the HTTP GET verb to fetch all student records.  If no students are found, a
    /// 404 Not Found response is returned.  In the event of an unexpected error, a generic problem response is
    /// returned.</remarks>
    /// <returns>An <see cref="IActionResult"/> containing the list of students if any exist;  otherwise, a <see
    /// cref="NotFoundResult"/> if no students are found.  Returns a <see cref="ProblemDetails"/> response in case of an
    /// error.</returns>
    [HttpGet]
    public IActionResult Get()
    {
        try
        {
            var students = _studentService.GetAll();
            if (students == null || students.Count() == 0)
            {
                return NotFound();
            }

            return Ok(students);
        }
        catch (Exception ex)
        {
            return Problem();
        }
    }

    /// <summary>
    /// Adds a new student to the system.
    /// </summary>
    /// <remarks>This method expects the student data to be provided in the request body in JSON format. 
    /// Ensure that the student object contains all required fields before making the request.</remarks>
    /// <param name="student">The student object to be added. The student details must be provided in the request body.</param>
    /// <returns>An <see cref="IActionResult"/> indicating the result of the operation.  Returns <see cref="OkResult"/> if the
    /// student is successfully added, or a generic error response if an exception occurs.</returns>
    [HttpPost]
    public IActionResult Add([FromBody] Student student)
    {
        try
        {
            _studentService.Add(student);
            return Ok();
        }
        catch (Exception ex)
        {
            return Problem();
        } 
    }
}
