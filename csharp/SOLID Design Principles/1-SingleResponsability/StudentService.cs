using SingleResponsability;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _1_SingleResponsability
{
    public class StudentService
    {
        #region Constructors

        public StudentService()
        {
            // Initialize the repository
            _studentRepository = new();
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// This method exports the list of all students to a CSV file.
        /// </summary>
        public void ExportAllStudentsToCsv()
        {
            try
            {
                IEnumerable<Student> students = _studentRepository.GetAll();

                // If there are no students cancel the operation
                if (!students.Any())
                {
                    Console.WriteLine("File was not generated due to none students were found");
                    return;
                }

                StringBuilder fileContent = new();
                fileContent.AppendLine("Id;Fullname;Grades");

                // Each student prop is separated by ;
                foreach (var student in students)
                {
                    fileContent.AppendLine($"{student.Id};{student.Fullname};{string.Join("|", student.Grades)}");
                }

                // Write the file to the path indicated
                File.WriteAllText(
                    Path.Combine(
                        _csvPathToSave,
                        CsvFilename
                    ),
                    fileContent.ToString(),
                    Encoding.Unicode
                );
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred while exporting the data: {ex.Message}");
            }
        }

        #endregion

        #region Private Methods

        #endregion

        #region Private Members

        private StudentRepository _studentRepository;

        private readonly string _csvPathToSave = AppDomain.CurrentDomain.BaseDirectory;

        private const string CsvFilename = "Students.csv";

        #endregion
    }
}
