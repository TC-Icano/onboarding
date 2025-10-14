using _2_OpenClose;

namespace OpenClose
{
    public class EmployeePartTime : Employee
    {
        public EmployeePartTime(string fullname, int hoursWorked)
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
        /// Calculates the monthly salary for the employee based on hours worked and additional compensation for
        /// overtime.
        /// </summary>
        public override void CalculateSalaryMonthly()
        {
            decimal hourValue = 20000M;
            decimal salary = hourValue * HoursWorked;
            if (HoursWorked > 160)
            {
                decimal effortCompensation = 5000M;
                int extraDays = HoursWorked - 160;
                salary += effortCompensation * extraDays;
            }
            Console.WriteLine($"Employee: {Fullname}, Payment: {salary:C1} ");
        }

        private string _fullname;
        private int _hoursWorked;
    }
}