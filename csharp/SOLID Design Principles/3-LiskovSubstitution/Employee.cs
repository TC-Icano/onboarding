namespace Liskov
{
    public abstract class Employee
    {
        public string Fullname { get; set; }
        public int HoursWorked { get; set; }
        public int ExtraHours {get;set;}

        public  Employee(
            string fullname,
            int hoursWorked,
            int extraHours
        )
        {
            Fullname = fullname;
            HoursWorked = hoursWorked;
            ExtraHours = extraHours;
        }

        /// <summary>
        /// Calculates the salary of the employee.
        /// </summary>
        /// <returns></returns>
        public abstract decimal CalculateSalary();
    }
}