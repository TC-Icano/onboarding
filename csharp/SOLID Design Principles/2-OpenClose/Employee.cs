
namespace _2_OpenClose
{
    public abstract class Employee
    {
        /// <summary>
        /// Gets or sets the full name of the employee.
        /// </summary>
        public abstract string Fullname { get; set; }

        /// <summary>
        /// Gets or sets the total number of hours worked.
        /// </summary>
        public abstract int HoursWorked { get; set; }

        /// <summary>
        /// Calculates the monthly salary for an employee.
        /// </summary>
        public abstract void CalculateSalaryMonthly();
    }
}
