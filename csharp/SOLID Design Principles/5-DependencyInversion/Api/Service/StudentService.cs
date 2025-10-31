using Api.Interface;
using DependencyInversion;

namespace Api.Service
{
    /// <summary>
    /// Provides operations for managing students, including retrieving, adding student records and transforming data.
    /// </summary>
    /// <remarks>This service acts as a mediator between the data repository and the application logic, 
    /// ensuring that student-related operations are logged and handled appropriately.  It relies on an <see
    /// cref="IStudentRepository"/> for data access and an <see cref="ILogbook"/> for logging.</remarks>
    public class StudentService : IStudentService
    {

        private readonly IStudentRepository _studentRepository;
        private readonly ILogbook _logbook;

        public StudentService(
            IStudentRepository studentRepository,

            ILogbook logbook
        )
        {
            _studentRepository = studentRepository;
            _logbook = logbook;
        }

        public IEnumerable<Student> GetAll()
        {
            try
            {
                _logbook.Add($"returning student's list");

                //Retrieved entities can be used for future business logic purposes
                var entities = _studentRepository.GetAll();

                return entities;
            }
            catch (Exception ex)
            {
                _logbook.Add($"An error occurred while retrieving students: {ex.Message}");
                throw;
            }
        }

        public Student Add(Student student)
        {
            try
            {
                //Inserted entity can be used for future business logic purposes
                Student entity = _studentRepository.Add(student);

                _logbook.Add($"The Student {student.Fullname} have been added");

                return entity;
            }
            catch (Exception ex)
            {
                //Implement rollback in case error to maintain data integrity
                //transaction.Rollback();

                _logbook.Add($"Error: {ex.Message}");
                throw;
            }
        }
    }
}
