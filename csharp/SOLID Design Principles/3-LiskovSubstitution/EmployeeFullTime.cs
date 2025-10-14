namespace Liskov
{
    public class EmployeeFullTime : Employee
    {
        public EmployeeFullTime(
            string fullname,
            int hoursWorked,
            int extraHours
        ) : base(fullname, hoursWorked, extraHours)
        {
        }

        /// <summary>
        /// Calculates the total salary based on the hours worked and extra hours.
        /// </summary>
        /// <returns>The total salary as a <see cref="decimal"/> value, calculated as 50 times the sum of  <c>HoursWorked</c> and
        /// <c>ExtraHours</c>.</returns>
        public override decimal CalculateSalary()
        {
            return 50 * (HoursWorked + ExtraHours);
        }
    }
}