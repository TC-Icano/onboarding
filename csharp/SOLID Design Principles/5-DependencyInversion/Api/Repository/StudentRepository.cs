using Api.Interface;
using System.Collections.ObjectModel;

namespace DependencyInversion
{
    public class StudentRepository : IStudentRepository
    {
        private static ObservableCollection<Student> collection;

        public StudentRepository(
            ILogbook logbook
        )
        {
            _logbook = logbook;

            InitData();
        }
        
        public IEnumerable<Student> GetAll()
        {
            try
            {
                _logbook.Add("returning student's list");
                return collection;
            }
            catch (Exception ex)
            {
                _logbook.Add($"An error occurred while fetching students: {ex.Message}");
                throw;
            }
        }
        
        public Student Add(Student student)
        {
            try
            {
                collection.Add(student);
                _logbook.Add($"The Student {student.Fullname} have been added");

                return student;
            }
            catch (Exception ex)
            {
                _logbook.Add($"An error occurred while adding a student: {ex.Message}");
                throw;
            }
        }

        private void InitData()
        {
            if (collection == null)
            {
                collection = new();
                collection.Add(new Student(1, "Pepito Pérez", new List<double>() { 3, 4.5 }));
                collection.Add(new Student(2, "Mariana Lopera", new List<double>() { 4, 5 }));
                collection.Add(new Student(3, "José Molina", new List<double>() { 2, 3 }));
            }
        }

        private readonly ILogbook _logbook;
    }
}