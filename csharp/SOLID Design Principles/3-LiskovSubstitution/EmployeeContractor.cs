namespace Liskov
{
    public class EmployeeContractor : Employee
    {
        public EmployeeContractor(
            string fullname,
            int hoursWorked,
            int extraHours
        ) : base(fullname, hoursWorked, extraHours)
        {
        }

        /// <summary>
        /// Calculates the total salary based on the standard work hours and extra hours worked.
        /// </summary>
        /// <returns>The total salary as a <see cref="decimal"/> value, calculated using the formula:  40 multiplied by the sum
        /// of <c>HoursWorked</c> and <c>ExtraHours</c>.</returns>
        public override decimal CalculateSalary()
        {
            return HourlyRate * (HoursWorked + ExtraHours);
        }

        private const int HourlyRate = 40;
    }
}