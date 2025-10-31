using DependencyInversion;

namespace Api.Interface
{
    public interface IStudentService
    {
        /// <summary>
        /// Retrieves all students from the repository.
        /// </summary>
        /// <remarks>This method logs the operation and any errors encountered during execution. Callers
        /// should handle the possibility of a <see langword="null"/> return value.</remarks>
        /// <returns>An <see cref="IEnumerable{T}"/> of <see cref="Student"/> objects representing all students in the
        /// repository. Returns <see langword="null"/> if an error occurs during retrieval.</returns>
        IEnumerable<Student> GetAll();

        /// <summary>
        /// Adds a new student to the repository and logs the operation.
        /// </summary>
        /// <remarks>This method logs the addition of the student and any errors that occur during the
        /// operation.</remarks>
        /// <param name="student">The student to be added. The <paramref name="student"/> parameter cannot be null.</param>
        /// <returns>The added student if the operation is successful; otherwise, <see langword="null"/>.</returns>
        Student Add(Student student);
    }
}
