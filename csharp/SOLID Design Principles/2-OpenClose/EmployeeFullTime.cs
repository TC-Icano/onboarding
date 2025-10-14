using _2_OpenClose;

namespace OpenClose
{
    public class EmployeeFullTime : Employee
    {
        public EmployeeFullTime(string fullname, int hoursWorked)
        {
            Fullname = fullname;
            HoursWorked = hoursWorked;
        }

        public override string Fullname
        {
            get => _fullname;
            set => _fullname = value;
        }

        public override int HoursWorked
        {
            get => _hoursWorked;
            set => _hoursWorked = value;
        }

        /// <summary>
        /// Calculates and displays the monthly salary of the employee based on their hourly rate and hours worked.
        /// </summary>
        public override void CalculateSalaryMonthly()
        {
            decimal hourValue = 30000M;
            decimal salary = hourValue * HoursWorked;
            Console.WriteLine($"Employee: {Fullname}, Salary: {salary:C1} ");
        }

        private string _fullname;
        private int _hoursWorked;
    }
}