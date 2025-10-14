using DependencyInversion;

namespace Api.Interface
{
    public interface IStudentRepository
    {
        /// <summary>
        /// Retrieves all students from the collection.
        /// </summary>
        /// <remarks>This method logs the operation and any errors that occur during execution.  If an
        /// exception is thrown, it is logged and rethrown for the caller to handle.</remarks>
        /// <returns>An <see cref="IEnumerable{T}"/> of <see cref="Student"/> representing the list of all students. The
        /// collection may be empty if no students are available.</returns>
        IEnumerable<Student> GetAll();

        /// <summary>
        /// Adds a new student to the collection.
        /// </summary>
        /// <param name="student">The student to add to the collection. Cannot be <see langword="null"/>.</param>
        /// <returns>The added student.</returns>
        Student Add(Student student);
    }
}
